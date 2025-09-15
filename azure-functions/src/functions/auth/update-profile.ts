import { app, HttpRequest, HttpResponseInit, InvocationContext } from '@azure/functions';
import { ApiResponse, UnauthorizedError, ValidationError } from '../../models/base';
import { UpdateUserRequest } from '../../models/user';
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

export async function updateProfile(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
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
        const body: UpdateUserRequest = await request.json();

        // Validate input
        if (Object.keys(body).length === 0) {
            throw new ValidationError('No fields to update', 'body');
        }

        // Prepare update object
        const updateData: any = {
            updatedAt: new Date(),
            updatedBy: currentUser._id
        };

        // Add fields to update
        if (body.displayName !== undefined) updateData.displayName = body.displayName;
        if (body.firstName !== undefined) updateData.firstName = body.firstName;
        if (body.lastName !== undefined) updateData.lastName = body.lastName;
        if (body.phoneNumber !== undefined) updateData.phoneNumber = body.phoneNumber;
        if (body.dateOfBirth !== undefined) updateData.dateOfBirth = new Date(body.dateOfBirth);
        if (body.gender !== undefined) updateData.gender = body.gender;
        if (body.address !== undefined) updateData.address = body.address;
        if (body.profileImageUrl !== undefined) updateData.profileImageUrl = body.profileImageUrl;
        if (body.notificationSettings !== undefined) updateData.notificationSettings = body.notificationSettings;
        if (body.emergencyContact !== undefined) updateData.emergencyContact = body.emergencyContact;

        // Update user profile
        const success = await databaseService.updateOne(
            'users',
            { _id: currentUser._id },
            { $set: updateData }
        );

        if (!success) {
            throw new Error('Failed to update profile');
        }

        // Get updated user
        const updatedUser = await authService.getUserByAzureId(claims.sub);
        if (!updatedUser) {
            throw new Error('Failed to retrieve updated profile');
        }

        // Return updated profile
        const profile = {
            id: updatedUser._id,
            email: updatedUser.email,
            displayName: updatedUser.displayName,
            firstName: updatedUser.firstName,
            lastName: updatedUser.lastName,
            phoneNumber: updatedUser.phoneNumber,
            dateOfBirth: updatedUser.dateOfBirth,
            gender: updatedUser.gender,
            address: updatedUser.address,
            role: updatedUser.role,
            profileImageUrl: updatedUser.profileImageUrl,
            notificationSettings: updatedUser.notificationSettings,
            emergencyContact: updatedUser.emergencyContact,
            updatedAt: updatedUser.updatedAt
        };

        return {
            status: 200,
            jsonBody: {
                success: true,
                data: { profile },
                message: 'Profile updated successfully'
            } as ApiResponse
        };

    } catch (error) {
        context.error('Update profile error:', error);

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

app.http('update-profile', {
    methods: ['PUT'],
    authLevel: 'anonymous',
    route: 'auth/profile',
    handler: updateProfile
});
