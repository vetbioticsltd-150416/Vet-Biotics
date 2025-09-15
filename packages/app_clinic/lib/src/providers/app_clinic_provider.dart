import 'package:flutter/material.dart';
import 'package:vet_biotics_auth/auth.dart';

class AppClinicProvider extends ChangeNotifier {
  final DatabaseProvider _databaseProvider;

  AppClinicProvider({DatabaseProvider? databaseProvider}) : _databaseProvider = databaseProvider ?? DatabaseProvider();

  // Clinic info
  Clinic? _currentClinic;
  List<User> _staff = [];

  // Appointments
  List<Appointment> _todayAppointments = [];
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _pendingAppointments = [];

  // Patients (pets and owners)
  List<Pet> _patients = [];
  List<User> _petOwners = [];

  // Medical records
  List<MedicalRecord> _recentMedicalRecords = [];

  // Billing
  List<Billing> _todayBilling = [];
  double _todayRevenue = 0;

  // Inventory
  List<InventoryItem> _lowStockItems = [];

  // Getters
  Clinic? get currentClinic => _currentClinic;
  List<User> get staff => _staff;

  List<Appointment> get todayAppointments => _todayAppointments;
  List<Appointment> get upcomingAppointments => _upcomingAppointments;
  List<Appointment> get pendingAppointments => _pendingAppointments;

  List<Pet> get patients => _patients;
  List<User> get petOwners => _petOwners;

  List<MedicalRecord> get recentMedicalRecords => _recentMedicalRecords;

  List<Billing> get todayBilling => _todayBilling;
  double get todayRevenue => _todayRevenue;

  List<InventoryItem> get lowStockItems => _lowStockItems;

  // Clinic management
  void setCurrentClinic(Clinic clinic) {
    _currentClinic = clinic;
    notifyListeners();
  }

  void setStaff(List<User> staff) {
    _staff = staff;
    notifyListeners();
  }

  void addStaff(User staffMember) {
    _staff.add(staffMember);
    notifyListeners();
  }

  void removeStaff(String staffId) {
    _staff.removeWhere((staff) => staff.id == staffId);
    notifyListeners();
  }

  // Appointment management
  void setTodayAppointments(List<Appointment> appointments) {
    _todayAppointments = appointments;
    notifyListeners();
  }

  void setUpcomingAppointments(List<Appointment> appointments) {
    _upcomingAppointments = appointments;
    notifyListeners();
  }

  void setPendingAppointments(List<Appointment> appointments) {
    _pendingAppointments = appointments;
    notifyListeners();
  }

  void updateAppointmentStatus(String appointmentId, AppointmentStatus status) {
    _updateAppointmentInList(_todayAppointments, appointmentId, status);
    _updateAppointmentInList(_upcomingAppointments, appointmentId, status);
    _updateAppointmentInList(_pendingAppointments, appointmentId, status);
    notifyListeners();
  }

  void _updateAppointmentInList(List<Appointment> appointments, String appointmentId, AppointmentStatus status) {
    final index = appointments.indexWhere((apt) => apt.id == appointmentId);
    if (index != -1) {
      appointments[index] = appointments[index].copyWith(status: status);
    }
  }

  // Patient management
  void setPatients(List<Pet> patients) {
    _patients = patients;
    notifyListeners();
  }

  void setPetOwners(List<User> owners) {
    _petOwners = owners;
    notifyListeners();
  }

  void addPatient(Pet patient) {
    _patients.add(patient);
    notifyListeners();
  }

  void updatePatient(Pet patient) {
    final index = _patients.indexWhere((p) => p.id == patient.id);
    if (index != -1) {
      _patients[index] = patient;
      notifyListeners();
    }
  }

  // Medical records management
  void setRecentMedicalRecords(List<MedicalRecord> records) {
    _recentMedicalRecords = records;
    notifyListeners();
  }

  void addMedicalRecord(MedicalRecord record) {
    _recentMedicalRecords.insert(0, record);
    notifyListeners();
  }

  // Billing management
  void setTodayBilling(List<Billing> billing) {
    _todayBilling = billing;
    _calculateTodayRevenue();
    notifyListeners();
  }

  void setTodayRevenue(double revenue) {
    _todayRevenue = revenue;
    notifyListeners();
  }

