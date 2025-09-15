import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/medical_record.dart';

/// Repository interface for medical record operations
abstract class MedicalRepository {
  /// Get medical records with optional filters
  Future<Either<Failure, List<MedicalRecord>>> getMedicalRecords({
    String? petId,
    String? clinicId,
    DateTime? date,
    int? limit,
  });

  /// Create a new medical record
  Future<Either<Failure, String>> createMedicalRecord(MedicalRecord medicalRecord);

  /// Update medical record
  Future<Either<Failure, void>> updateMedicalRecord(String recordId, Map<String, dynamic> updates);
}
