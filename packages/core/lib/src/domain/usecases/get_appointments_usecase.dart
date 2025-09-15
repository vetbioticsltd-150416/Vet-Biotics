import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class GetAppointmentsUseCase {
  final AppointmentRepository repository;

  GetAppointmentsUseCase(this.repository);

  Future<Either<Failure, List<Appointment>>> call({
    String? clinicId,
    String? userId,
    DateTime? date,
    bool? upcomingOnly,
    int? limit,
  }) => repository.getAppointments(
    clinicId: clinicId,
    userId: userId,
    date: date,
    upcomingOnly: upcomingOnly,
    limit: limit,
  );
}
