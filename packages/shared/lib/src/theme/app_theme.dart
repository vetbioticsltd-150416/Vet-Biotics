import 'package:flutter/material.dart';
import 'package:shared/src/theme/color_palette.dart';
import 'package:shared/src/theme/text_styles.dart';

/// Application theme configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: ColorPalette.primary,
        onPrimary: Colors.white,
        primaryContainer: ColorPalette.primaryLight,
        onPrimaryContainer: ColorPalette.primaryDark,

        secondary: ColorPalette.secondary,
        onSecondary: Colors.white,
        secondaryContainer: ColorPalette.secondaryLight,
        onSecondaryContainer: ColorPalette.secondaryDark,

        tertiary: ColorPalette.accent,
        onTertiary: Colors.white,
        tertiaryContainer: ColorPalette.accentLight,
        onTertiaryContainer: ColorPalette.accentDark,

        error: ColorPalette.error,
        onError: Colors.white,
        errorContainer: ColorPalette.errorLight,
        onErrorContainer: ColorPalette.errorDark,

        surface: ColorPalette.surface,
        onSurface: ColorPalette.textPrimary,
        surfaceContainer: ColorPalette.surfaceLight,
        onSurfaceVariant: ColorPalette.textSecondary,

        outline: ColorPalette.divider,
        outlineVariant: ColorPalette.dividerLight,
      ),

      // Text theme
      textTheme: TextStyles.textTheme,

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorPalette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyles.headline6,
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: ColorPalette.primary)),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorPalette.primary,
          side: const BorderSide(color: ColorPalette.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorPalette.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorPalette.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorPalette.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorPalette.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorPalette.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorPalette.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyles.body2.copyWith(color: ColorPalette.textSecondary),
        hintStyle: TextStyles.body2.copyWith(color: ColorPalette.textHint),
        errorStyle: TextStyles.caption.copyWith(color: ColorPalette.error),
      ),

      // Card theme
      cardTheme: CardTheme(
        color: ColorPalette.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: ColorPalette.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ColorPalette.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      ),

      // SnackBar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ColorPalette.surfaceDark,
        contentTextStyle: TextStyles.body2.copyWith(color: Colors.white),
        actionTextColor: ColorPalette.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      // Tab bar theme
      tabBarTheme: TabBarTheme(
        labelColor: ColorPalette.primary,
        unselectedLabelColor: ColorPalette.textSecondary,
        indicatorColor: ColorPalette.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyles.button,
        unselectedLabelStyle: TextStyles.button,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ColorPalette.primary,
        foregroundColor: Colors.white,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ColorPalette.primary,
        linearTrackColor: ColorPalette.divider,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(color: ColorPalette.divider, thickness: 1, space: 1),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorPalette.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorPalette.primary;
          }
          return ColorPalette.textSecondary;
        }),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorPalette.primary;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorPalette.primary.withOpacity(0.3);
          }
          return ColorPalette.divider;
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: ColorPalette.primary,
        onPrimary: Colors.white,
        primaryContainer: ColorPalette.primaryDark,
        onPrimaryContainer: ColorPalette.primaryLight,

        secondary: ColorPalette.secondary,
        onSecondary: Colors.white,
        secondaryContainer: ColorPalette.secondaryDark,
        onSecondaryContainer: ColorPalette.secondaryLight,

        tertiary: ColorPalette.accent,
        onTertiary: Colors.white,
        tertiaryContainer: ColorPalette.accentDark,
        onTertiaryContainer: ColorPalette.accentLight,

        error: ColorPalette.error,
        onError: Colors.white,
        errorContainer: ColorPalette.errorDark,
        onErrorContainer: ColorPalette.errorLight,

        surface: ColorPalette.surfaceDark,
        onSurface: ColorPalette.textPrimaryDark,
        surfaceContainer: ColorPalette.surfaceDark,
        onSurfaceVariant: ColorPalette.textSecondaryDark,

        outline: ColorPalette.dividerDark,
        outlineVariant: ColorPalette.dividerDark,
      ),

      // Text theme
      textTheme: TextStyles.textThemeDark,

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorPalette.surfaceDark,
        foregroundColor: ColorPalette.textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyles.headline6Dark,
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: ColorPalette.primary)),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorPalette.primary,
          side: const BorderSide(color: ColorPalette.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorPalette.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorPalette.dividerDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorPalette.dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorPalette.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorPalette.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorPalette.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyles.body2Dark.copyWith(color: ColorPalette.textSecondaryDark),
        hintStyle: TextStyles.body2Dark.copyWith(color: ColorPalette.textHintDark),
        errorStyle: TextStyles.captionDark.copyWith(color: ColorPalette.error),
      ),

      // Card theme
      cardTheme: CardTheme(
        color: ColorPalette.surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: ColorPalette.surfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ColorPalette.surfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      ),

      // SnackBar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ColorPalette.surface,
        contentTextStyle: TextStyles.body2Dark.copyWith(color: ColorPalette.textPrimaryDark),
        actionTextColor: ColorPalette.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      // Tab bar theme
      tabBarTheme: TabBarTheme(
        labelColor: ColorPalette.primary,
        unselectedLabelColor: ColorPalette.textSecondaryDark,
        indicatorColor: ColorPalette.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyles.buttonDark,
        unselectedLabelStyle: TextStyles.buttonDark,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ColorPalette.primary,
        foregroundColor: Colors.white,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ColorPalette.primary,
        linearTrackColor: ColorPalette.dividerDark,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(color: ColorPalette.dividerDark, thickness: 1, space: 1),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorPalette.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorPalette.primary;
          }
          return ColorPalette.textSecondaryDark;
        }),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorPalette.primary;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorPalette.primary.withOpacity(0.3);
          }
          return ColorPalette.dividerDark;
        }),
      ),
    );
  }

  /// Get theme mode from string
  static ThemeMode getThemeMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Get theme mode as string
  static String getThemeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }
}
