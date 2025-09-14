import 'package:flutter_test/flutter_test.dart';
import 'package:vet_biotics_core/core.dart';

void main() {
  group('UserRole Enum', () {
    test('should have correct enum values', () {
      expect(UserRole.client.value, 'client');
      expect(UserRole.receptionist.value, 'receptionist');
      expect(UserRole.veterinarian.value, 'veterinarian');
      expect(UserRole.clinicAdmin.value, 'clinic_admin');
      expect(UserRole.superAdmin.value, 'super_admin');
    });

    test('should have correct display names', () {
      expect(UserRole.client.displayName, 'Client');
      expect(UserRole.receptionist.displayName, 'Receptionist');
      expect(UserRole.veterinarian.displayName, 'Veterinarian');
      expect(UserRole.clinicAdmin.displayName, 'Clinic Admin');
      expect(UserRole.superAdmin.displayName, 'Super Admin');
    });

    test('fromString should return correct role', () {
      expect(UserRole.fromString('client'), UserRole.client);
      expect(UserRole.fromString('receptionist'), UserRole.receptionist);
      expect(UserRole.fromString('veterinarian'), UserRole.veterinarian);
      expect(UserRole.fromString('clinic_admin'), UserRole.clinicAdmin);
      expect(UserRole.fromString('super_admin'), UserRole.superAdmin);
    });

    test('fromString should return client for unknown value', () {
      expect(UserRole.fromString('unknown'), UserRole.client);
      expect(UserRole.fromString(''), UserRole.client);
    });

    test('should have all expected values', () {
      final values = UserRole.values;
      expect(values.length, 5);
      expect(values, contains(UserRole.client));
      expect(values, contains(UserRole.receptionist));
      expect(values, contains(UserRole.veterinarian));
      expect(values, contains(UserRole.clinicAdmin));
      expect(values, contains(UserRole.superAdmin));
    });
  });
}
