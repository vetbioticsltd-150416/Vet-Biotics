import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/medical_record.dart';
import '../repositories/medical_repository.dart';

class GetMedicalRecordsUseCase {
  final MedicalRepository repository;

  GetMedicalRecordsUseCase(this.repository);

  Future<Either<Failure, List<MedicalRecord>>> call({
    String? petId,
    String? clinicId,
    DateTime? date,
    int? limit,
  }) async => await repository.getMedicalRecords(petId: petId, clinicId: clinicId, date: date, limit: limit);
}
