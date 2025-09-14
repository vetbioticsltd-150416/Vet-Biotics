import 'package:flutter/material.dart';

/// Extension methods for BuildContext
extension ContextExtensions on BuildContext {
  /// Get theme data
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => mediaQuery.size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Check if device is mobile
  bool get isMobile => screenWidth < 600;

  /// Check if device is tablet
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;

  /// Check if device is desktop
  bool get isDesktop => screenWidth >= 1200;

  /// Get padding
  EdgeInsets get padding => mediaQuery.padding;

  /// Get view insets (keyboard)
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Get safe area height
  double get safeHeight => screenHeight - padding.top - padding.bottom;

  /// Show snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show loading dialog
  void showLoadingDialog() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  /// Hide loading dialog
  void hideLoadingDialog() {
    Navigator.of(this).pop();
  }

  /// Navigate to new screen
  Future<T?> navigateTo<T>(Widget screen) {
    return Navigator.push<T>(this, MaterialPageRoute(builder: (context) => screen));
  }

  /// Navigate and replace current screen
  Future<T?> navigateAndReplace<T>(Widget screen) {
    return Navigator.pushReplacement<T, dynamic>(this, MaterialPageRoute(builder: (context) => screen));
  }

  /// Navigate and remove all previous screens
  Future<T?> navigateAndRemoveUntil<T>(Widget screen, {String? routeName}) {
    return Navigator.pushAndRemoveUntil<T>(
      this,
      MaterialPageRoute(builder: (context) => screen),
      (route) => routeName != null ? route.settings.name == routeName : false,
    );
  }

  /// Go back
  void goBack<T>({T? result}) {
    Navigator.of(this).pop(result);
  }

  /// Check if keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// Get keyboard height
  double get keyboardHeight => viewInsets.bottom;
}