  void _calculateTodayRevenue() {
    _todayRevenue = _todayBilling
        .where((billing) => billing.status == BillingStatus.paid)
        .fold(0, (sum, billing) => sum + billing.totalAmount);
  }

  void addBillingRecord(Billing billing) {
    _todayBilling.add(billing);
    if (billing.status == BillingStatus.paid) {
      _todayRevenue += billing.totalAmount;
    }
    notifyListeners();
  }

  // Inventory management
  void setLowStockItems(List<InventoryItem> items) {
    _lowStockItems = items;
    notifyListeners();
  }

  void updateInventoryItem(InventoryItem item) {
    final index = _lowStockItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _lowStockItems[index] = item;
      notifyListeners();
    }
  }

  // Load clinic data
  Future<void> loadClinicData() async {
    if (_currentClinic == null) return;

    try {
      // Load today's appointments
      final todayAppointments = await _databaseProvider.getClinicAppointments(
        _currentClinic!.id!,
        date: DateTime.now(),
      );
      _todayAppointments = todayAppointments.map((a) => a as Appointment).toList();

      // Load upcoming appointments (next 7 days)
      final nextWeek = DateTime.now().add(const Duration(days: 7));
      final upcomingAppointments = await _databaseProvider.getClinicAppointments(_currentClinic!.id!, date: nextWeek);
      _upcomingAppointments = upcomingAppointments.map((a) => a as Appointment).toList();

      // Load pending appointments
      final pendingAppointments = await _databaseProvider.getClinicAppointments(_currentClinic!.id!);
      _pendingAppointments = pendingAppointments
          .map((a) => a as Appointment)
          .where((apt) => apt.status == AppointmentStatus.pending)
          .toList();

      // Load clinic staff
      _staff = await _databaseProvider.getClinicStaff(_currentClinic!.id!);

      // Load patients (recent)
      final pets = await _databaseProvider.getUserPets();
      _patients = pets.map((p) => p as Pet).take(20).toList();

      // Load recent medical records
      final medicalRecords = await _databaseProvider.getClinicMedicalRecords(_currentClinic!.id!, limit: 10);
      _recentMedicalRecords = medicalRecords.map((r) => r as MedicalRecord).toList();

      // Load today's billing
      final todayBilling = await _databaseProvider.getClinicInvoices(
        _currentClinic!.id!,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );
      _todayBilling = todayBilling.map((b) => b as Billing).toList();
      _calculateTodayRevenue();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading clinic data: $e');
    }
  }

  // Appointment management methods
  Future<bool> createAppointment(Appointment appointment) async {
    try {
      await _databaseProvider.createAppointment(appointment);
      debugPrint('Appointment created successfully');
      // Refresh data to show the new appointment
      loadClinicData();
      return true;
    } catch (e) {
      debugPrint('Failed to create appointment: $e');
      return false;
    }
  }

  Future<bool> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    try {
      await _databaseProvider.updateAppointmentStatus(appointmentId, status.value);
      // Update local state immediately for better UX
      _updateAppointmentInList(_todayAppointments, appointmentId, status);
      _updateAppointmentInList(_upcomingAppointments, appointmentId, status);
      _updateAppointmentInList(_pendingAppointments, appointmentId, status);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to update appointment status: $e');
      return false;
    }
  }

  Future<bool> cancelAppointment(String appointmentId, {String? reason}) async {
    try {
      await _databaseProvider.cancelAppointment(appointmentId, reason: reason);
      // Update local state
      _updateAppointmentInList(_todayAppointments, appointmentId, AppointmentStatus.cancelled);
      _updateAppointmentInList(_upcomingAppointments, appointmentId, AppointmentStatus.cancelled);
      _updateAppointmentInList(_pendingAppointments, appointmentId, AppointmentStatus.cancelled);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to cancel appointment: $e');
      return false;
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadClinicData();
  }

  // Clear data (logout)
  void clearData() {
    _currentClinic = null;
    _staff = [];
    _todayAppointments = [];
    _upcomingAppointments = [];
    _pendingAppointments = [];
    _patients = [];
    _petOwners = [];
    _recentMedicalRecords = [];
    _todayBilling = [];
    _todayRevenue = 0.0;
    _lowStockItems = [];
    notifyListeners();
  }
}
