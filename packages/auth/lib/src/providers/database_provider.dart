import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

enum DatabaseStatus { initial, loading, success, error }

class DatabaseProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;

  DatabaseStatus _status = DatabaseStatus.initial;
  String? _errorMessage;

  DatabaseProvider({FirestoreService? firestoreService, FirebaseAuth? auth})
    : _firestoreService = firestoreService ?? FirestoreService(),
      _auth = auth ?? FirebaseAuth.instance;

  DatabaseStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _auth.currentUser?.uid;

  void _setLoading() {
    _status = DatabaseStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = DatabaseStatus.success;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = DatabaseStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Initialize user profile after signup
  Future<void> initializeUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      _setError('No authenticated user found');
      return;
    }

    try {
      _setLoading();
      await _firestoreService.createUserProfile(
        user,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        address: address,
      );
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to initialize user profile');
    }
  }

  /// Update current user profile
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final userId = currentUserId;
    if (userId == null) {
      _setError('No authenticated user found');
      return;
    }

    try {
      _setLoading();
      await _firestoreService.updateUserProfile(userId, updates);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to update user profile');
    }
  }

  /// Get clinics list
  Future<List<dynamic>> getClinics({int limit = 20}) async {
    try {
      _setLoading();
      final clinics = await _firestoreService.getClinics(limit: limit);
      _setSuccess();
      return clinics;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load clinics');
      return [];
    }
  }

  /// Get current user's pets
  Future<List<dynamic>> getUserPets() async {
    final userId = currentUserId;
    if (userId == null) {
      _setError('No authenticated user found');
      return [];
    }

    try {
      _setLoading();
      final pets = await _firestoreService.getUserPets(userId);
      _setSuccess();
      return pets;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load pets');
      return [];
    }
  }

  /// Create a new pet
  Future<void> createPet(dynamic pet) async {
    try {
      _setLoading();
      await _firestoreService.createPet(pet);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to create pet');
    }
  }

  /// Update pet
  Future<void> updatePet(String petId, Map<String, dynamic> updates) async {
    try {
      _setLoading();
      await _firestoreService.updatePet(petId, updates);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to update pet');
    }
  }

  /// Get user appointments
  Future<List<dynamic>> getUserAppointments({bool upcomingOnly = false}) async {
    final userId = currentUserId;
    if (userId == null) {
      _setError('No authenticated user found');
      return [];
    }

    try {
      _setLoading();
      final appointments = await _firestoreService.getUserAppointments(userId, upcomingOnly: upcomingOnly);
      _setSuccess();
      return appointments;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load appointments');
      return [];
    }
  }

  /// Get clinic appointments (for staff)
  Future<List<dynamic>> getClinicAppointments(String clinicId, {DateTime? date, int limit = 50}) async {
    try {
      _setLoading();
      final appointments = await _firestoreService.getClinicAppointments(clinicId, date: date, limit: limit);
      _setSuccess();
      return appointments;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load clinic appointments');
      return [];
    }
  }

  /// Create appointment
  Future<String?> createAppointment(dynamic appointment) async {
    try {
      _setLoading();
      await _firestoreService.createAppointment(appointment);
      _setSuccess();
      return appointment.id; // Return appointment ID for navigation
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to create appointment');
      return null;
    }
  }

  /// Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      _setLoading();
      await _firestoreService.updateAppointment(appointmentId, {'status': status});
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to update appointment status');
    }
  }

  /// Cancel appointment
  Future<void> cancelAppointment(String appointmentId, {String? reason}) async {
    try {
      _setLoading();
      final updates = {'status': 'cancelled', if (reason != null) 'notes': reason};
      await _firestoreService.updateAppointment(appointmentId, updates);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to cancel appointment');
    }
  }

  /// Get available time slots for a clinic and date
  Future<List<Map<String, dynamic>>> getAvailableSlots(String clinicId, DateTime date) async {
    try {
      _setLoading();

      // Get clinic appointments for the date
      final appointments = await _firestoreService.getClinicAppointments(clinicId, date: date);

      // Generate time slots (assuming 9 AM - 5 PM, 30-minute slots)
      final slots = <Map<String, dynamic>>[];
      final startHour = 9;
      final endHour = 17;
      final slotDuration = 30; // minutes

      for (var hour = startHour; hour < endHour; hour++) {
        for (var minute = 0; minute < 60; minute += slotDuration) {
          final slotStart = DateTime(date.year, date.month, date.day, hour, minute);
          final slotEnd = slotStart.add(Duration(minutes: slotDuration));

          // Check if slot conflicts with existing appointments
          final hasConflict = appointments.any((appointment) {
            final appointmentEnd = appointment.scheduledDate.add(Duration(minutes: appointment.durationMinutes));
            return slotStart.isBefore(appointmentEnd) && slotEnd.isAfter(appointment.scheduledDate);
          });

          if (!hasConflict && slotStart.isAfter(DateTime.now())) {
            slots.add({'startTime': slotStart, 'endTime': slotEnd, 'isAvailable': true, 'clinicId': clinicId});
          }
        }
      }

      _setSuccess();
      return slots;
    } catch (e) {
      _setError('Failed to get available slots');
      return [];
    }
  }

  /// Check if a time slot is available
  Future<bool> isSlotAvailable(String clinicId, DateTime startTime, int durationMinutes) async {
    try {
      final endTime = startTime.add(Duration(minutes: durationMinutes));
      final appointments = await _firestoreService.getClinicAppointments(
        clinicId,
        date: DateTime(startTime.year, startTime.month, startTime.day),
      );

      // Check for conflicts
      final hasConflict = appointments.any((appointment) {
        final appointmentEnd = appointment.scheduledDate.add(Duration(minutes: appointment.durationMinutes));
        return startTime.isBefore(appointmentEnd) && endTime.isAfter(appointment.scheduledDate);
      });

      return !hasConflict;
    } catch (e) {
      return false;
    }
  }

  /// Stream user profile
  Stream<dynamic> watchUserProfile(String userId) {
    return _firestoreService.watchUserProfile(userId);
  }

  /// Stream user pets
  Stream<List<dynamic>> watchUserPets() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }
    return _firestoreService.watchUserPets(userId);
  }

  /// Stream clinic appointments (for staff)
  Stream<List<dynamic>> watchClinicAppointments(String clinicId) {
    return _firestoreService.watchClinicAppointments(clinicId);
  }

  /// Get medical records for current user's pet
  Future<List<dynamic>> getPetMedicalRecords(String petId) async {
    try {
      _setLoading();
      final records = await _firestoreService.getPetMedicalRecords(petId);
      _setSuccess();
      return records;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load medical records');
      return [];
    }
  }

  /// Get medical record by ID
  Future<dynamic> getMedicalRecord(String recordId) async {
    try {
      _setLoading();
      final record = await _firestoreService.getMedicalRecord(recordId);
      _setSuccess();
      return record;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to load medical record');
      return null;
    }
  }

  /// Create medical record
  Future<String?> createMedicalRecord(dynamic medicalRecord) async {
    try {
      _setLoading();
      final recordId = await _firestoreService.createMedicalRecord(medicalRecord);
      _setSuccess();
      return recordId;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to create medical record');
      return null;
    }
  }

  /// Update medical record
  Future<void> updateMedicalRecord(String recordId, Map<String, dynamic> updates) async {
    try {
      _setLoading();
      await _firestoreService.updateMedicalRecord(recordId, updates);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to update medical record');
    }
  }

  /// Get prescriptions for a medical record
  Future<List<dynamic>> getPrescriptions(String medicalRecordId) async {
    try {
      _setLoading();
      final prescriptions = await _firestoreService.getPrescriptions(medicalRecordId);
      _setSuccess();
      return prescriptions;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load prescriptions');
      return [];
    }
  }

  /// Create prescription
  Future<String?> createPrescription(dynamic prescription) async {
    try {
      _setLoading();
      final prescriptionId = await _firestoreService.createPrescription(prescription);
      _setSuccess();
      return prescriptionId;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to create prescription');
      return null;
    }
  }

  /// Get vaccination records for a pet
  Future<List<dynamic>> getPetVaccinations(String petId) async {
    try {
      _setLoading();
      final vaccinations = await _firestoreService.getPetVaccinations(petId);
      _setSuccess();
      return vaccinations;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load vaccinations');
      return [];
    }
  }

  /// Create vaccination record
  Future<String?> createVaccination(dynamic vaccination) async {
    try {
      _setLoading();
      final vaccinationId = await _firestoreService.createVaccination(vaccination);
      _setSuccess();
      return vaccinationId;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to create vaccination');
      return null;
    }
  }

  /// Get clinic medical records (for staff)
  Future<List<dynamic>> getClinicMedicalRecords(String clinicId, {DateTime? date, int limit = 50}) async {
    try {
      _setLoading();
      final records = await _firestoreService.getClinicMedicalRecords(clinicId, date: date, limit: limit);
      _setSuccess();
      return records;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load clinic medical records');
      return [];
    }
  }

  /// Stream pet medical records
  Stream<List<dynamic>> watchPetMedicalRecords(String petId) {
    return _firestoreService.watchPetMedicalRecords(petId);
  }

  /// Stream clinic medical records
  Stream<List<dynamic>> watchClinicMedicalRecords(String clinicId) {
    return _firestoreService.watchClinicMedicalRecords(clinicId);
  }

  /// Get user's pets
  Future<List<dynamic>> getUserPets() async {
    try {
      _setLoading();
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _setError('User not authenticated');
        return [];
      }

      final pets = await _firestoreService.getUserPets(userId);
      _setSuccess();
      return pets;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load pets');
      return [];
    }
  }

  /// Get pet by ID
  Future<dynamic> getPet(String petId) async {
    try {
      _setLoading();
      final pet = await _firestoreService.getPet(petId);
      _setSuccess();
      return pet;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to load pet');
      return null;
    }
  }

  /// Create pet
  Future<String?> createPet(dynamic pet) async {
    try {
      _setLoading();
      final petId = await _firestoreService.createPet(pet);
      _setSuccess();
      return petId;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to create pet');
      return null;
    }
  }

  /// Update pet
  Future<void> updatePet(String petId, Map<String, dynamic> updates) async {
    try {
      _setLoading();
      await _firestoreService.updatePet(petId, updates);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to update pet');
    }
  }

  /// Delete pet
  Future<void> deletePet(String petId) async {
    try {
      _setLoading();
      await _firestoreService.deletePet(petId);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to delete pet');
    }
  }

  /// Stream user pets
  Stream<List<dynamic>> watchUserPets() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }
    return _firestoreService.watchUserPets(userId);
  }

  /// Get pet medical summary
  Future<dynamic> getPetMedicalSummary(String petId) async {
    try {
      _setLoading();
      final summary = await _firestoreService.getPetMedicalSummary(petId);
      _setSuccess();
      return summary;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to load medical summary');
      return null;
    }
  }

  /// Get all clinics (admin)
  Future<List<dynamic>> getAllClinics() async {
    try {
      _setLoading();
      final clinics = await _firestoreService.getAllClinics();
      _setSuccess();
      return clinics;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load clinics');
      return [];
    }
  }

  /// Get clinic by ID
  Future<dynamic> getClinic(String clinicId) async {
    try {
      _setLoading();
      final clinic = await _firestoreService.getClinic(clinicId);
      _setSuccess();
      return clinic;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to load clinic');
      return null;
    }
  }

  /// Create clinic
  Future<String?> createClinic(dynamic clinic) async {
    try {
      _setLoading();
      final clinicId = await _firestoreService.createClinic(clinic);
      _setSuccess();
      return clinicId;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to create clinic');
      return null;
    }
  }

  /// Update clinic
  Future<void> updateClinic(String clinicId, Map<String, dynamic> updates) async {
    try {
      _setLoading();
      await _firestoreService.updateClinic(clinicId, updates);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to update clinic');
    }
  }

  /// Delete clinic
  Future<void> deleteClinic(String clinicId) async {
    try {
      _setLoading();
      await _firestoreService.deleteClinic(clinicId);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to delete clinic');
    }
  }

  /// Get clinic services
  Future<List<dynamic>> getClinicServices(String clinicId) async {
    try {
      _setLoading();
      final services = await _firestoreService.getClinicServices(clinicId);
      _setSuccess();
      return services;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load clinic services');
      return [];
    }
  }

  /// Create clinic service
  Future<String?> createClinicService(dynamic service) async {
    try {
      _setLoading();
      final serviceId = await _firestoreService.createClinicService(service);
      _setSuccess();
      return serviceId;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to create clinic service');
      return null;
    }
  }

  /// Update clinic service
  Future<void> updateClinicService(String serviceId, Map<String, dynamic> updates) async {
    try {
      _setLoading();
      await _firestoreService.updateClinicService(serviceId, updates);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to update clinic service');
    }
  }

  /// Delete clinic service
  Future<void> deleteClinicService(String serviceId) async {
    try {
      _setLoading();
      await _firestoreService.deleteClinicService(serviceId);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to delete clinic service');
    }
  }

  /// Get clinic staff
  Future<List<dynamic>> getClinicStaff(String clinicId) async {
    try {
      _setLoading();
      final staff = await _firestoreService.getClinicStaff(clinicId);
      _setSuccess();
      return staff;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load clinic staff');
      return [];
    }
  }

  /// Add staff to clinic
  Future<String?> addClinicStaff(dynamic staff) async {
    try {
      _setLoading();
      final staffId = await _firestoreService.addClinicStaff(staff);
      _setSuccess();
      return staffId;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to add clinic staff');
      return null;
    }
  }

  /// Update clinic staff
  Future<void> updateClinicStaff(String staffId, Map<String, dynamic> updates) async {
    try {
      _setLoading();
      await _firestoreService.updateClinicStaff(staffId, updates);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to update clinic staff');
    }
  }

  /// Remove clinic staff
  Future<void> removeClinicStaff(String staffId) async {
    try {
      _setLoading();
      await _firestoreService.removeClinicStaff(staffId);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to remove clinic staff');
    }
  }

  /// Get clinic analytics
  Future<Map<String, dynamic>> getClinicAnalytics(String clinicId) async {
    try {
      _setLoading();
      final analytics = await _firestoreService.getClinicAnalytics(clinicId);
      _setSuccess();
      return analytics;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return {};
    } catch (e) {
      _setError('Failed to load clinic analytics');
      return {};
    }
  }

  /// Generate invoice number
  Future<String> generateInvoiceNumber(String clinicId) async {
    try {
      _setLoading();
      final invoiceNumber = await _firestoreService.generateInvoiceNumber(clinicId);
      _setSuccess();
      return invoiceNumber;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return '';
    } catch (e) {
      _setError('Failed to generate invoice number');
      return '';
    }
  }

  /// Get invoices for current user
  Future<List<dynamic>> getUserInvoices() async {
    try {
      _setLoading();
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _setError('User not authenticated');
        return [];
      }

      final invoices = await _firestoreService.getCustomerInvoices(userId);
      _setSuccess();
      return invoices;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load invoices');
      return [];
    }
  }

  /// Get clinic invoices
  Future<List<dynamic>> getClinicInvoices(String clinicId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      _setLoading();
      final invoices = await _firestoreService.getClinicInvoices(clinicId, startDate: startDate, endDate: endDate);
      _setSuccess();
      return invoices;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load clinic invoices');
      return [];
    }
  }

  /// Get invoice by ID
  Future<dynamic> getInvoice(String invoiceId) async {
    try {
      _setLoading();
      final invoice = await _firestoreService.getInvoice(invoiceId);
      _setSuccess();
      return invoice;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to load invoice');
      return null;
    }
  }

  /// Create invoice
  Future<String?> createInvoice(dynamic invoice) async {
    try {
      _setLoading();
      final invoiceId = await _firestoreService.createInvoice(invoice);
      _setSuccess();
      return invoiceId;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to create invoice');
      return null;
    }
  }

  /// Update invoice
  Future<void> updateInvoice(String invoiceId, Map<String, dynamic> updates) async {
    try {
      _setLoading();
      await _firestoreService.updateInvoice(invoiceId, updates);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to update invoice');
    }
  }

  /// Delete invoice
  Future<void> deleteInvoice(String invoiceId) async {
    try {
      _setLoading();
      await _firestoreService.deleteInvoice(invoiceId);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to delete invoice');
    }
  }

  /// Get payments for an invoice
  Future<List<dynamic>> getInvoicePayments(String invoiceId) async {
    try {
      _setLoading();
      final payments = await _firestoreService.getInvoicePayments(invoiceId);
      _setSuccess();
      return payments;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load invoice payments');
      return [];
    }
  }

  /// Get payments for current user
  Future<List<dynamic>> getUserPayments() async {
    try {
      _setLoading();
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _setError('User not authenticated');
        return [];
      }

      final payments = await _firestoreService.getCustomerPayments(userId);
      _setSuccess();
      return payments;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load payments');
      return [];
    }
  }

  /// Create payment
  Future<String?> createPayment(dynamic payment) async {
    try {
      _setLoading();
      final paymentId = await _firestoreService.createPayment(payment);
      _setSuccess();
      return paymentId;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to create payment');
      return null;
    }
  }

  /// Process payment
  Future<void> processPayment(String paymentId) async {
    try {
      _setLoading();
      await _firestoreService.processPayment(paymentId);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to process payment');
    }
  }

  /// Get billing analytics for clinic
  Future<Map<String, dynamic>> getClinicBillingAnalytics(
    String clinicId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _setLoading();
      final analytics = await _firestoreService.getClinicBillingAnalytics(
        clinicId,
        startDate: startDate,
        endDate: endDate,
      );
      _setSuccess();
      return analytics;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return {};
    } catch (e) {
      _setError('Failed to load billing analytics');
      return {};
    }
  }

  /// Get user profile
  Future<dynamic?> getUserProfile(String userId) async {
    try {
      _setLoading();
      final profile = await _firestoreService.getUserProfile(userId);
      _setSuccess();
      return profile;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to load user profile');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      _setLoading();
      await _firestoreService.updateUserProfile(userId, updates);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to update user profile');
    }
  }

  /// Get current user profile
  Future<dynamic?> getCurrentUserProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _setError('User not authenticated');
      return null;
    }
    return getUserProfile(userId);
  }

  /// Update current user profile
  Future<void> updateCurrentUserProfile(Map<String, dynamic> updates) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _setError('User not authenticated');
      return;
    }
    return updateUserProfile(userId, updates);
  }

  /// Get all users (admin only)
  Future<List<dynamic>> getAllUsers({int limit = 50, dynamic startAfter}) async {
    try {
      _setLoading();
      final users = await _firestoreService.getAllUsers(limit: limit, startAfter: startAfter);
      _setSuccess();
      return users;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load users');
      return [];
    }
  }

  /// Get clinic users
  Future<List<dynamic>> getClinicUsers(String clinicId) async {
    try {
      _setLoading();
      final users = await _firestoreService.getClinicUsers(clinicId);
      _setSuccess();
      return users;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load clinic users');
      return [];
    }
  }

  /// Update user role
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      _setLoading();
      await _firestoreService.updateUserRole(userId, newRole);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to update user role');
    }
  }

  /// Deactivate user
  Future<void> deactivateUser(String userId) async {
    try {
      _setLoading();
      await _firestoreService.deactivateUser(userId);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to deactivate user');
    }
  }

  /// Reactivate user
  Future<void> reactivateUser(String userId) async {
    try {
      _setLoading();
      await _firestoreService.reactivateUser(userId);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to reactivate user');
    }
  }

  /// Log user activity
  Future<String?> logUserActivity(dynamic activity) async {
    try {
      _setLoading();
      final activityId = await _firestoreService.logUserActivity(activity);
      _setSuccess();
      return activityId;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to log user activity');
      return null;
    }
  }

  /// Get user activities
  Future<List<dynamic>> getUserActivities(String userId, {int limit = 20, dynamic startAfter}) async {
    try {
      _setLoading();
      final activities = await _firestoreService.getUserActivities(userId, limit: limit, startAfter: startAfter);
      _setSuccess();
      return activities;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return [];
    } catch (e) {
      _setError('Failed to load user activities');
      return [];
    }
  }

  /// Get notification preferences
  Future<dynamic?> getNotificationPreferences(String userId) async {
    try {
      _setLoading();
      final preferences = await _firestoreService.getNotificationPreferences(userId);
      _setSuccess();
      return preferences;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to load notification preferences');
      return null;
    }
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences(String userId, Map<String, dynamic> updates) async {
    try {
      _setLoading();
      await _firestoreService.updateNotificationPreferences(userId, updates);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to update notification preferences');
    }
  }

  /// Get current user notification preferences
  Future<dynamic?> getCurrentUserNotificationPreferences() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _setError('User not authenticated');
      return null;
    }
    return getNotificationPreferences(userId);
  }

  /// Update current user notification preferences
  Future<void> updateCurrentUserNotificationPreferences(Map<String, dynamic> updates) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _setError('User not authenticated');
      return;
    }
    return updateNotificationPreferences(userId, updates);
  }

  /// Create password reset token
  Future<String?> createPasswordResetToken(dynamic token) async {
    try {
      _setLoading();
      final tokenId = await _firestoreService.createPasswordResetToken(token);
      _setSuccess();
      return tokenId;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to create password reset token');
      return null;
    }
  }

  /// Verify password reset token
  Future<dynamic?> verifyPasswordResetToken(String token) async {
    try {
      _setLoading();
      final tokenData = await _firestoreService.verifyPasswordResetToken(token);
      _setSuccess();
      return tokenData;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to verify password reset token');
      return null;
    }
  }

  /// Use password reset token
  Future<void> usePasswordResetToken(String tokenId) async {
    try {
      _setLoading();
      await _firestoreService.usePasswordResetToken(tokenId);
      _setSuccess();
    } on FirestoreException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to use password reset token');
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      _setLoading();
      final statistics = await _firestoreService.getUserStatistics();
      _setSuccess();
      return statistics;
    } on FirestoreException catch (e) {
      _setError(e.message);
      return {};
    } catch (e) {
      _setError('Failed to load user statistics');
      return {};
    }
  }
}
