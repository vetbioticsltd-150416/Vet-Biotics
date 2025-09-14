import 'package:flutter/material.dart';
import 'package:vet_biotics_core/core.dart';

class AppAdminProvider extends ChangeNotifier {
  // Navigation
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Dashboard Data
  int _totalClinics = 0;
  int _totalUsers = 0;
  int _totalAppointments = 0;
  double _totalRevenue = 0.0;

  int get totalClinics => _totalClinics;
  int get totalUsers => _totalUsers;
  int get totalAppointments => _totalAppointments;
  double get totalRevenue => _totalRevenue;

  // Clinics Management
  List<Clinic> _clinics = [];
  List<Clinic> get clinics => _clinics;

  void setClinics(List<Clinic> clinics) {
    _clinics = clinics;
    notifyListeners();
  }

  void addClinic(Clinic clinic) {
    _clinics.add(clinic);
    _totalClinics = _clinics.length;
    notifyListeners();
  }

  void updateClinic(Clinic updatedClinic) {
    final index = _clinics.indexWhere((clinic) => clinic.id == updatedClinic.id);
    if (index != -1) {
      _clinics[index] = updatedClinic;
      notifyListeners();
    }
  }

  void removeClinic(String clinicId) {
    _clinics.removeWhere((clinic) => clinic.id == clinicId);
    _totalClinics = _clinics.length;
    notifyListeners();
  }

  // Users Management
  List<User> _users = [];
  List<User> get users => _users;

  void setUsers(List<User> users) {
    _users = users;
    notifyListeners();
  }

  void addUser(User user) {
    _users.add(user);
    _totalUsers = _users.length;
    notifyListeners();
  }

  void updateUser(User updatedUser) {
    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      notifyListeners();
    }
  }

  void removeUser(String userId) {
    _users.removeWhere((user) => user.id == userId);
    _totalUsers = _users.length;
    notifyListeners();
  }

  // Analytics Data
  Map<String, dynamic> _analyticsData = {};
  Map<String, dynamic> get analyticsData => _analyticsData;

  void setAnalyticsData(Map<String, dynamic> data) {
    _analyticsData = data;
    notifyListeners();
  }

  // Mock Data for Development
  void loadMockData() {
    // Mock Clinics
    _clinics = [
      Clinic(
        id: 'clinic_1',
        name: 'Central Pet Clinic',
        address: '123 Main St, City, State 12345',
        phone: '(555) 123-4567',
        email: 'info@centralpetclinic.com',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      ),
      Clinic(
        id: 'clinic_2',
        name: 'Downtown Veterinary',
        address: '456 Oak Ave, City, State 12345',
        phone: '(555) 987-6543',
        email: 'contact@downtownvet.com',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        updatedAt: DateTime.now(),
      ),
      Clinic(
        id: 'clinic_3',
        name: 'Suburban Animal Hospital',
        address: '789 Pine Rd, City, State 12345',
        phone: '(555) 456-7890',
        email: 'hello@suburbananimal.com',
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        updatedAt: DateTime.now(),
      ),
    ];

    // Mock Users
    _users = [
      User(
        id: 'user_1',
        email: 'admin@vetbiotics.com',
        firstName: 'Super',
        lastName: 'Admin',
        role: UserRole.superAdmin,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      ),
      User(
        id: 'user_2',
        email: 'clinic1@vetbiotics.com',
        firstName: 'Dr. John',
        lastName: 'Smith',
        role: UserRole.clinicAdmin,
        clinicId: 'clinic_1',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        updatedAt: DateTime.now(),
      ),
      User(
        id: 'user_3',
        email: 'clinic2@vetbiotics.com',
        firstName: 'Dr. Sarah',
        lastName: 'Johnson',
        role: UserRole.clinicAdmin,
        clinicId: 'clinic_2',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 250)),
        updatedAt: DateTime.now(),
      ),
      User(
        id: 'user_4',
        email: 'vet1@clinic1.com',
        firstName: 'Dr. Michael',
        lastName: 'Brown',
        role: UserRole.veterinarian,
        clinicId: 'clinic_1',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now(),
      ),
      User(
        id: 'user_5',
        email: 'reception@clinic1.com',
        firstName: 'Emily',
        lastName: 'Davis',
        role: UserRole.receptionist,
        clinicId: 'clinic_1',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        updatedAt: DateTime.now(),
      ),
    ];

    // Update totals
    _totalClinics = _clinics.length;
    _totalUsers = _users.length;
    _totalAppointments = 1250; // Mock data
    _totalRevenue = 250000.0; // Mock data

    // Mock Analytics Data
    _analyticsData = {
      'monthlyRevenue': [
        {'month': 'Jan', 'revenue': 18500.0},
        {'month': 'Feb', 'revenue': 22000.0},
        {'month': 'Mar', 'revenue': 19800.0},
        {'month': 'Apr', 'revenue': 25600.0},
        {'month': 'May', 'revenue': 28900.0},
        {'month': 'Jun', 'revenue': 31200.0},
      ],
      'clinicPerformance': [
        {'clinic': 'Central Pet Clinic', 'appointments': 450, 'revenue': 89500.0},
        {'clinic': 'Downtown Veterinary', 'appointments': 380, 'revenue': 76200.0},
        {'clinic': 'Suburban Animal Hospital', 'appointments': 0, 'revenue': 0.0},
      ],
      'userRegistrations': [
        {'month': 'Jan', 'count': 45},
        {'month': 'Feb', 'count': 52},
        {'month': 'Mar', 'count': 38},
        {'month': 'Apr', 'count': 67},
        {'month': 'May', 'count': 71},
        {'month': 'Jun', 'count': 89},
      ],
    };

    notifyListeners();
  }

  // Initialize with mock data
  AppAdminProvider() {
    loadMockData();
  }
}
