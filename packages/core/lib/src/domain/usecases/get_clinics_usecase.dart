import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/clinic.dart';
import '../repositories/clinic_repository.dart';

class GetClinicsUseCase {
  final ClinicRepository repository;

  GetClinicsUseCase(this.repository);

  Future<Either<Failure, List<Clinic>>> call({int? limit, bool? activeOnly}) async =>
      await repository.getClinics(limit: limit, activeOnly: activeOnly);
}
