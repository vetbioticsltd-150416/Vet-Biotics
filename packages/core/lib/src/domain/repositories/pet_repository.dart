import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/pet.dart';

/// Repository interface for pet operations
abstract class PetRepository {
  /// Get pets with optional filters
  Future<Either<Failure, List<Pet>>> getPets({String? ownerId, int? limit});
}
