/// Route paths for the application
class RoutePaths {
  // Auth paths
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password/:token';
  static const String verifyEmail = '/verify-email';

  // Main paths
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Pet paths
  static const String pets = '/pets';
  static String petDetail(String id) => '/pets/$id';
  static const String addPet = '/pets/add';
  static String editPet(String id) => '/pets/$id/edit';

  // Appointment paths
  static const String appointments = '/appointments';
  static String appointmentDetail(String id) => '/appointments/$id';
  static const String bookAppointment = '/appointments/book';
  static String editAppointment(String id) => '/appointments/$id/edit';

  // Medical paths
  static const String medicalRecords = '/medical-records';
  static String medicalRecordDetail(String id) => '/medical-records/$id';
  static const String addMedicalRecord = '/medical-records/add';

  // Clinic paths
  static const String clinics = '/clinics';
  static String clinicDetail(String id) => '/clinics/$id';
  static String clinicDashboard(String id) => '/clinics/$id/dashboard';
  static String clinicSettings(String id) => '/clinics/$id/settings';

  // User paths
  static const String users = '/users';
  static String userDetail(String id) => '/users/$id';
  static const String userProfile = '/users/profile';

  // Admin paths
  static const String admin = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminClinics = '/admin/clinics';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminSettings = '/admin/settings';

  // Common paths
  static const String notifications = '/notifications';
  static const String search = '/search';
  static const String help = '/help';
  static const String about = '/about';

  // Error paths
  static const String notFound = '/404';
  static const String error = '/error';
  static const String maintenance = '/maintenance';
}
