import { UserRole } from '../models/base';
import { AuthService } from '../services/auth.service';
import { DatabaseService } from '../services/database.service';

// Mock DatabaseService
jest.mock('../services/database.service');
const MockDatabaseService = DatabaseService as jest.MockedClass<typeof DatabaseService>;

describe('AuthService', () => {
    let authService: AuthService;
    let mockDatabaseService: jest.Mocked<DatabaseService>;

    beforeEach(() => {
        // Reset mocks
        MockDatabaseService.mockClear();

        // Create mock instance
        mockDatabaseService = new MockDatabaseService(
            'test-endpoint',
            'test-database'
        ) as jest.Mocked<DatabaseService>;

        // Create AuthService instance
        authService = new AuthService(
            'test-client-id',
            'test-client-secret',
            'test-tenant-id',
            mockDatabaseService
        );
    });

    describe('getUserPermissions', () => {
        it('should return correct permissions for client role', () => {
            const permissions = authService.getUserPermissions(UserRole.CLIENT);

            expect(permissions).toContain('read_own_profile');
            expect(permissions).toContain('create_appointment');
            expect(permissions).toContain('read_own_appointments');
            expect(permissions).toContain('pay_invoice');
        });

        it('should return correct permissions for veterinarian role', () => {
            const permissions = authService.getUserPermissions(UserRole.VETERINARIAN);

            expect(permissions).toContain('create_medical_record');
            expect(permissions).toContain('update_medical_record');
            expect(permissions).toContain('update_appointment_status');
            expect(permissions).toContain('create_prescription');
        });

        it('should return correct permissions for receptionist role', () => {
            const permissions = authService.getUserPermissions(UserRole.RECEPTIONIST);

            expect(permissions).toContain('create_appointment');
            expect(permissions).toContain('update_appointment');
            expect(permissions).toContain('generate_invoice');
            expect(permissions).toContain('process_payment');
        });

        it('should return correct permissions for clinic admin role', () => {
            const permissions = authService.getUserPermissions(UserRole.CLINIC_ADMIN);

            expect(permissions).toContain('manage_clinic_staff');
            expect(permissions).toContain('manage_clinic_services');
            expect(permissions).toContain('view_clinic_reports');
            expect(permissions).toContain('manage_clinic_finances');
        });

        it('should return correct permissions for super admin role', () => {
            const permissions = authService.getUserPermissions(UserRole.SUPER_ADMIN);

            expect(permissions).toContain('manage_all_clinics');
            expect(permissions).toContain('manage_all_users');
            expect(permissions).toContain('view_system_reports');
            expect(permissions).toContain('system_administration');
        });
    });

    describe('hasPermission', () => {
        it('should return true for allowed permissions', () => {
            expect(authService.hasPermission(UserRole.CLIENT, 'read_own_profile')).toBe(true);
            expect(authService.hasPermission(UserRole.VETERINARIAN, 'create_medical_record')).toBe(true);
            expect(authService.hasPermission(UserRole.RECEPTIONIST, 'create_appointment')).toBe(true);
        });

        it('should return false for denied permissions', () => {
            expect(authService.hasPermission(UserRole.CLIENT, 'create_medical_record')).toBe(false);
            expect(authService.hasPermission(UserRole.VETERINARIAN, 'manage_all_users')).toBe(false);
            expect(authService.hasPermission(UserRole.RECEPTIONIST, 'view_system_reports')).toBe(false);
        });
    });

    describe('buildDisplayName', () => {
        it('should build display name from given and family name', () => {
            const claims = {
                sub: 'test-sub',
                email: 'test@example.com',
                given_name: 'John',
                family_name: 'Doe'
            };

            expect((authService as any).buildDisplayName(claims)).toBe('John Doe');
        });

        it('should use given name only if family name is missing', () => {
            const claims = {
                sub: 'test-sub',
                email: 'test@example.com',
                given_name: 'John'
            };

            expect((authService as any).buildDisplayName(claims)).toBe('John');
        });

        it('should use family name only if given name is missing', () => {
            const claims = {
                sub: 'test-sub',
                email: 'test@example.com',
                family_name: 'Doe'
            };

            expect((authService as any).buildDisplayName(claims)).toBe('Doe');
        });

        it('should use email prefix as fallback', () => {
            const claims = {
                sub: 'test-sub',
                email: 'john.doe@example.com'
            };

            expect((authService as any).buildDisplayName(claims)).toBe('john.doe');
        });
    });
});
