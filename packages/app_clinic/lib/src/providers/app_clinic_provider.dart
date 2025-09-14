import 'package:flutter/material.dart';
import 'package:vet_biotics_core/core.dart';

class AppClinicProvider extends ChangeNotifier {
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
  double _todayRevenue = 0.0;

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
        .fold(0.0, (sum, billing) => sum + billing.totalAmount);
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
    // TODO: Implement data loading from repositories
    // This will use the core repositories to fetch data
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
