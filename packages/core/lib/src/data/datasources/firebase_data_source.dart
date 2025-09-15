import '../../domain/entities/appointment.dart';
import '../../domain/entities/clinic.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/entities/pet.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/invoice.dart';

abstract class FirebaseDataSource {
  // Appointments
  Future<List<Appointment>> getAppointments({
    String? clinicId,
    String? userId,
    DateTime? date,
    bool? upcomingOnly,
    int? limit,
  });

  Future<String> createAppointment(Appointment appointment);
  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status);
  Future<void> cancelAppointment(String appointmentId, {String? reason});
  Future<List<Map<String, dynamic>>> getAvailableSlots(String clinicId, DateTime date);
  Future<bool> isSlotAvailable(String clinicId, DateTime startTime, int durationMinutes);

  // Medical Records
  Future<List<MedicalRecord>> getMedicalRecords({String? petId, String? clinicId, DateTime? date, int? limit});

  Future<String> createMedicalRecord(MedicalRecord medicalRecord);
  Future<void> updateMedicalRecord(String recordId, Map<String, dynamic> updates);

  // Pets
  Future<List<Pet>> getPets({String? ownerId, int? limit});
  Future<String> createPet(Pet pet);
  Future<void> updatePet(String petId, Map<String, dynamic> updates);
  Future<void> deletePet(String petId);

  // Clinics
  Future<List<Clinic>> getClinics({int? limit, bool? activeOnly});
  Future<String> createClinic(Clinic clinic);
  Future<void> updateClinic(String clinicId, Map<String, dynamic> updates);
  Future<void> deleteClinic(String clinicId);
  Future<List<User>> getClinicStaff(String clinicId);
  Future<String> addClinicStaff(User staff);
  Future<void> updateClinicStaff(String staffId, Map<String, dynamic> updates);
  Future<void> removeClinicStaff(String staffId);

  // Users
  Future<List<User>> getUsers({int? limit, dynamic startAfter});
  Future<List<User>> getClinicUsers(String clinicId);
  Future<void> updateUserRole(String userId, UserRole newRole);
  Future<void> deactivateUser(String userId);
  Future<void> reactivateUser(String userId);

  // Invoices
  Future<List<Invoice>> getInvoices({String? clinicId, DateTime? startDate, DateTime? endDate});
  Future<String> createInvoice(Invoice invoice);
  Future<void> updateInvoice(String invoiceId, Map<String, dynamic> updates);
  Future<void> deleteInvoice(String invoiceId);

  // Analytics
  Future<Map<String, dynamic>> getClinicAnalytics(String clinicId);
  Future<Map<String, dynamic>> getClinicBillingAnalytics(String clinicId, {DateTime? startDate, DateTime? endDate});
  Future<Map<String, dynamic>> getUserStatistics();

  // Real-time streams
  Stream<List<Appointment>> watchClinicAppointments(String clinicId);
  Stream<List<Appointment>> watchUserAppointments(String userId);
  Stream<List<MedicalRecord>> watchPetMedicalRecords(String petId);
  Stream<List<Pet>> watchUserPets(String userId);
}
