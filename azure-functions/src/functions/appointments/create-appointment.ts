import { app, HttpRequest, HttpResponseInit, InvocationContext } from '@azure/functions';
import { ObjectId } from 'mongodb';
import { Appointment, AppointmentStatus, CreateAppointmentRequest } from '../../models/appointment';
import { ApiResponse, ForbiddenError, NotFoundError, UnauthorizedError, ValidationError } from '../../models/base';
import { AuthService } from '../../services/auth.service';
import { DatabaseService } from '../../services/database.service';

// Initialize services
const databaseService = new DatabaseService(
    process.env.COSMOS_DB_ENDPOINT!,
    process.env.COSMOS_DB_DATABASE!
);

const authService = new AuthService(
    process.env.AZURE_AD_B2C_CLIENT_ID!,
    process.env.AZURE_AD_B2C_CLIENT_SECRET!,
    process.env.AZURE_AD_B2C_TENANT_ID!,
    databaseService
);

// Generate appointment number
function generateAppointmentNumber(): string {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
    return `APT-${timestamp}-${random}`;
}

// Validate appointment data
function validateAppointmentData(data: CreateAppointmentRequest): void {
    if (!data.petId) throw new ValidationError('Pet ID is required', 'petId');
    if (!data.ownerId) throw new ValidationError('Owner ID is required', 'ownerId');
    if (!data.veterinarianId) throw new ValidationError('Veterinarian ID is required', 'veterinarianId');
    if (!data.clinicId) throw new ValidationError('Clinic ID is required', 'clinicId');
    if (!data.scheduledDate) throw new ValidationError('Scheduled date is required', 'scheduledDate');
    if (!data.duration || data.duration <= 0) throw new ValidationError('Valid duration is required', 'duration');
    if (!data.reason) throw new ValidationError('Appointment reason is required', 'reason');
    if (!data.serviceName) throw new ValidationError('Service name is required', 'serviceName');
    if (!data.price || data.price < 0) throw new ValidationError('Valid price is required', 'price');

    // Check if scheduled date is in the future
    const scheduledDate = new Date(data.scheduledDate);
    if (scheduledDate <= new Date()) {
        throw new ValidationError('Appointment must be scheduled for a future date', 'scheduledDate');
    }
}

