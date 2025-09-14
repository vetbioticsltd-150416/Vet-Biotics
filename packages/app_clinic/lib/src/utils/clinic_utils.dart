import 'package:vet_biotics_core/core.dart';

class ClinicUtils {
  static String formatAppointmentStatus(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }

  static String formatBillingStatus(BillingStatus status) {
    switch (status) {
      case BillingStatus.pending:
        return 'Pending';
      case BillingStatus.paid:
        return 'Paid';
      case BillingStatus.overdue:
        return 'Overdue';
      case BillingStatus.cancelled:
        return 'Cancelled';
    }
  }

  static String formatGender(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
    }
  }

  static String getAppointmentStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return '#FFC107'; // Warning yellow
      case AppointmentStatus.confirmed:
        return '#2196F3'; // Primary blue
      case AppointmentStatus.inProgress:
        return '#FF9800'; // Accent orange
      case AppointmentStatus.completed:
        return '#4CAF50'; // Success green
      case AppointmentStatus.cancelled:
        return '#F44336'; // Error red
      case AppointmentStatus.noShow:
        return '#9E9E9E'; // Grey
    }
  }

  static String getBillingStatusColor(BillingStatus status) {
    switch (status) {
      case BillingStatus.pending:
        return '#FFC107'; // Warning yellow
      case BillingStatus.paid:
        return '#4CAF50'; // Success green
      case BillingStatus.overdue:
        return '#F44336'; // Error red
      case BillingStatus.cancelled:
        return '#9E9E9E'; // Grey
    }
  }

  static String calculatePatientAge(DateTime birthDate) {
    final now = DateTime.now();
    final age = now.difference(birthDate);

    final years = age.inDays ~/ 365;
    final months = (age.inDays % 365) ~/ 30;
    final days = age.inDays % 30;

    if (years > 0) {
      return '$years year${years > 1 ? 's' : ''} old';
    } else if (months > 0) {
      return '$months month${months > 1 ? 's' : ''} old';
    } else {
      return '$days day${days > 1 ? 's' : ''} old';
    }
  }

  static double calculateTotalRevenue(List<Billing> billings) {
    return billings
        .where((billing) => billing.status == BillingStatus.paid)
        .fold(0.0, (sum, billing) => sum + billing.totalAmount);
  }

  static int getPendingAppointmentsCount(List<Appointment> appointments) {
    return appointments.where((appointment) => appointment.status == AppointmentStatus.pending).length;
  }

  static int getTodayAppointmentsCount(List<Appointment> appointments) {
    final today = DateTime.now();
    return appointments.where((appointment) {
      return appointment.dateTime.year == today.year &&
          appointment.dateTime.month == today.month &&
          appointment.dateTime.day == today.day;
    }).length;
  }

  static List<Appointment> getTodayAppointments(List<Appointment> appointments) {
    final today = DateTime.now();
    return appointments.where((appointment) {
      return appointment.dateTime.year == today.year &&
          appointment.dateTime.month == today.month &&
          appointment.dateTime.day == today.day;
    }).toList();
  }

  static List<Appointment> getUpcomingAppointments(List<Appointment> appointments) {
    final now = DateTime.now();
    return appointments.where((appointment) => appointment.dateTime.isAfter(now)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  static List<MedicalRecord> getRecentMedicalRecords(List<MedicalRecord> records, {int limit = 10}) {
    return records
      ..sort((a, b) => b.date.compareTo(a.date))
      ..take(limit).toList();
  }

  static List<InventoryItem> getLowStockItems(List<InventoryItem> items) {
    return items.where((item) => item.currentStock <= item.minStockLevel).toList();
  }

  static double calculateInventoryValue(List<InventoryItem> items) {
    return items.fold(0.0, (sum, item) => sum + (item.currentStock * item.unitPrice));
  }

  static Map<String, int> getAppointmentsByStatus(List<Appointment> appointments) {
    final statusCount = <String, int>{};

    for (final appointment in appointments) {
      final status = formatAppointmentStatus(appointment.status);
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }

    return statusCount;
  }

  static Map<String, double> getRevenueByMonth(List<Billing> billings, int year) {
    final monthlyRevenue = <String, double>{};

    for (final billing in billings) {
      if (billing.status == BillingStatus.paid && billing.date.year == year) {
        final monthKey = '${billing.date.month.toString().padLeft(2, '0')}/${year.toString().substring(2)}';
        monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0) + billing.totalAmount;
      }
    }

    return monthlyRevenue;
  }

  static String generateAppointmentId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'APT_$timestamp';
  }

  static String generateMedicalRecordId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'MED_$timestamp';
  }

  static String generateBillingId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'BILL_$timestamp';
  }

  static String generateInventoryId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'INV_$timestamp';
  }

  static bool isAppointmentToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day;
  }

  static bool isAppointmentPast(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.isBefore(now);
  }

  static bool isAppointmentUpcoming(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.isAfter(now);
  }

  static Duration calculateAppointmentDuration(Appointment appointment) {
    // This would be calculated based on appointment type or stored duration
    // For now, return a default duration
    return const Duration(minutes: 30);
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes min';
    }
  }

  static List<String> getAppointmentTypes() {
    return [
      'General Check-up',
      'Vaccination',
      'Dental Care',
      'Surgery',
      'Emergency',
      'Grooming',
      'Consultation',
      'Follow-up',
    ];
  }

  static List<String> getMedicalRecordTypes() {
    return ['Check-up', 'Vaccination', 'Surgery', 'Emergency', 'Dental', 'Grooming', 'Consultation', 'Laboratory'];
  }

  static List<String> getInventoryCategories() {
    return ['Medications', 'Vaccines', 'Equipment', 'Supplies', 'Food', 'Treats', 'Other'];
  }

  static List<String> getStaffRoles() {
    return ['Veterinarian', 'Vet Assistant', 'Receptionist', 'Groomer', 'Manager', 'Admin'];
  }
}
