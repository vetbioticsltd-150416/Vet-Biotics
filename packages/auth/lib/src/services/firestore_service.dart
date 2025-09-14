import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vet_biotics_core/core.dart';

/// Service for Firestore database operations
class FirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  /// Collection references
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _clinics => _firestore.collection('clinics');
  CollectionReference get _clinicServices => _firestore.collection('clinic_services');
  CollectionReference get _clinicStaff => _firestore.collection('clinic_staff');
  CollectionReference get _pets => _firestore.collection('pets');
  CollectionReference get _appointments => _firestore.collection('appointments');
  CollectionReference get _medicalRecords => _firestore.collection('medical_records');
  CollectionReference get _prescriptions => _firestore.collection('prescriptions');
  CollectionReference get _vaccinations => _firestore.collection('vaccinations');
  CollectionReference get _invoices => _firestore.collection('invoices');
  CollectionReference get _payments => _firestore.collection('payments');
  CollectionReference get _userProfiles => _firestore.collection('user_profiles');
  CollectionReference get _userActivities => _firestore.collection('user_activities');
  CollectionReference get _notificationPreferences => _firestore.collection('notification_preferences');
  CollectionReference get _passwordResetTokens => _firestore.collection('password_reset_tokens');

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Create or update user profile in Firestore
  Future<void> createUserProfile(
    User user, {
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    UserRole role = UserRole.client,
    String? clinicId,
  }) async {
    try {
      final userProfile = User(
        id: user.uid,
        email: user.email!,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        address: address,
        role: role,
        clinicId: clinicId,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _users.doc(user.uid).set(userProfile.toJson());
    } catch (e) {
      throw FirestoreException('Failed to create user profile: ${e.toString()}');
    }
  }

  /// Get user profile from Firestore
  Future<User?> getUserProfile(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (doc.exists) {
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw FirestoreException('Failed to get user profile: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _users.doc(userId).update(updates);
    } catch (e) {
      throw FirestoreException('Failed to update user profile: ${e.toString()}');
    }
  }

  /// Get clinics list
  Future<List<Clinic>> getClinics({int limit = 20, DocumentSnapshot? startAfter}) async {
    try {
      Query query = _clinics.where('isActive', isEqualTo: true).orderBy('name').limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Clinic.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get clinics: ${e.toString()}');
    }
  }

  /// Get clinic by ID
  Future<Clinic?> getClinic(String clinicId) async {
    try {
      final doc = await _clinics.doc(clinicId).get();
      if (doc.exists) {
        return Clinic.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw FirestoreException('Failed to get clinic: ${e.toString()}');
    }
  }

  /// Create clinic (Admin only)
  Future<void> createClinic(Clinic clinic) async {
    try {
      await _clinics.doc(clinic.id).set(clinic.toJson());
    } catch (e) {
      throw FirestoreException('Failed to create clinic: ${e.toString()}');
    }
  }

  /// Get user's pets
  Future<List<Pet>> getUserPets(String userId) async {
    try {
      final snapshot = await _pets
          .where('ownerId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => Pet.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get pets: ${e.toString()}');
    }
  }

  /// Get pet by ID
  Future<Pet?> getPet(String petId) async {
    try {
      final doc = await _pets.doc(petId).get();
      if (doc.exists) {
        return Pet.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw FirestoreException('Failed to get pet: ${e.toString()}');
    }
  }

  /// Create pet
  Future<void> createPet(Pet pet) async {
    try {
      await _pets.doc(pet.id).set(pet.toJson());
    } catch (e) {
      throw FirestoreException('Failed to create pet: ${e.toString()}');
    }
  }

  /// Update pet
  Future<void> updatePet(String petId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _pets.doc(petId).update(updates);
    } catch (e) {
      throw FirestoreException('Failed to update pet: ${e.toString()}');
    }
  }

  /// Get appointments for user
  Future<List<Appointment>> getUserAppointments(String userId, {bool upcomingOnly = false}) async {
    try {
      Query query = _appointments.where('userId', isEqualTo: userId);

      if (upcomingOnly) {
        query = query.where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.now());
      }

      query = query.orderBy('scheduledAt', descending: upcomingOnly);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Appointment.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get appointments: ${e.toString()}');
    }
  }

  /// Get clinic appointments (for staff)
  Future<List<Appointment>> getClinicAppointments(String clinicId, {DateTime? date, int limit = 50}) async {
    try {
      Query query = _appointments.where('clinicId', isEqualTo: clinicId);

      if (date != null) {
        final startOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day));
        final endOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));
        query = query
            .where('scheduledAt', isGreaterThanOrEqualTo: startOfDay)
            .where('scheduledAt', isLessThanOrEqualTo: endOfDay);
      }

      query = query.orderBy('scheduledAt').limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Appointment.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get clinic appointments: ${e.toString()}');
    }
  }

  /// Create appointment
  Future<void> createAppointment(Appointment appointment) async {
    try {
      await _appointments.doc(appointment.id).set(appointment.toJson());
    } catch (e) {
      throw FirestoreException('Failed to create appointment: ${e.toString()}');
    }
  }

  /// Update appointment
  Future<void> updateAppointment(String appointmentId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _appointments.doc(appointmentId).update(updates);
    } catch (e) {
      throw FirestoreException('Failed to update appointment: ${e.toString()}');
    }
  }

  /// Stream user profile changes
  Stream<User?> watchUserProfile(String userId) {
    return _users.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return User.fromJson(doc.data()!);
      }
      return null;
    });
  }

  /// Stream user pets
  Stream<List<Pet>> watchUserPets(String userId) {
    return _pets
        .where('ownerId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Pet.fromJson(doc.data())).toList());
  }

  /// Stream clinic appointments
  Stream<List<Appointment>> watchClinicAppointments(String clinicId) {
    return _appointments
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('scheduledAt')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Appointment.fromJson(doc.data())).toList());
  }

  /// Get medical records for a pet
  Future<List<dynamic>> getPetMedicalRecords(String petId) async {
    try {
      final snapshot = await _medicalRecords
          .where('petId', isEqualTo: petId)
          .where('isActive', isEqualTo: true)
          .orderBy('recordDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => MedicalRecord.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get medical records: ${e.toString()}');
    }
  }

  /// Get medical record by ID
  Future<dynamic> getMedicalRecord(String recordId) async {
    try {
      final doc = await _medicalRecords.doc(recordId).get();
      if (doc.exists) {
        return MedicalRecord.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw FirestoreException('Failed to get medical record: ${e.toString()}');
    }
  }

  /// Create medical record
  Future<String?> createMedicalRecord(dynamic medicalRecord) async {
    try {
      final docRef = await _medicalRecords.add(medicalRecord.toJson());
      return docRef.id;
    } catch (e) {
      throw FirestoreException('Failed to create medical record: ${e.toString()}');
    }
  }

  /// Update medical record
  Future<void> updateMedicalRecord(String recordId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _medicalRecords.doc(recordId).update(updates);
    } catch (e) {
      throw FirestoreException('Failed to update medical record: ${e.toString()}');
    }
  }

  /// Get prescriptions for a medical record
  Future<List<dynamic>> getPrescriptions(String medicalRecordId) async {
    try {
      final snapshot = await _prescriptions
          .where('medicalRecordId', isEqualTo: medicalRecordId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Prescription.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get prescriptions: ${e.toString()}');
    }
  }

  /// Create prescription
  Future<String?> createPrescription(dynamic prescription) async {
    try {
      final docRef = await _prescriptions.add(prescription.toJson());
      return docRef.id;
    } catch (e) {
      throw FirestoreException('Failed to create prescription: ${e.toString()}');
    }
  }

  /// Get vaccination records for a pet
  Future<List<dynamic>> getPetVaccinations(String petId) async {
    try {
      final snapshot = await _vaccinations
          .where('petId', isEqualTo: petId)
          .where('isActive', isEqualTo: true)
          .orderBy('vaccinationDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => VaccinationRecord.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get vaccinations: ${e.toString()}');
    }
  }

  /// Create vaccination record
  Future<String?> createVaccination(dynamic vaccination) async {
    try {
      final docRef = await _vaccinations.add(vaccination.toJson());
      return docRef.id;
    } catch (e) {
      throw FirestoreException('Failed to create vaccination: ${e.toString()}');
    }
  }

  /// Get clinic medical records (for staff)
  Future<List<dynamic>> getClinicMedicalRecords(String clinicId, {DateTime? date, int limit = 50}) async {
    try {
      Query query = _medicalRecords.where('clinicId', isEqualTo: clinicId);

      if (date != null) {
        final startOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day));
        final endOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));
        query = query
            .where('recordDate', isGreaterThanOrEqualTo: startOfDay)
            .where('recordDate', isLessThanOrEqualTo: endOfDay);
      }

      query = query.orderBy('recordDate', descending: true).limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => MedicalRecord.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get clinic medical records: ${e.toString()}');
    }
  }

  /// Stream pet medical records
  Stream<List<dynamic>> watchPetMedicalRecords(String petId) {
    return _medicalRecords
        .where('petId', isEqualTo: petId)
        .where('isActive', isEqualTo: true)
        .orderBy('recordDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MedicalRecord.fromJson(doc.data())).toList());
  }

  /// Stream clinic medical records
  Stream<List<dynamic>> watchClinicMedicalRecords(String clinicId) {
    return _medicalRecords
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('recordDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MedicalRecord.fromJson(doc.data())).toList());
  }

  /// Get user's pets
  Future<List<dynamic>> getUserPets(String userId) async {
    try {
      final snapshot = await _pets
          .where('ownerId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => Pet.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get user pets: ${e.toString()}');
    }
  }

  /// Get pet by ID
  Future<dynamic> getPet(String petId) async {
    try {
      final doc = await _pets.doc(petId).get();
      if (doc.exists) {
        return Pet.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw FirestoreException('Failed to get pet: ${e.toString()}');
    }
  }

  /// Create pet
  Future<String?> createPet(dynamic pet) async {
    try {
      final docRef = await _pets.add(pet.toJson());
      return docRef.id;
    } catch (e) {
      throw FirestoreException('Failed to create pet: ${e.toString()}');
    }
  }

  /// Update pet
  Future<void> updatePet(String petId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _pets.doc(petId).update(updates);
    } catch (e) {
      throw FirestoreException('Failed to update pet: ${e.toString()}');
    }
  }

  /// Delete pet (soft delete)
  Future<void> deletePet(String petId) async {
    try {
      await _pets.doc(petId).update({
        'isActive': false,
        'status': 'inactive',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Failed to delete pet: ${e.toString()}');
    }
  }

  /// Stream user pets
  Stream<List<dynamic>> watchUserPets(String userId) {
    return _pets
        .where('ownerId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Pet.fromJson(doc.data())).toList());
  }

  /// Get pet medical summary
  Future<dynamic> getPetMedicalSummary(String petId) async {
    try {
      // Get pet medical records count
      final medicalRecordsQuery = await _medicalRecords
          .where('petId', isEqualTo: petId)
          .where('isActive', isEqualTo: true)
          .get();

      final totalVisits = medicalRecordsQuery.docs.length;

      // Get last visit date
      DateTime? lastVisitDate;
      if (medicalRecordsQuery.docs.isNotEmpty) {
        final sortedRecords =
            medicalRecordsQuery.docs.map((doc) => MedicalRecord.fromJson(doc.data() as Map<String, dynamic>)).toList()
              ..sort((a, b) => b.recordDate.compareTo(a.recordDate));
        lastVisitDate = sortedRecords.first.recordDate;
      }

      // Get current medications from prescriptions
      final prescriptionsQuery = await _prescriptions
          .where('petId', isEqualTo: petId)
          .where('isActive', isEqualTo: true)
          .get();

      final currentMedications = <String>[];
      for (final doc in prescriptionsQuery.docs) {
        final prescription = Prescription.fromJson(doc.data() as Map<String, dynamic>);
        if (prescription.isActive && !prescription.isExpired) {
          for (final item in prescription.items) {
            if (!currentMedications.contains(item.medicationName)) {
              currentMedications.add(item.medicationName);
            }
          }
        }
      }

      // Get allergies from pet data (will be implemented when pet CRUD is done)
      final allergies = <String>[];

      // Check if needs vaccination
      final vaccinationsQuery = await _vaccinations
          .where('petId', isEqualTo: petId)
          .where('isActive', isEqualTo: true)
          .orderBy('vaccinationDate', descending: true)
          .limit(1)
          .get();

      bool needsVaccination = true;
      if (vaccinationsQuery.docs.isNotEmpty) {
        final lastVaccination = VaccinationRecord.fromJson(vaccinationsQuery.docs.first.data());
        final daysSinceVaccination = DateTime.now().difference(lastVaccination.vaccinationDate).inDays;
        needsVaccination = daysSinceVaccination > 365; // Simplified: needs vaccination if > 1 year
      }

      return PetMedicalSummary(
        petId: petId,
        totalVisits: totalVisits,
        lastVisitDate: lastVisitDate,
        currentMedications: currentMedications,
        allergies: allergies,
        needsVaccination: needsVaccination,
      );
    } catch (e) {
      throw FirestoreException('Failed to get pet medical summary: ${e.toString()}');
    }
  }

  /// Get all clinics (admin)
  Future<List<dynamic>> getAllClinics() async {
    try {
      final snapshot = await _clinics.orderBy('name').get();

      return snapshot.docs.map((doc) => Clinic.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get clinics: ${e.toString()}');
    }
  }

  /// Get clinic by ID
  Future<dynamic> getClinic(String clinicId) async {
    try {
      final doc = await _clinics.doc(clinicId).get();
      if (doc.exists) {
        return Clinic.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw FirestoreException('Failed to get clinic: ${e.toString()}');
    }
  }

  /// Create clinic
  Future<String?> createClinic(dynamic clinic) async {
    try {
      final docRef = await _clinics.add(clinic.toJson());
      return docRef.id;
    } catch (e) {
      throw FirestoreException('Failed to create clinic: ${e.toString()}');
    }
  }

  /// Update clinic
  Future<void> updateClinic(String clinicId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _clinics.doc(clinicId).update(updates);
    } catch (e) {
      throw FirestoreException('Failed to update clinic: ${e.toString()}');
    }
  }

  /// Delete clinic (soft delete)
  Future<void> deleteClinic(String clinicId) async {
    try {
      await _clinics.doc(clinicId).update({
        'isActive': false,
        'status': 'closed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Failed to delete clinic: ${e.toString()}');
    }
  }

  /// Get clinic services
  Future<List<dynamic>> getClinicServices(String clinicId) async {
    try {
      final snapshot = await _clinicServices
          .where('clinicId', isEqualTo: clinicId)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => ClinicService.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get clinic services: ${e.toString()}');
    }
  }

  /// Create clinic service
  Future<String?> createClinicService(dynamic service) async {
    try {
      final docRef = await _clinicServices.add(service.toJson());
      return docRef.id;
    } catch (e) {
      throw FirestoreException('Failed to create clinic service: ${e.toString()}');
    }
  }

  /// Update clinic service
  Future<void> updateClinicService(String serviceId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _clinicServices.doc(serviceId).update(updates);
    } catch (e) {
      throw FirestoreException('Failed to update clinic service: ${e.toString()}');
    }
  }

  /// Delete clinic service (soft delete)
  Future<void> deleteClinicService(String serviceId) async {
    try {
      await _clinicServices.doc(serviceId).update({'isActive': false, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      throw FirestoreException('Failed to delete clinic service: ${e.toString()}');
    }
  }

  /// Get clinic staff
  Future<List<dynamic>> getClinicStaff(String clinicId) async {
    try {
      final snapshot = await _clinicStaff
          .where('clinicId', isEqualTo: clinicId)
          .where('isActive', isEqualTo: true)
          .orderBy('role')
          .get();

      return snapshot.docs.map((doc) => ClinicStaff.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get clinic staff: ${e.toString()}');
    }
  }

  /// Add staff to clinic
  Future<String?> addClinicStaff(dynamic staff) async {
    try {
      final docRef = await _clinicStaff.add(staff.toJson());
      return docRef.id;
    } catch (e) {
      throw FirestoreException('Failed to add clinic staff: ${e.toString()}');
    }
  }

  /// Update clinic staff
  Future<void> updateClinicStaff(String staffId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _clinicStaff.doc(staffId).update(updates);
    } catch (e) {
      throw FirestoreException('Failed to update clinic staff: ${e.toString()}');
    }
  }

  /// Remove clinic staff
  Future<void> removeClinicStaff(String staffId) async {
    try {
      await _clinicStaff.doc(staffId).update({'isActive': false, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      throw FirestoreException('Failed to remove clinic staff: ${e.toString()}');
    }
  }

  /// Get clinic analytics
  Future<Map<String, dynamic>> getClinicAnalytics(String clinicId) async {
    try {
      // Get total appointments
      final appointmentsQuery = await _appointments.where('clinicId', isEqualTo: clinicId).get();

      final totalAppointments = appointmentsQuery.docs.length;

      // Get appointments this month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final appointmentsThisMonth = appointmentsQuery.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final scheduledAt = (data['scheduledAt'] as Timestamp).toDate();
        return scheduledAt.isAfter(startOfMonth);
      }).length;

      // Get total pets
      final petsQuery = await _pets.where('clinicId', isEqualTo: clinicId).get();
      final totalPets = petsQuery.docs.length;

      // Get total medical records
      final medicalRecordsQuery = await _medicalRecords.where('clinicId', isEqualTo: clinicId).get();
      final totalMedicalRecords = medicalRecordsQuery.docs.length;

      // Calculate revenue (mock - would need billing system)
      final mockRevenue = totalAppointments * 50000; // 50k VND per appointment

      return {
        'totalAppointments': totalAppointments,
        'appointmentsThisMonth': appointmentsThisMonth,
        'totalPets': totalPets,
        'totalMedicalRecords': totalMedicalRecords,
        'revenue': mockRevenue,
        'averageRating': 4.5, // Mock rating
      };
    } catch (e) {
      throw FirestoreException('Failed to get clinic analytics: ${e.toString()}');
    }
  }

  /// Generate invoice number
  Future<String> generateInvoiceNumber(String clinicId) async {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    // Get count of invoices for today
    final startOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final endOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59));

    final snapshot = await _invoices
        .where('clinicId', isEqualTo: clinicId)
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .where('createdAt', isLessThanOrEqualTo: endOfDay)
        .get();

    final count = snapshot.docs.length + 1;
    final countStr = count.toString().padLeft(4, '0');

    return 'INV-$clinicId-$dateStr-$countStr';
  }

  /// Get invoices for a customer
  Future<List<dynamic>> getCustomerInvoices(String customerId) async {
    try {
      final snapshot = await _invoices
          .where('customerId', isEqualTo: customerId)
          .where('isActive', isEqualTo: true)
          .orderBy('issueDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => Invoice.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get customer invoices: ${e.toString()}');
    }
  }

  /// Get clinic invoices
  Future<List<dynamic>> getClinicInvoices(String clinicId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      Query query = _invoices.where('clinicId', isEqualTo: clinicId);

      if (startDate != null) {
        query = query.where('issueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('issueDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('issueDate', descending: true);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Invoice.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get clinic invoices: ${e.toString()}');
    }
  }

  /// Get invoice by ID
  Future<dynamic> getInvoice(String invoiceId) async {
    try {
      final doc = await _invoices.doc(invoiceId).get();
      if (doc.exists) {
        return Invoice.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw FirestoreException('Failed to get invoice: ${e.toString()}');
    }
  }

  /// Create invoice
  Future<String?> createInvoice(dynamic invoice) async {
    try {
      final docRef = await _invoices.add(invoice.toJson());
      return docRef.id;
    } catch (e) {
      throw FirestoreException('Failed to create invoice: ${e.toString()}');
    }
  }

  /// Update invoice
  Future<void> updateInvoice(String invoiceId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _invoices.doc(invoiceId).update(updates);
    } catch (e) {
      throw FirestoreException('Failed to update invoice: ${e.toString()}');
    }
  }

  /// Delete invoice (soft delete)
  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _invoices.doc(invoiceId).update({'isActive': false, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      throw FirestoreException('Failed to delete invoice: ${e.toString()}');
    }
  }

  /// Get payments for an invoice
  Future<List<dynamic>> getInvoicePayments(String invoiceId) async {
    try {
      final snapshot = await _payments
          .where('invoiceId', isEqualTo: invoiceId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Payment.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get invoice payments: ${e.toString()}');
    }
  }

  /// Get payments for a customer
  Future<List<dynamic>> getCustomerPayments(String customerId) async {
    try {
      final snapshot = await _payments
          .where('customerId', isEqualTo: customerId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Payment.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get customer payments: ${e.toString()}');
    }
  }

  /// Get clinic payments
  Future<List<dynamic>> getClinicPayments(String clinicId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      Query query = _payments.where('isActive', isEqualTo: true);

      // Note: We can't filter by clinicId directly since payments are linked to invoices
      // This would need to be done in application logic by first getting clinic invoices

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Payment.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get clinic payments: ${e.toString()}');
    }
  }

  /// Create payment
  Future<String?> createPayment(dynamic payment) async {
    try {
      final docRef = await _payments.add(payment.toJson());
      return docRef.id;
    } catch (e) {
      throw FirestoreException('Failed to create payment: ${e.toString()}');
    }
  }

  /// Update payment
  Future<void> updatePayment(String paymentId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _payments.doc(paymentId).update(updates);
    } catch (e) {
      throw FirestoreException('Failed to update payment: ${e.toString()}');
    }
  }

  /// Process payment (mark as completed)
  Future<void> processPayment(String paymentId) async {
    try {
      await _payments.doc(paymentId).update({
        'status': 'completed',
        'paymentDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Failed to process payment: ${e.toString()}');
    }
  }

  /// Get billing analytics for clinic
  Future<Map<String, dynamic>> getClinicBillingAnalytics(
    String clinicId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      // Get clinic invoices
      final invoices = await getClinicInvoices(clinicId, startDate: start, endDate: end) as List<Invoice>;

      // Calculate totals
      final totalInvoices = invoices.length;
      final totalRevenue = invoices
          .where((inv) => inv.status.isPaid)
          .fold<double>(0, (sum, inv) => sum + inv.totalAmount);
      final pendingAmount = invoices
          .where((inv) => !inv.status.isPaid && !inv.status.isCancelled)
          .fold<double>(0, (sum, inv) => sum + inv.totalAmount);
      final overdueInvoices = invoices.where((inv) => inv.isOverdue).length;

      // Get payments
      final payments = await getClinicPayments(clinicId, startDate: start, endDate: end) as List<Payment>;
      final totalPayments = payments.where((p) => p.status.isSuccessful).fold<double>(0, (sum, p) => sum + p.amount);

      return {
        'totalInvoices': totalInvoices,
        'totalRevenue': totalRevenue,
        'pendingAmount': pendingAmount,
        'overdueInvoices': overdueInvoices,
        'totalPayments': totalPayments,
        'period': {'start': start.toIso8601String(), 'end': end.toIso8601String()},
      };
    } catch (e) {
      throw FirestoreException('Failed to get billing analytics: ${e.toString()}');
    }
  }

  /// Get user profile by user ID
  Future<dynamic?> getUserProfile(String userId) async {
    try {
      final doc = await _userProfiles.doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw FirestoreException('Failed to get user profile: ${e.toString()}');
    }
  }

  /// Create or update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _userProfiles.doc(userId).set(updates, SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to update user profile: ${e.toString()}');
    }
  }

  /// Get all users (admin only)
  Future<List<dynamic>> getAllUsers({int limit = 50, DocumentSnapshot? startAfter}) async {
    try {
      Query query = _userProfiles.orderBy('createdAt', descending: true).limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => UserProfile.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get users: ${e.toString()}');
    }
  }

  /// Get clinic users
  Future<List<dynamic>> getClinicUsers(String clinicId) async {
    try {
      final snapshot = await _userProfiles
          .where('clinicId', isEqualTo: clinicId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => UserProfile.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get clinic users: ${e.toString()}');
    }
  }

  /// Update user role
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _userProfiles.doc(userId).update({
        'role': newRole.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Failed to update user role: ${e.toString()}');
    }
  }

  /// Deactivate user
  Future<void> deactivateUser(String userId) async {
    try {
      await _userProfiles.doc(userId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Failed to deactivate user: ${e.toString()}');
    }
  }

  /// Reactivate user
  Future<void> reactivateUser(String userId) async {
    try {
      await _userProfiles.doc(userId).update({
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Failed to reactivate user: ${e.toString()}');
    }
  }

  /// Log user activity
  Future<String?> logUserActivity(dynamic activity) async {
    try {
      final docRef = await _userActivities.add(activity.toJson());
      return docRef.id;
    } catch (e) {
      throw FirestoreException('Failed to log user activity: ${e.toString()}');
    }
  }

  /// Get user activities
  Future<List<dynamic>> getUserActivities(String userId, {int limit = 20, DocumentSnapshot? startAfter}) async {
    try {
      Query query = _userActivities
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => UserActivity.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FirestoreException('Failed to get user activities: ${e.toString()}');
    }
  }

  /// Get notification preferences
  Future<dynamic?> getNotificationPreferences(String userId) async {
    try {
      final doc = await _notificationPreferences.doc(userId).get();
      if (doc.exists) {
        return NotificationPreferences.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw FirestoreException('Failed to get notification preferences: ${e.toString()}');
    }
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _notificationPreferences.doc(userId).set(updates, SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to update notification preferences: ${e.toString()}');
    }
  }

  /// Create password reset token
  Future<String?> createPasswordResetToken(dynamic token) async {
    try {
      final docRef = await _passwordResetTokens.add(token.toJson());
      return docRef.id;
    } catch (e) {
      throw FirestoreException('Failed to create password reset token: ${e.toString()}');
    }
  }

  /// Verify password reset token
  Future<dynamic?> verifyPasswordResetToken(String token) async {
    try {
      final snapshot = await _passwordResetTokens
          .where('token', isEqualTo: token)
          .where('isUsed', isEqualTo: false)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final tokenData = PasswordResetToken.fromJson(doc.data() as Map<String, dynamic>);

        if (!tokenData.isExpired) {
          return tokenData;
        }
      }
      return null;
    } catch (e) {
      throw FirestoreException('Failed to verify password reset token: ${e.toString()}');
    }
  }

  /// Use password reset token
  Future<void> usePasswordResetToken(String tokenId) async {
    try {
      await _passwordResetTokens.doc(tokenId).update({
        'isUsed': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Failed to use password reset token: ${e.toString()}');
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final totalUsers = await _userProfiles.where('isActive', isEqualTo: true).count().get();
      final totalAdmins = await _userProfiles.where('role', isEqualTo: 'super_admin').count().get();
      final totalClinicAdmins = await _userProfiles.where('role', isEqualTo: 'clinic_admin').count().get();
      final totalVeterinarians = await _userProfiles.where('role', isEqualTo: 'veterinarian').count().get();
      final totalReceptionists = await _userProfiles.where('role', isEqualTo: 'receptionist').count().get();
      final totalCustomers = await _userProfiles.where('role', isEqualTo: 'customer').count().get();

      // Recent activities (last 7 days)
      final sevenDaysAgo = Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7)));
      final recentActivities = await _userActivities
          .where('createdAt', isGreaterThan: sevenDaysAgo)
          .count()
          .get();

      return {
        'totalUsers': totalUsers.count,
        'totalAdmins': totalAdmins.count,
        'totalClinicAdmins': totalClinicAdmins.count,
        'totalVeterinarians': totalVeterinarians.count,
        'totalReceptionists': totalReceptionists.count,
        'totalCustomers': totalCustomers.count,
        'recentActivities': recentActivities.count,
      };
    } catch (e) {
      throw FirestoreException('Failed to get user statistics: ${e.toString()}');
    }
  }
}

/// Custom exception for Firestore operations
class FirestoreException implements Exception {
  final String message;

  FirestoreException(this.message);

  @override
  String toString() => message;
}
