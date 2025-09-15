import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/appointment.dart';

/// Repository interface for appointment operations
abstract class AppointmentRepository {
  /// Get all appointments with optional filters
  Future<Either<Failure, List<Appointment>>> getAppointments({
    String? clinicId,
    String? userId,
    DateTime? date,
    bool? upcomingOnly,
    int? limit,
  });

  /// Create a new appointment
  Future<Either<Failure, String>> createAppointment(Appointment appointment);

  /// Update appointment status
  Future<Either<Failure, void>> updateAppointmentStatus(String appointmentId, AppointmentStatus status);

  /// Cancel an appointment
  Future<Either<Failure, void>> cancelAppointment(String appointmentId, {String? reason});

  /// Get available time slots for a clinic on a specific date
  Future<Either<Failure, List<Map<String, dynamic>>>> getAvailableSlots(String clinicId, DateTime date);

  /// Check if a time slot is available
  Future<Either<Failure, bool>> isSlotAvailable(String clinicId, DateTime startTime, int durationMinutes);
}
