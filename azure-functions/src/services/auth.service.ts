import { AuthenticationResult, ConfidentialClientApplication } from '@azure/msal-node';
import { UnauthorizedError, ValidationError } from '../models/base';
import { CreateUserRequest, User, UserRole } from '../models/user';
import { DatabaseService } from './database.service';

export interface AuthTokens {
    accessToken: string;
    refreshToken?: string;
    idToken: string;
    expiresIn: number;
    tokenType: string;
}

export interface UserClaims {
    sub: string; // Azure AD B2C user ID
    email: string;
    given_name?: string;
    family_name?: string;
    extension_role?: UserRole;
    emails?: string[];
}

export class AuthService {
    private msalClient: ConfidentialClientApplication;
    private databaseService: DatabaseService;

    constructor(
        clientId: string,
        clientSecret: string,
        tenantId: string,
        databaseService: DatabaseService
    ) {
        this.msalClient = new ConfidentialClientApplication({
            auth: {
                clientId,
                clientSecret,
                authority: `https://${tenantId}.b2clogin.com/${tenantId}.onmicrosoft.com/B2C_1_SignUpSignIn`
            }
        });
        this.databaseService = databaseService;
    }

    /**
     * Authenticate user with Azure AD B2C
     */
    async authenticateUser(authorizationCode: string, codeVerifier?: string): Promise<AuthTokens> {
        try {
            const tokenRequest = {
                code: authorizationCode,
                scopes: ['openid', 'profile', 'email'],
                codeVerifier,
                redirectUri: process.env.REDIRECT_URI || 'com.vetbiotics.app://oauthredirect'
            };

            const response: AuthenticationResult = await this.msalClient.acquireTokenByCode(tokenRequest);

            return {
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                idToken: response.idToken || '',
                expiresIn: response.expiresOn ? Math.floor((response.expiresOn.getTime() - Date.now()) / 1000) : 3600,
                tokenType: 'Bearer'
            };
        } catch (error) {
            console.error('Authentication failed:', error);
            throw new UnauthorizedError('Invalid authorization code');
        }
    }

    /**
     * Refresh access token
     */
    async refreshToken(refreshToken: string): Promise<AuthTokens> {
        try {
            const tokenRequest = {
                refreshToken,
                scopes: ['openid', 'profile', 'email']
            };

            const response: AuthenticationResult = await this.msalClient.acquireTokenByRefreshToken(tokenRequest);

            return {
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                idToken: response.idToken || '',
                expiresIn: response.expiresOn ? Math.floor((response.expiresOn.getTime() - Date.now()) / 1000) : 3600,
                tokenType: 'Bearer'
            };
        } catch (error) {
            console.error('Token refresh failed:', error);
            throw new UnauthorizedError('Invalid refresh token');
        }
    }

    /**
     * Validate access token and extract claims
     */
    async validateToken(accessToken: string): Promise<UserClaims> {
        try {
            // For Azure AD B2C, we can decode the JWT token to get claims
            // In production, you should validate the token signature
            const payload = this.decodeJwtPayload(accessToken);

            if (!payload.sub || !payload.email) {
                throw new UnauthorizedError('Invalid token claims');
            }

            return {
                sub: payload.sub,
                email: payload.email,
                given_name: payload.given_name,
                family_name: payload.family_name,
                extension_role: payload.extension_role,
                emails: payload.emails
            };
        } catch (error) {
            console.error('Token validation failed:', error);
            throw new UnauthorizedError('Invalid access token');
        }
    }

    /**
     * Decode JWT payload (without signature verification for demo)
     */
    private decodeJwtPayload(token: string): any {
        try {
            const parts = token.split('.');
            if (parts.length !== 3) {
                throw new Error('Invalid JWT format');
            }

            const payload = Buffer.from(parts[1], 'base64').toString();
            return JSON.parse(payload);
        } catch (error) {
            throw new Error('Failed to decode JWT token');
        }
    }

