import 'package:flutter/material.dart';

/// Application color palette
class ColorPalette {
  // Primary colors
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1565C0);

  // Secondary colors
  static const Color secondary = Color(0xFF9C27B0);
  static const Color secondaryLight = Color(0xFFBA68C8);
  static const Color secondaryDark = Color(0xFF7B1FA2);

  // Accent colors
  static const Color accent = Color(0xFFFF9800);
  static const Color accentLight = Color(0xFFFFB74D);
  static const Color accentDark = Color(0xFFF57C00);

  // Surface colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF121212);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);
  static const Color textHintDark = Color(0xFF757575);

  // Error colors
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);

  // Success colors
  static const Color success = Color(0xFF388E3C);
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF2E7D32);

  // Warning colors
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFE65100);

  // Info colors
  static const Color info = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFF42A5F5);
  static const Color infoDark = Color(0xFF1565C0);

  // Divider colors
  static const Color divider = Color(0xFFBDBDBD);
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);

  // Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);

  // Card colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF1E1E1E);

  // Status colors
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color busy = Color(0xFFFF9800);
  static const Color away = Color(0xFFFFC107);

  // Veterinary specific colors
  static const Color petPrimary = Color(0xFF8BC34A); // Light green for pets
  static const Color petSecondary = Color(0xFFFF5722); // Deep orange for medical
  static const Color clinicPrimary = Color(0xFF3F51B5); // Indigo for clinics
  static const Color emergency = Color(0xFFE53935); // Red for emergencies

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, errorLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Get color from status string
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'online':
        return online;
      case 'inactive':
      case 'offline':
        return offline;
      case 'busy':
        return busy;
      case 'away':
        return away;
      case 'pending':
        return warning;
      case 'completed':
        return success;
      case 'cancelled':
      case 'error':
        return error;
      default:
        return textSecondary;
    }
  }

  // Get color from role string
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return primary;
      case 'doctor':
        return clinicPrimary;
      case 'staff':
        return secondary;
      case 'client':
        return accent;
      default:
        return textSecondary;
    }
  }

  // Get color with opacity
  static Color withOpacity(Color color, double opacity) => color.withValues(alpha: opacity);

  // Blend two colors
  static Color blend(Color color1, Color color2, double ratio) {
    final r = ((color1.r * 255.0).round() * ratio + (color2.r * 255.0).round() * (1 - ratio)).round();
    final g = ((color1.g * 255.0).round() * ratio + (color2.g * 255.0).round() * (1 - ratio)).round();
    final b = ((color1.b * 255.0).round() * ratio + (color2.b * 255.0).round() * (1 - ratio)).round();
    final a = ((color1.a * 255.0).round() * ratio + (color2.a * 255.0).round() * (1 - ratio)).round();
    return Color.fromARGB(a, r, g, b);
  }

  // Get contrasting text color for background
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimary : textPrimaryDark;
  }
}
