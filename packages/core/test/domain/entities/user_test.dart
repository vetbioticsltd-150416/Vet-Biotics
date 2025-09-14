import 'package:flutter_test/flutter_test.dart';
import 'package:vet_biotics_core/core.dart';

void main() {
  group('User Entity', () {
    const userId = 'user_123';
    const email = 'test@example.com';
    const firstName = 'John';
    const lastName = 'Doe';
    const clinicId = 'clinic_456';
    final createdAt = DateTime(2024, 1, 1);
    final updatedAt = DateTime(2024, 1, 2);

    test('should create User with all required fields', () {
      // Arrange & Act
      final user = User(
        id: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: UserRole.client,
        isActive: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Assert
      expect(user.id, userId);
      expect(user.email, email);
      expect(user.firstName, firstName);
      expect(user.lastName, lastName);
      expect(user.role, UserRole.client);
      expect(user.isActive, true);
      expect(user.createdAt, createdAt);
      expect(user.updatedAt, updatedAt);
      expect(user.clinicId, isNull);
    });

    test('should create User with clinicId', () {
      // Arrange & Act
      final user = User(
        id: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: UserRole.veterinarian,
        clinicId: clinicId,
        isActive: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Assert
      expect(user.clinicId, clinicId);
      expect(user.role, UserRole.veterinarian);
    });

    test('should create User with default isActive = true', () {
      // Arrange & Act
      final user = User(
        id: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: UserRole.client,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Assert
      expect(user.isActive, true);
    });

    test('should support all UserRole values', () {
      // Test all user roles
      final roles = [
        UserRole.superAdmin,
        UserRole.clinicAdmin,
        UserRole.veterinarian,
        UserRole.receptionist,
        UserRole.client,
      ];

      for (final role in roles) {
        final user = User(
          id: userId,
          email: email,
          firstName: firstName,
          lastName: lastName,
          role: role,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(user.role, role);
      }
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      final user1 = User(
        id: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: UserRole.client,
        clinicId: clinicId,
        isActive: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final user2 = User(
        id: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: UserRole.client,
        clinicId: clinicId,
        isActive: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Act & Assert
      expect(user1, user2);
    });

    test('should not be equal when properties differ', () {
      // Arrange
      final user1 = User(
        id: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: UserRole.client,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final user2 = User(
        id: 'different_id',
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: UserRole.client,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Act & Assert
      expect(user1, isNot(equals(user2)));
    });

    test('should have correct fullName getter', () {
      // Arrange
      final user = User(
        id: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: UserRole.client,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Act & Assert
      expect(user.fullName, '$firstName $lastName');
    });

    test('should handle copyWith correctly', () {
      // Arrange
      final originalUser = User(
        id: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: UserRole.client,
        clinicId: clinicId,
        isActive: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Act
      final copiedUser = originalUser.copyWith(email: 'newemail@example.com', isActive: false);

      // Assert
      expect(copiedUser.id, userId);
      expect(copiedUser.email, 'newemail@example.com');
      expect(copiedUser.firstName, firstName);
      expect(copiedUser.lastName, lastName);
      expect(copiedUser.role, UserRole.client);
      expect(copiedUser.clinicId, clinicId);
      expect(copiedUser.isActive, false);
      expect(copiedUser.createdAt, createdAt);
      expect(copiedUser.updatedAt, updatedAt);
    });
  });
}
