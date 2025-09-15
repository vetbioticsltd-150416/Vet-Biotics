import { app, HttpRequest, HttpResponseInit, InvocationContext } from '@azure/functions';
import { ApiResponse } from '../../models/base';
import { AuthService } from '../../services/auth.service';
import { DatabaseService } from '../../services/database.service';

interface LoginRequest {
    authorizationCode: string;
    codeVerifier?: string;
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

export async function login(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    try {
        // Connect to database
        await databaseService.connect();

        // Parse request body
        const body: LoginRequest = await request.json();

        if (!body.authorizationCode) {
            return {
                status: 400,
                jsonBody: {
                    success: false,
                    message: 'Authorization code is required',
                    error: 'MISSING_AUTHORIZATION_CODE'
                } as ApiResponse
            };
        }

        // Authenticate with Azure AD B2C
        const tokens = await authService.authenticateUser(body.authorizationCode, body.codeVerifier);

        // Validate token and get user claims
        const claims = await authService.validateToken(tokens.accessToken);

        // Get or create user
        const user = await authService.getOrCreateUser(claims);

        // Return success response
        return {
            status: 200,
            jsonBody: {
                success: true,
                data: {
                    user: {
                        id: user._id,
                        email: user.email,
                        displayName: user.displayName,
                        role: user.role,
                        profileImageUrl: user.profileImageUrl
                    },
                    tokens
                },
                message: 'Login successful'
            } as ApiResponse
        };

    } catch (error) {
        context.error('Login error:', error);

        if (error instanceof Error) {
            return {
                status: 401,
                jsonBody: {
                    success: false,
                    message: 'Authentication failed',
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

app.http('login', {
    methods: ['POST'],
    authLevel: 'anonymous',
    route: 'auth/login',
    handler: login
});
