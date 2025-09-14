/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Vet Biotics';
  static const String appVersion = '1.0.0';

  // API
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const Duration cacheDuration = Duration(hours: 24);

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentExtensions = ['pdf', 'doc', 'docx'];

  // Date/Time
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Permissions
  static const String permissionCamera = 'camera';
  static const String permissionStorage = 'storage';
  static const String permissionLocation = 'location';

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleDoctor = 'doctor';
  static const String roleStaff = 'staff';
  static const String roleClient = 'client';
}
