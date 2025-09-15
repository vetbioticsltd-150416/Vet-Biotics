import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/pet.dart';
import '../repositories/pet_repository.dart';

class GetPetsUseCase {
  final PetRepository repository;

  GetPetsUseCase(this.repository);

  Future<Either<Failure, List<Pet>>> call({String? ownerId, int? limit}) async =>
      await repository.getPets(ownerId: ownerId, limit: limit);
}