export async function createAppointment(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    try {
        // Connect to database
        await databaseService.connect();

        // Get authorization header
        const authHeader = request.headers.get('authorization');
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            throw new UnauthorizedError('Missing or invalid authorization header');
        }

        const accessToken = authHeader.substring(7);

        // Validate token and get claims
        const claims = await authService.validateToken(accessToken);

        // Get current user
        const currentUser = await authService.getUserByAzureId(claims.sub);
        if (!currentUser) {
            throw new UnauthorizedError('User not found');
        }

        // Parse request body
        const body: CreateAppointmentRequest = await request.json();
        validateAppointmentData(body);

        // Verify permissions
        const isOwner = currentUser._id!.toString() === body.ownerId;
        const isReceptionist = currentUser.role === 'receptionist' && currentUser.clinicId?.toString() === body.clinicId;
        const isVeterinarian = currentUser.role === 'veterinarian' && currentUser._id!.toString() === body.veterinarianId;

        if (!isOwner && !isReceptionist && !isVeterinarian && !authService.hasPermission(currentUser.role, 'create_appointment')) {
            throw new ForbiddenError('Insufficient permissions to create appointment');
        }

        // Verify that referenced entities exist
        const [pet, owner, veterinarian, clinic] = await Promise.all([
            databaseService.findOne('pets', { _id: new ObjectId(body.petId) }),
            databaseService.findOne('users', { _id: new ObjectId(body.ownerId) }),
            databaseService.findOne('users', { _id: new ObjectId(body.veterinarianId), role: 'veterinarian' }),
            databaseService.findOne('clinics', { _id: new ObjectId(body.clinicId) })
        ]);

        if (!pet) throw new NotFoundError('Pet not found', 'pet');
        if (!owner) throw new NotFoundError('Owner not found', 'user');
        if (!veterinarian) throw new NotFoundError('Veterinarian not found', 'user');
        if (!clinic) throw new NotFoundError('Clinic not found', 'clinic');

        // Check if pet belongs to owner
        if (pet.ownerId.toString() !== body.ownerId) {
            throw new ValidationError('Pet does not belong to the specified owner', 'petId');
        }

        // Check for scheduling conflicts
        const scheduledDate = new Date(body.scheduledDate);
        const endDate = new Date(scheduledDate.getTime() + body.duration * 60000);

        const conflictingAppointments = await databaseService.find('appointments', {
            veterinarianId: new ObjectId(body.veterinarianId),
            status: { $in: ['pending', 'confirmed', 'inProgress'] },
            $or: [
                {
                    scheduledDate: { $lt: endDate },
                    $expr: {
                        $gt: [
                            { $add: ['$scheduledDate', { $multiply: ['$duration', 60000] }] },
                            scheduledDate
                        ]
                    }
                }
            ]
        });

        if (conflictingAppointments.length > 0) {
            throw new ValidationError('Veterinarian has a scheduling conflict', 'scheduledDate');
        }

        // Create appointment
        const appointmentData: Omit<Appointment, '_id'> = {
            appointmentNumber: generateAppointmentNumber(),
            petId: new ObjectId(body.petId),
            ownerId: new ObjectId(body.ownerId),
            veterinarianId: new ObjectId(body.veterinarianId),
            clinicId: new ObjectId(body.clinicId),
            scheduledDate,
            duration: body.duration,
            endDate,
            status: AppointmentStatus.PENDING,
            reason: body.reason,
            serviceName: body.serviceName,
            price: body.price,
            paymentStatus: 'pending',
            serviceId: body.serviceId,
            notes: body.notes,
            symptoms: body.symptoms,
            isEmergency: body.isEmergency || false,
            priority: body.priority || 'medium',
            createdBy: currentUser._id,
            updatedBy: currentUser._id
        };

        const appointmentId = await databaseService.insertOne<Appointment>('appointments', appointmentData);

        // Get created appointment with details
        const createdAppointment = await databaseService.findOne<Appointment>('appointments', { _id: appointmentId });
        if (!createdAppointment) {
            throw new Error('Failed to retrieve created appointment');
        }

        return {
            status: 201,
            jsonBody: {
                success: true,
                data: {
                    appointment: {
                        id: createdAppointment._id,
                        appointmentNumber: createdAppointment.appointmentNumber,
                        scheduledDate: createdAppointment.scheduledDate,
                        duration: createdAppointment.duration,
                        status: createdAppointment.status,
                        reason: createdAppointment.reason,
                        serviceName: createdAppointment.serviceName,
                        price: createdAppointment.price
                    }
                },
                message: 'Appointment created successfully'
            } as ApiResponse
        };

    } catch (error) {
        context.error('Create appointment error:', error);

        if (error instanceof ValidationError) {
            return {
                status: 400,
                jsonBody: {
                    success: false,
                    message: error.message,
                    error: error.field
                } as ApiResponse
            };
        }

        if (error instanceof NotFoundError) {
            return {
                status: 404,
                jsonBody: {
                    success: false,
                    message: error.message,
                    error: error.resource
                } as ApiResponse
            };
        }

        if (error instanceof UnauthorizedError) {
            return {
                status: 401,
                jsonBody: {
                    success: false,
                    message: error.message,
                    error: 'UNAUTHORIZED'
                } as ApiResponse
            };
        }

        if (error instanceof ForbiddenError) {
            return {
                status: 403,
                jsonBody: {
                    success: false,
                    message: error.message,
                    error: 'FORBIDDEN'
                } as ApiResponse
            };
        }

        return {
            status: 500,
            jsonBody: {
                success: false,
                message: 'Internal server error',
                error: 'INTERNAL_ERROR'
            } as ApiResponse
        };
    } finally {
        await databaseService.disconnect();
    }
}

app.http('create-appointment', {
    methods: ['POST'],
    authLevel: 'anonymous',
    route: 'appointments',
    handler: createAppointment
});
