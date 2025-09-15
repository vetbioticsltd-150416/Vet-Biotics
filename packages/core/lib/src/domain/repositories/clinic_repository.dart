import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/clinic.dart';

/// Repository interface for clinic operations
abstract class ClinicRepository {
  /// Get clinics with optional filters
  Future<Either<Failure, List<Clinic>>> getClinics({int? limit, bool? activeOnly});
}
