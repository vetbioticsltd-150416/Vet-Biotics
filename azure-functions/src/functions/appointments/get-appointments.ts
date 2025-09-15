import { app, HttpRequest, HttpResponseInit, InvocationContext } from '@azure/functions';
import { ObjectId } from 'mongodb';
import { AppointmentWithDetails } from '../../models/appointment';
import { ApiResponse, ForbiddenError, UnauthorizedError } from '../../models/base';
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

export async function getAppointments(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
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

        // Parse query parameters
        const url = new URL(request.url);
        const page = parseInt(url.searchParams.get('page') || '1');
        const limit = parseInt(url.searchParams.get('limit') || '20');
        const status = url.searchParams.get('status');
        const startDate = url.searchParams.get('startDate');
        const endDate = url.searchParams.get('endDate');
        const clinicId = url.searchParams.get('clinicId');

        // Build filter based on user role and permissions
        let filter: any = {
            isDeleted: { $ne: true }
        };

        switch (currentUser.role) {
            case 'client':
                // Clients can only see their own appointments
                filter.ownerId = currentUser._id;
                break;

            case 'veterinarian':
                // Veterinarians can see appointments assigned to them
                filter.veterinarianId = currentUser._id;
                if (clinicId) filter.clinicId = new ObjectId(clinicId);
                break;

            case 'receptionist':
                // Receptionists can see appointments for their clinic
                if (currentUser.clinicId) {
                    filter.clinicId = currentUser.clinicId;
                }
                if (clinicId) filter.clinicId = new ObjectId(clinicId);
                break;

            case 'clinicAdmin':
            case 'superAdmin':
                // Admins can see all appointments, optionally filtered by clinic
                if (clinicId) filter.clinicId = new ObjectId(clinicId);
                break;

            default:
                throw new ForbiddenError('Invalid user role');
        }

        // Add additional filters
        if (status) {
            filter.status = status;
        }

        if (startDate || endDate) {
            filter.scheduledDate = {};
            if (startDate) filter.scheduledDate.$gte = new Date(startDate);
            if (endDate) filter.scheduledDate.$lte = new Date(endDate);
        }

        // Get appointments with pagination
        const { data: appointments, total, totalPages } = await databaseService.findWithPagination<AppointmentWithDetails>(
            'appointments',
            filter,
            page,
            limit,
            { scheduledDate: -1 } // Sort by date descending
        );

        // Enrich appointments with related data
        const enrichedAppointments = await Promise.all(
            appointments.map(async (appointment) => {
                // Get pet details
                const pet = await databaseService.findOne('pets', { _id: appointment.petId });

                // Get owner details (limited fields)
                const owner = await databaseService.findOne('users', { _id: appointment.ownerId });

                // Get veterinarian details
                const veterinarian = await databaseService.findOne('users', { _id: appointment.veterinarianId });

                // Get clinic details
                const clinic = await databaseService.findOne('clinics', { _id: appointment.clinicId });

                return {
                    ...appointment,
                    pet: pet ? {
                        _id: pet._id,
                        name: pet.name,
                        species: pet.species,
                        breed: pet.breed,
                        owner: owner ? {
                            _id: owner._id,
                            displayName: owner.displayName,
                            phoneNumber: owner.phoneNumber
                        } : undefined
                    } : undefined,
                    veterinarian: veterinarian ? {
                        _id: veterinarian._id,
                        displayName: veterinarian.displayName,
                        email: veterinarian.email,
                        specialties: veterinarian.specialties
                    } : undefined,
                    clinic: clinic ? {
                        _id: clinic._id,
                        name: clinic.name,
                        address: clinic.address,
                        phoneNumber: clinic.phoneNumber
                    } : undefined
                };
            })
        );

        // Create pagination info
        const pagination = {
            currentPage: page,
            totalPages,
            totalItems: total,
            itemsPerPage: limit,
            hasNextPage: page < totalPages,
            hasPreviousPage: page > 1
        };

        return {
            status: 200,
            jsonBody: {
                success: true,
                data: enrichedAppointments,
                pagination,
                message: 'Appointments retrieved successfully'
            } as ApiResponse
        };

    } catch (error) {
        context.error('Get appointments error:', error);

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

app.http('get-appointments', {
    methods: ['GET'],
    authLevel: 'anonymous',
    route: 'appointments',
    handler: getAppointments
});
