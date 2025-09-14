/// API endpoints configuration
class ApiEndpoints {
  // Base URLs
  static const String baseUrl = 'https://api.vetbiotics.com';
  static const String baseUrlDev = 'https://dev-api.vetbiotics.com';

  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // User Management
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
  static const String userProfile = '/users/profile';
  static const String changePassword = '/users/change-password';

  // Clinic Management
  static const String clinics = '/clinics';
  static String clinicById(String id) => '/clinics/$id';
  static const String clinicSettings = '/clinics/settings';

  // Pet Management
  static const String pets = '/pets';
  static String petById(String id) => '/pets/$id';
  static String petsByOwner(String ownerId) => '/pets/owner/$ownerId';

  // Appointment Management
  static const String appointments = '/appointments';
  static String appointmentById(String id) => '/appointments/$id';
  static String appointmentsByDate(String date) => '/appointments/date/$date';
  static String appointmentsByDoctor(String doctorId) => '/appointments/doctor/$doctorId';

  // Medical Records
  static const String medicalRecords = '/medical-records';
  static String medicalRecordById(String id) => '/medical-records/$id';
  static String medicalRecordsByPet(String petId) => '/medical-records/pet/$petId';

  // Pharmacy & Inventory
  static const String medicines = '/medicines';
  static String medicineById(String id) => '/medicines/$id';
  static const String prescriptions = '/prescriptions';
  static String prescriptionById(String id) => '/prescriptions/$id';

  // Billing & Invoices
  static const String invoices = '/invoices';
  static String invoiceById(String id) => '/invoices/$id';
  static const String payments = '/payments';

  // Reports & Analytics
  static const String reports = '/reports';
  static const String dashboardStats = '/reports/dashboard';
  static const String revenueReport = '/reports/revenue';
  static const String appointmentReport = '/reports/appointments';

  // Notifications
  static const String notifications = '/notifications';
  static String notificationById(String id) => '/notifications/$id';
  static const String markAsRead = '/notifications/read';

  // File Upload
  static const String uploadFile = '/files/upload';
  static String fileById(String id) => '/files/$id';

  // Settings
  static const String appSettings = '/settings/app';
  static const String clinicSettingsEndpoint = '/settings/clinic';
}
