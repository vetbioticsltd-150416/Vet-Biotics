import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/medical_record.dart';
import '../repositories/medical_repository.dart';

class CreateMedicalRecordUseCase {
  final MedicalRepository repository;

  CreateMedicalRecordUseCase(this.repository);

  Future<Either<Failure, String>> call(MedicalRecord medicalRecord) async =>
      await repository.createMedicalRecord(medicalRecord);
}
