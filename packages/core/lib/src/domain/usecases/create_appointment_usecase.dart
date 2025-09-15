import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class CreateAppointmentUseCase {
  final AppointmentRepository repository;

  CreateAppointmentUseCase(this.repository);

  Future<Either<Failure, String>> call(Appointment appointment) => repository.createAppointment(appointment);
}