    /**
     * Get or create user from Azure AD B2C claims
     */
    async getOrCreateUser(claims: UserClaims): Promise<User> {
        // Try to find existing user
        let user = await this.databaseService.findOne<User>('users', {
            azureB2CId: claims.sub
        });

        if (!user) {
            // Create new user
            const createUserRequest: CreateUserRequest = {
                email: claims.email,
                displayName: this.buildDisplayName(claims),
                firstName: claims.given_name,
                lastName: claims.family_name,
                role: claims.extension_role || UserRole.CLIENT,
                azureB2CId: claims.sub,
                emailVerified: true // Azure AD B2C handles email verification
            };

            const userId = await this.databaseService.insertOne<User>('users', createUserRequest);
            user = await this.databaseService.findOne<User>('users', { _id: userId });

            if (!user) {
                throw new Error('Failed to create user');
            }
        }

        // Update last login
        await this.databaseService.updateOne<User>(
            'users',
            { _id: user._id },
            { $set: { lastLoginAt: new Date() } }
        );

        return user;
    }

    /**
     * Build display name from claims
     */
    private buildDisplayName(claims: UserClaims): string {
        if (claims.given_name && claims.family_name) {
            return `${claims.given_name} ${claims.family_name}`;
        } else if (claims.given_name) {
            return claims.given_name;
        } else if (claims.family_name) {
            return claims.family_name;
        } else {
            // Fallback to email prefix
            return claims.email.split('@')[0];
        }
    }

    /**
     * Get user by Azure AD B2C ID
     */
    async getUserByAzureId(azureB2CId: string): Promise<User | null> {
        return await this.databaseService.findOne<User>('users', {
            azureB2CId,
            isActive: true,
            $or: [
                { isDeleted: { $exists: false } },
                { isDeleted: false }
            ]
        });
    }

    /**
     * Update user role (admin function)
     */
    async updateUserRole(userId: string, newRole: UserRole, updatedBy: string): Promise<boolean> {
        const validRoles = Object.values(UserRole);
        if (!validRoles.includes(newRole)) {
            throw new ValidationError('Invalid user role', 'role');
        }

        return await this.databaseService.updateOne<User>(
            'users',
            { _id: userId },
            {
                $set: {
                    role: newRole,
                    updatedBy
                }
            }
        );
    }

    /**
     * Deactivate user
     */
    async deactivateUser(userId: string, deactivatedBy: string): Promise<boolean> {
        return await this.databaseService.updateOne<User>(
            'users',
            { _id: userId },
            {
                $set: {
                    isActive: false,
                    updatedBy: deactivatedBy
                }
            }
        );
    }

    /**
     * Get user permissions based on role
     */
    getUserPermissions(role: UserRole): string[] {
        const basePermissions = ['read_own_profile', 'update_own_profile'];

        switch (role) {
            case UserRole.CLIENT:
                return [
                    ...basePermissions,
                    'read_own_pets',
                    'create_pet',
                    'update_own_pet',
                    'read_own_appointments',
                    'create_appointment',
                    'cancel_own_appointment',
                    'read_own_medical_records',
                    'read_own_invoices',
                    'pay_invoice'
                ];

            case UserRole.VETERINARIAN:
                return [
                    ...basePermissions,
                    'read_clinic_patients',
                    'update_patient_records',
                    'create_medical_record',
                    'update_medical_record',
                    'read_clinic_appointments',
                    'update_appointment_status',
                    'create_prescription',
                    'read_clinic_inventory',
                    'generate_invoice'
                ];

            case UserRole.RECEPTIONIST:
                return [
                    ...basePermissions,
                    'read_clinic_appointments',
                    'create_appointment',
                    'update_appointment',
                    'cancel_appointment',
                    'read_clinic_patients',
                    'update_patient_info',
                    'generate_invoice',
                    'process_payment'
                ];

            case UserRole.CLINIC_ADMIN:
                return [
                    ...basePermissions,
                    'manage_clinic_staff',
                    'manage_clinic_services',
                    'manage_clinic_settings',
                    'view_clinic_reports',
                    'manage_clinic_inventory',
                    'manage_clinic_finances'
                ];

            case UserRole.SUPER_ADMIN:
                return [
                    ...basePermissions,
                    'manage_all_clinics',
                    'manage_all_users',
                    'view_system_reports',
                    'manage_system_settings',
                    'manage_billing',
                    'system_administration'
                ];

            default:
                return basePermissions;
        }
    }

    /**
     * Check if user has permission
     */
    hasPermission(userRole: UserRole, requiredPermission: string): boolean {
        const permissions = this.getUserPermissions(userRole);
        return permissions.includes(requiredPermission);
    }
}
