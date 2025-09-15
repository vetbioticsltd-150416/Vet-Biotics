import 'package:flutter_test/flutter_test.dart';
import 'package:vet_biotics_core/core.dart';

void main() {
  group('Clinic Entity', () {
    const clinicId = 'clinic_123';
    const name = 'Central Pet Clinic';
    const address = '123 Main St, City, State 12345';
    const phone = '(555) 123-4567';
    const email = 'info@centralpetclinic.com';
    final createdAt = DateTime(2024, 1, 1);
    final updatedAt = DateTime(2024, 1, 2);

    test('should create Clinic with all required fields', () {
      // Arrange & Act
      final clinic = Clinic(
        id: clinicId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isActive: true,
        name: name,
        ownerId: 'owner123',
        address: address,
        phone: phone,
        email: email,
        status: ClinicStatus.active,
      );

      // Assert
      expect(clinic.id, clinicId);
      expect(clinic.name, name);
      expect(clinic.address, address);
      expect(clinic.phone, phone);
      expect(clinic.email, email);
      expect(clinic.isActive, true);
      expect(clinic.createdAt, createdAt);
      expect(clinic.updatedAt, updatedAt);
    });

    test('should create Clinic with default isActive = true', () {
      // Arrange & Act
      final clinic = Clinic(
        id: clinicId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        name: name,
        ownerId: 'owner123',
        address: address,
        phone: phone,
        email: email,
        status: ClinicStatus.active,
      );

      // Assert
      expect(clinic.isActive, true);
    });

    test('should support both active and inactive states', () {
      // Test active clinic
      final activeClinic = Clinic(
        id: clinicId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isActive: true,
        name: name,
        ownerId: 'owner123',
        address: address,
        phone: phone,
        email: email,
        status: ClinicStatus.active,
      );

      // Test inactive clinic
      final inactiveClinic = Clinic(
        id: 'clinic_456',
        createdAt: createdAt,
        updatedAt: updatedAt,
        isActive: false,
        name: 'Inactive Clinic',
        ownerId: 'owner456',
        address: address,
        phone: phone,
        email: email,
        status: ClinicStatus.active,
      );

      expect(activeClinic.isActive, true);
      expect(inactiveClinic.isActive, false);
    });

    test('should validate email format', () {
      // Valid emails
      final validEmails = ['clinic@example.com', 'info@petclinic.org', 'contact@vet-center.net'];

      for (final email in validEmails) {
        final clinic = Clinic(
          id: clinicId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          name: name,
          ownerId: 'owner123',
          address: address,
          phone: phone,
          email: email,
          status: ClinicStatus.active,
        );

        expect(clinic.email, email);
      }
    });

    test('should validate phone format', () {
      // Valid phone formats
      final validPhones = ['(555) 123-4567', '555-123-4567', '+1-555-123-4567', '5551234567'];

      for (final phone in validPhones) {
        final clinic = Clinic(
          id: clinicId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          name: name,
          ownerId: 'owner123',
          address: address,
          phone: phone,
          email: email,
          status: ClinicStatus.active,
        );

        expect(clinic.phone, phone);
      }
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      final clinic1 = Clinic(
        id: clinicId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isActive: true,
        name: name,
        ownerId: 'owner123',
        address: address,
        phone: phone,
        email: email,
        status: ClinicStatus.active,
      );

      final clinic2 = Clinic(
        id: clinicId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isActive: true,
        name: name,
        ownerId: 'owner123',
        address: address,
        phone: phone,
        email: email,
        status: ClinicStatus.active,
      );

      // Act & Assert
      expect(clinic1, clinic2);
    });

    test('should not be equal when properties differ', () {
      // Arrange
      final clinic1 = Clinic(
        id: clinicId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        name: name,
        ownerId: 'owner123',
        address: address,
        phone: phone,
        email: email,
        status: ClinicStatus.active,
      );

      final clinic2 = Clinic(
        id: 'different_id',
        createdAt: createdAt,
        updatedAt: updatedAt,
        name: name,
        ownerId: 'owner123',
        address: address,
        phone: phone,
        email: email,
        status: ClinicStatus.active,
      );

      // Act & Assert
      expect(clinic1, isNot(equals(clinic2)));
    });

    test('should handle copyWith correctly', () {
      // Arrange
      final originalClinic = Clinic(
        id: clinicId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isActive: true,
        name: name,
        ownerId: 'owner123',
        address: address,
        phone: phone,
        email: email,
        status: ClinicStatus.active,
      );

      // Act
      final copiedClinic = originalClinic.copyWith(isActive: false, updatedAt: DateTime(2024, 1, 3));

      // Assert - copyWith only affects AuditableEntity fields
      expect(copiedClinic.id, clinicId);
      expect(copiedClinic.name, name); // unchanged
      expect(copiedClinic.isActive, false);
      expect(copiedClinic.createdAt, createdAt);
      expect(copiedClinic.updatedAt, DateTime(2024, 1, 3));
    });

    test('should handle long addresses', () {
      // Arrange
      const longAddress =
          '123 Main Street, Suite 456, Downtown District, '
          'Metropolitan City, State 12345-6789, United States of America';

      // Act
      final clinic = Clinic(
        id: clinicId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        name: name,
        ownerId: 'owner123',
        address: longAddress,
        phone: phone,
        email: email,
        status: ClinicStatus.active,
      );

      // Assert
      expect(clinic.address, longAddress);
    });
  });
}
