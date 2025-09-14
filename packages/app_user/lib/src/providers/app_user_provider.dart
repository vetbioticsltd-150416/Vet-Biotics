import 'package:flutter/material.dart';
import 'package:vet_biotics_core/core.dart';

class AppUserProvider extends ChangeNotifier {
  int _currentIndex = 0;
  User? _currentUser;
  List<Pet> _pets = [];
  List<Appointment> _appointments = [];
  List<MedicalRecord> _medicalRecords = [];

  // Getters
  int get currentIndex => _currentIndex;
  User? get currentUser => _currentUser;
  List<Pet> get pets => _pets;
  List<Appointment> get appointments => _appointments;
  List<MedicalRecord> get medicalRecords => _medicalRecords;

  // Bottom navigation
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // User management
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Pet management
  void setPets(List<Pet> pets) {
    _pets = pets;
    notifyListeners();
  }

  void addPet(Pet pet) {
    _pets.add(pet);
    notifyListeners();
  }

  void updatePet(Pet pet) {
    final index = _pets.indexWhere((p) => p.id == pet.id);
    if (index != -1) {
      _pets[index] = pet;
      notifyListeners();
    }
  }

  void removePet(String petId) {
    _pets.removeWhere((pet) => pet.id == petId);
    notifyListeners();
  }

  // Appointment management
  void setAppointments(List<Appointment> appointments) {
    _appointments = appointments;
    notifyListeners();
  }

  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
    notifyListeners();
  }

  void updateAppointment(Appointment appointment) {
    final index = _appointments.indexWhere((a) => a.id == appointment.id);
    if (index != -1) {
      _appointments[index] = appointment;
      notifyListeners();
    }
  }

  void cancelAppointment(String appointmentId) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(status: AppointmentStatus.cancelled);
      notifyListeners();
    }
  }

  // Medical records management
  void setMedicalRecords(List<MedicalRecord> records) {
    _medicalRecords = records;
    notifyListeners();
  }

  void addMedicalRecord(MedicalRecord record) {
    _medicalRecords.add(record);
    notifyListeners();
  }

  // Load user data
  Future<void> loadUserData() async {
    // TODO: Implement data loading from repository
    // This will use the core repositories to fetch data
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadUserData();
  }

  // Clear data (logout)
  void clearData() {
    _currentUser = null;
    _pets = [];
    _appointments = [];
    _medicalRecords = [];
    _currentIndex = 0;
    notifyListeners();
  }
}
