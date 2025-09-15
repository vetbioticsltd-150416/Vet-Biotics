import { app, HttpRequest, HttpResponseInit, InvocationContext } from '@azure/functions';
import { ApiResponse, UnauthorizedError } from '../../models/base';
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

export async function getProfile(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
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

        // Get user profile
        const user = await authService.getUserByAzureId(claims.sub);
        if (!user) {
            throw new UnauthorizedError('User not found');
        }

        // Return user profile (exclude sensitive data)
        const profile = {
            id: user._id,
            email: user.email,
            displayName: user.displayName,
            firstName: user.firstName,
            lastName: user.lastName,
            phoneNumber: user.phoneNumber,
            dateOfBirth: user.dateOfBirth,
            gender: user.gender,
            address: user.address,
            role: user.role,
            profileImageUrl: user.profileImageUrl,
            notificationSettings: user.notificationSettings,
            emergencyContact: user.emergencyContact,
            emailVerified: user.emailVerified,
            lastLoginAt: user.lastLoginAt,
            createdAt: user.createdAt
        };

        return {
            status: 200,
            jsonBody: {
                success: true,
                data: { profile },
                message: 'Profile retrieved successfully'
            } as ApiResponse
        };

    } catch (error) {
        context.error('Get profile error:', error);

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

app.http('get-profile', {
    methods: ['GET'],
    authLevel: 'anonymous',
    route: 'auth/profile',
    handler: getProfile
});
