import 'package:flutter_test/flutter_test.dart';
import 'package:vet_biotics_core/core.dart';

void main() {
  group('Pet Entity', () {
    const petId = 'pet_123';
    const name = 'Max';
    const ownerId = 'user_456';
    const breed = 'Golden Retriever';
    const color = 'Golden';
    const microchipNumber = '123456789012345';
    const notes = 'Friendly and energetic';
    final birthDate = DateTime(2020, 5, 15);
    final createdAt = DateTime(2024, 1, 1);
    final updatedAt = DateTime(2024, 1, 2);

    test('should create Pet with all required fields', () {
      // Arrange & Act
      final pet = Pet(
        id: petId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isActive: true,
        name: name,
        ownerId: ownerId,
        species: PetSpecies.dog,
        breed: breed,
        gender: PetGender.male,
        color: color,
        dateOfBirth: birthDate,
        weight: 25.5,
      );

      // Assert
      expect(pet.id, petId);
      expect(pet.name, name);
      expect(pet.ownerId, ownerId);
      expect(pet.species, PetSpecies.dog);
      expect(pet.breed, breed);
      expect(pet.gender, PetGender.male);
      expect(pet.color, color);
      expect(pet.dateOfBirth, birthDate);
      expect(pet.weight, 25.5);
      expect(pet.isActive, true);
      expect(pet.createdAt, createdAt);
      expect(pet.updatedAt, updatedAt);
    });

    test('should create Pet with optional fields', () {
      // Arrange & Act
      final pet = Pet(
        id: petId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isActive: true,
        name: name,
        ownerId: ownerId,
        species: PetSpecies.cat,
        breed: breed,
        gender: PetGender.female,
        color: color,
        dateOfBirth: birthDate,
        microchipId: microchipNumber,
        weight: 4.2,
      );

      // Assert
      expect(pet.microchipId, microchipNumber);
      expect(pet.notes, notes);
    });

    test('should create Pet with default isActive = true', () {
      // Arrange & Act
      final pet = Pet(
        id: petId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        name: name,
        ownerId: ownerId,
        species: PetSpecies.dog,
        breed: breed,
        gender: PetGender.male,
        color: color,
        dateOfBirth: birthDate,
        weight: 25,
      );

      // Assert
      expect(pet.isActive, true);
    });

    test('should support all PetSpecies values', () {
      // Test all pet species
      final species = [PetSpecies.dog, PetSpecies.cat, PetSpecies.bird, PetSpecies.rabbit, PetSpecies.other];

      for (var spec in species) {
        final pet = Pet(
          id: petId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          name: name,
          ownerId: ownerId,
          species: spec,
          breed: breed,
          gender: PetGender.male,
          color: color,
          dateOfBirth: birthDate,
          weight: 10,
        );

        expect(pet.species, spec);
      }
    });

    test('should support all PetGender values', () {
      // Test all pet genders
      final genders = [PetGender.male, PetGender.female];

      for (var gender in genders) {
        final pet = Pet(
          id: petId,
          name: name,
          ownerId: ownerId,
          species: PetSpecies.dog,
          breed: breed,
          gender: gender,
          color: color,
          dateOfBirth: birthDate,
          weight: 10,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(pet.gender, gender);
      }
    });

    test('should calculate age correctly', () {
      // Arrange
      final birthDate = DateTime(2020, 5, 15);
      final currentDate = DateTime(2024, 5, 15); // Exactly 4 years later

      final pet = Pet(
        id: petId,
        name: name,
        ownerId: ownerId,
        species: PetSpecies.dog,
        breed: breed,
        gender: PetGender.male,
        color: color,
        dateOfBirth: birthDate,
        weight: 25,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Act
      final age = pet.ageInYears;

      // Assert
      expect(age, 4);
    });

    test('should handle weight variations', () {
      // Test different weight ranges
      final weights = [0.5, 2.3, 15.7, 45.2, 100.0];

      for (var weight in weights) {
        final pet = Pet(
          id: petId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          name: name,
          ownerId: ownerId,
          species: PetSpecies.dog,
          breed: breed,
          gender: PetGender.male,
          color: color,
          dateOfBirth: birthDate,
          weight: weight,
        );

        expect(pet.weight, weight);
      }
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      final pet1 = Pet(
        id: petId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isActive: true,
        name: name,
        ownerId: ownerId,
        species: PetSpecies.dog,
        breed: breed,
        gender: PetGender.male,
        color: color,
        dateOfBirth: birthDate,
        microchipId: microchipNumber,
        weight: 25.5,
      );

      final pet2 = Pet(
        id: petId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isActive: true,
        name: name,
        ownerId: ownerId,
        species: PetSpecies.dog,
        breed: breed,
        gender: PetGender.male,
        color: color,
        dateOfBirth: birthDate,
        microchipId: microchipNumber,
        weight: 25.5,
      );

      // Act & Assert
      expect(pet1, pet2);
    });

    test('should not be equal when properties differ', () {
      // Arrange
      final pet1 = Pet(
        id: petId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        name: name,
        ownerId: ownerId,
        species: PetSpecies.dog,
        breed: breed,
        gender: PetGender.male,
        color: color,
        dateOfBirth: birthDate,
        weight: 25,
      );

      final pet2 = Pet(
        id: 'different_id',
        createdAt: createdAt,
        updatedAt: updatedAt,
        name: name,
        ownerId: ownerId,
        species: PetSpecies.dog,
        breed: breed,
        gender: PetGender.male,
        color: color,
        dateOfBirth: birthDate,
        weight: 25,
      );

      // Act & Assert
      expect(pet1, isNot(equals(pet2)));
    });

    test('should handle copyWith correctly', () {
      // Arrange
      final originalPet = Pet(
        id: petId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isActive: true,
        name: name,
        ownerId: ownerId,
        species: PetSpecies.dog,
        breed: breed,
        gender: PetGender.male,
        color: color,
        dateOfBirth: birthDate,
        microchipId: microchipNumber,
        weight: 25.5,
      );

      // Act
      final copiedPet = originalPet.copyWith(isActive: false, updatedAt: DateTime(2024, 1, 3));

      // Assert - copyWith only affects AuditableEntity fields
      expect(copiedPet.id, petId);
      expect(copiedPet.name, name); // unchanged
      expect(copiedPet.isActive, false);
      expect(copiedPet.createdAt, createdAt);
      expect(copiedPet.updatedAt, DateTime(2024, 1, 3));
    });
  });
}
