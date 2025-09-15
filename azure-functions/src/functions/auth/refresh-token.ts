import { app, HttpRequest, HttpResponseInit, InvocationContext } from '@azure/functions';
import { ApiResponse } from '../../models/base';
import { AuthService } from '../../services/auth.service';
import { DatabaseService } from '../../services/database.service';

interface RefreshTokenRequest {
    refreshToken: string;
}

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

export async function refreshToken(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    try {
        // Connect to database
        await databaseService.connect();

        // Parse request body
        const body: RefreshTokenRequest = await request.json();

        if (!body.refreshToken) {
            return {
                status: 400,
                jsonBody: {
                    success: false,
                    message: 'Refresh token is required',
                    error: 'MISSING_REFRESH_TOKEN'
                } as ApiResponse
            };
        }

        // Refresh token with Azure AD B2C
        const tokens = await authService.refreshToken(body.refreshToken);

        // Return success response
        return {
            status: 200,
            jsonBody: {
                success: true,
                data: { tokens },
                message: 'Token refreshed successfully'
            } as ApiResponse
        };

    } catch (error) {
        context.error('Token refresh error:', error);

        if (error instanceof Error) {
            return {
                status: 401,
                jsonBody: {
                    success: false,
                    message: 'Token refresh failed',
                    error: error.message
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

app.http('refresh-token', {
    methods: ['POST'],
    authLevel: 'anonymous',
    route: 'auth/refresh-token',
    handler: refreshToken
});
