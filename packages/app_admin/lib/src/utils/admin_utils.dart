import 'package:intl/intl.dart';

class AdminUtils {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  static String getStatusText(bool isActive) {
    return isActive ? 'Active' : 'Inactive';
  }

  static Color getStatusColor(bool isActive) {
    return isActive ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
  }

  static String getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return 'Super Admin';
      case 'clinicadmin':
        return 'Clinic Admin';
      case 'veterinarian':
        return 'Veterinarian';
      case 'receptionist':
        return 'Receptionist';
      case 'client':
        return 'Client';
      default:
        return role;
    }
  }

  static List<String> getClinicStatuses() {
    return ['Active', 'Inactive', 'Pending', 'Suspended'];
  }

  static List<String> getUserRoles() {
    return ['Super Admin', 'Clinic Admin', 'Veterinarian', 'Receptionist', 'Client'];
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    return phoneRegex.hasMatch(phone);
  }

  static String generateClinicId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'CLINIC_$timestamp';
  }

  static String generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'USER_$timestamp';
  }
}
