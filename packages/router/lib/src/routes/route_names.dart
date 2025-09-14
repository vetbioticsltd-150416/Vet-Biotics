/// Route names for the application
class RouteNames {
  // Auth routes
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot_password';
  static const String resetPassword = 'reset_password';
  static const String verifyEmail = 'verify_email';

  // Main routes
  static const String home = 'home';
  static const String dashboard = 'dashboard';
  static const String profile = 'profile';
  static const String settings = 'settings';

  // Pet routes
  static const String pets = 'pets';
  static const String petDetail = 'pet_detail';
  static const String addPet = 'add_pet';
  static const String editPet = 'edit_pet';

  // Appointment routes
  static const String appointments = 'appointments';
  static const String appointmentDetail = 'appointment_detail';
  static const String bookAppointment = 'book_appointment';
  static const String editAppointment = 'edit_appointment';

  // Medical routes
  static const String medicalRecords = 'medical_records';
  static const String medicalRecordDetail = 'medical_record_detail';
  static const String addMedicalRecord = 'add_medical_record';

  // Clinic routes
  static const String clinics = 'clinics';
  static const String clinicDetail = 'clinic_detail';
  static const String clinicDashboard = 'clinic_dashboard';
  static const String clinicSettings = 'clinic_settings';

  // User routes
  static const String users = 'users';
  static const String userDetail = 'user_detail';
  static const String userProfile = 'user_profile';

  // Admin routes
  static const String admin = 'admin';
  static const String adminDashboard = 'admin_dashboard';
  static const String adminUsers = 'admin_users';
  static const String adminClinics = 'admin_clinics';
  static const String adminAnalytics = 'admin_analytics';
  static const String adminSettings = 'admin_settings';

  // Common routes
  static const String notifications = 'notifications';
  static const String search = 'search';
  static const String help = 'help';
  static const String about = 'about';

  // Error routes
  static const String notFound = 'not_found';
  static const String error = 'error';
  static const String maintenance = 'maintenance';
}
