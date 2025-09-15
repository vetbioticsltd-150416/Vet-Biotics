import 'package:flutter/material.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';

class AppAdminProvider extends ChangeNotifier {
  final DatabaseProvider _databaseProvider;

  AppAdminProvider({DatabaseProvider? databaseProvider})
      : _databaseProvider = databaseProvider ?? DatabaseProvider() {
  // Navigation
  int currentIndex = 0;
  int get int currentIndex => currentIndex;

  void setCurrentIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  // Loading states
  bool isLoading = false;
  bool get bool isLoading => isLoading;

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  // Dashboard Data
  int totalClinics = 0;
  int totalUsers = 0;
  int totalAppointments = 0;
  double totalRevenue = 0;

  int get int totalClinics => totalClinics;
  int get int totalUsers => totalUsers;
  int get int totalAppointments => totalAppointments;
  double get double totalRevenue => totalRevenue;

  // Clinics Management
  List<Clinic> clinics = [];
  List<Clinic> get List<Clinic> clinics => clinics;

  void setClinics(List<Clinic> clinics) {
    clinics = clinics;
    notifyListeners();
  }

  void addClinic(Clinic clinic) {
    clinics.add(clinic);
    totalClinics = clinics.length;
    notifyListeners();
  }

  void updateClinic(Clinic updatedClinic) {
    final index = clinics.indexWhere((clinic) => clinic.id == updatedClinic.id);
    if (index != -1) {
      clinics[index] = updatedClinic;
      notifyListeners();
    }
  }

  void removeClinic(String clinicId) {
    clinics.removeWhere((clinic) => clinic.id == clinicId);
    totalClinics = clinics.length;
    notifyListeners();
  }

  // Users Management
  List<User> users = [];
  List<User> get List<User> users => users;

  void setUsers(List<User> users) {
    users = users;
    notifyListeners();
  }

  void addUser(User user) {
    users.add(user);
    totalUsers = users.length;
    notifyListeners();
  }

  void updateUser(User updatedUser) {
    final index = users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
      notifyListeners();
    }
  }

  void removeUser(String userId) {
    users.removeWhere((user) => user.id == userId);
    totalUsers = users.length;
    notifyListeners();
  }

  // Analytics Data
  Map<String, dynamic> analyticsData = {};
  Map<String, dynamic> get Map<String, dynamic> analyticsData => analyticsData;

  void setAnalyticsData(Map<String, dynamic> data) {
    analyticsData = data;
    notifyListeners();
  }

  // Load real data from Firebase
  Future<void> loadData() async {
    try {
      setLoading(true);

      // Load clinics
      var clinics = await _databaseProvider.getAllClinics();
      clinics = clinics.map((c) => c as Clinic).toList();

      // Load users
      var users = await _databaseProvider.getAllUsers(limit: 100);
      users = users.map((u) => u as User).toList();

      // Update totals
      totalClinics = clinics.length;
      totalUsers = users.length;

      // Load analytics data
      await loadAnalyticsData();

      setLoading(false);
    } catch (e) {
      debugPrint('Error loading admin data: $e');
      setLoading(false);
      // Fallback to mock data if Firebase fails
      loadMockData();
    }
  }

  Future<void> loadAnalyticsData() async {
    try {
      final statistics = await _databaseProvider.getUserStatistics();
      analyticsData = statistics;

      // Calculate total appointments and revenue from statistics
      totalAppointments = statistics['totalAppointments'] ?? 0;
      totalRevenue = statistics['totalRevenue'] ?? 0.0;
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    }
  }

  // Mock Data for Development (fallback)
  void loadMockData() {
    // Mock Clinics
    clinics = [
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
    users = [
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
    totalClinics = clinics.length;
    totalUsers = users.length;
    totalAppointments = 1250; // Mock data
    totalRevenue = 250000.0; // Mock data

    // Mock Analytics Data
    analyticsData = {
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

  // Initialize with real data (fallback to mock if needed)
  void AppAdminProvider() {
    loadData();
  }
}
