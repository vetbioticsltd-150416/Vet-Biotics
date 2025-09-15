import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class UpdateAppointmentStatusUseCase {
  final AppointmentRepository repository;

  UpdateAppointmentStatusUseCase(this.repository);

  Future<Either<Failure, void>> call(String appointmentId, AppointmentStatus status) async =>
      await repository.updateAppointmentStatus(appointmentId, status);
}
