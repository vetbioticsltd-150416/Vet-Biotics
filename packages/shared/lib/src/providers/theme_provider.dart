import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vet_biotics_shared/shared.dart';

/// Provider for managing app theme and responsive design
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _animationsKey = 'animations_enabled';

  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  bool _animationsEnabled = true;
  bool _isInitialized = false;

  ThemeProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _themeMode = _getThemeModeFromPrefs();
    _animationsEnabled = _prefs.getBool(_animationsKey) ?? true;
    _isInitialized = true;
    notifyListeners();
  }

  bool get isInitialized => _isInitialized;
  ThemeMode get themeMode => _themeMode;
  bool get animationsEnabled => _animationsEnabled;

  /// Get current theme based on theme mode and system brightness
  ThemeMode _getThemeModeFromPrefs() {
    final modeString = _prefs.getString(_themeKey) ?? 'system';
    return AppTheme.getThemeMode(modeString);
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _prefs.setString(_themeKey, AppTheme.getThemeModeString(mode));
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Set system theme mode
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Set animations enabled/disabled
  Future<void> setAnimationsEnabled(bool enabled) async {
    if (_animationsEnabled == enabled) return;

    _animationsEnabled = enabled;
    await _prefs.setBool(_animationsKey, enabled);
    notifyListeners();
  }

  /// Get the appropriate theme data based on current mode
  ThemeData getThemeData(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return AppTheme.lightTheme;
      case ThemeMode.dark:
        return AppTheme.darkTheme;
      case ThemeMode.system:
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    }
  }

  /// Get theme mode description
  String get themeModeDescription {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Sáng';
      case ThemeMode.dark:
        return 'Tối';
      case ThemeMode.system:
        return 'Theo hệ thống';
    }
  }

  /// Check if current theme is dark
  bool isDarkMode(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }

  /// Get responsive padding
  EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1200) {
      // Desktop
      return const EdgeInsets.symmetric(horizontal: 200, vertical: 24);
    } else if (screenWidth >= 800) {
      // Tablet
      return const EdgeInsets.symmetric(horizontal: 100, vertical: 20);
    } else {
      // Mobile
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    }
  }

  /// Get responsive max width for content
  double getResponsiveMaxWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1200) {
      return 1200;
    } else if (screenWidth >= 800) {
      return 800;
    } else {
      return double.infinity;
    }
  }

  /// Get grid cross axis count based on screen size
  int getResponsiveGridCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1200) {
      return 4;
    } else if (screenWidth >= 800) {
      return 3;
    } else if (screenWidth >= 600) {
      return 2;
    } else {
      return 1;
    }
  }

  /// Check if device is mobile
  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;

  /// Check if device is tablet
  bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  /// Check if device is desktop
  bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;

  /// Get animation duration based on preferences
  Duration get animationDuration => _animationsEnabled ? const Duration(milliseconds: 300) : Duration.zero;

  /// Get fast animation duration
  Duration get fastAnimationDuration => _animationsEnabled ? const Duration(milliseconds: 150) : Duration.zero;

  /// Get slow animation duration
  Duration get slowAnimationDuration => _animationsEnabled ? const Duration(milliseconds: 500) : Duration.zero;

  /// Create animated transition
  PageTransitionsBuilder get pageTransitionBuilder =>
      _animationsEnabled ? const CupertinoPageTransitionsBuilder() : const FadeUpwardsPageTransitionsBuilder();
}

/// Custom page transition for no animations
class FadeUpwardsPageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeUpwardsPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}
