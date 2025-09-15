import 'package:flutter/material.dart';
import 'package:vet_biotics_shared/shared.dart';

/// Application text styles
class TextStyles {
  // Light theme text theme
  static TextTheme get textTheme => const TextTheme(
    displayLarge: headline1,
    displayMedium: headline2,
    displaySmall: headline3,
    headlineLarge: headline4,
    headlineMedium: headline5,
    headlineSmall: headline6,
    titleLarge: subtitle1,
    titleMedium: subtitle2,
    titleSmall: body1,
    bodyLarge: body1,
    bodyMedium: body2,
    bodySmall: caption,
    labelLarge: button,
    labelMedium: button,
    labelSmall: overline,
  );

  // Dark theme text theme
  static TextTheme get textThemeDark => const TextTheme(
    displayLarge: headline1Dark,
    displayMedium: headline2Dark,
    displaySmall: headline3Dark,
    headlineLarge: headline4Dark,
    headlineMedium: headline5Dark,
    headlineSmall: headline6Dark,
    titleLarge: subtitle1Dark,
    titleMedium: subtitle2Dark,
    titleSmall: body1Dark,
    bodyLarge: body1Dark,
    bodyMedium: body2Dark,
    bodySmall: captionDark,
    labelLarge: buttonDark,
    labelMedium: buttonDark,
    labelSmall: overlineDark,
  );

  // Headlines
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    color: ColorPalette.textPrimary,
    letterSpacing: -1.5,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
    color: ColorPalette.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textPrimary,
  );

  static const TextStyle headline4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textPrimary,
    letterSpacing: 0.25,
  );

  static const TextStyle headline5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textPrimary,
  );

  static const TextStyle headline6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: ColorPalette.textPrimary,
    letterSpacing: 0.15,
  );

  // Subtitles
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textPrimary,
    letterSpacing: 0.15,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ColorPalette.textPrimary,
    letterSpacing: 0.1,
  );

  // Body text
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textPrimary,
    letterSpacing: 0.25,
  );

  // Caption and overline
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textSecondary,
    letterSpacing: 0.4,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textSecondary,
    letterSpacing: 1.5,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ColorPalette.primary,
    letterSpacing: 1.25,
  );

  // Dark theme variants
  static const TextStyle headline1Dark = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    color: ColorPalette.textPrimaryDark,
    letterSpacing: -1.5,
  );

  static const TextStyle headline2Dark = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
    color: ColorPalette.textPrimaryDark,
    letterSpacing: -0.5,
  );

  static const TextStyle headline3Dark = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textPrimaryDark,
  );

  static const TextStyle headline4Dark = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textPrimaryDark,
    letterSpacing: 0.25,
  );

  static const TextStyle headline5Dark = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textPrimaryDark,
  );

  static const TextStyle headline6Dark = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: ColorPalette.textPrimaryDark,
    letterSpacing: 0.15,
  );

  static const TextStyle subtitle1Dark = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textPrimaryDark,
    letterSpacing: 0.15,
  );

  static const TextStyle subtitle2Dark = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ColorPalette.textPrimaryDark,
    letterSpacing: 0.1,
  );

  static const TextStyle body1Dark = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textPrimaryDark,
    letterSpacing: 0.5,
  );

  static const TextStyle body2Dark = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textPrimaryDark,
    letterSpacing: 0.25,
  );

  static const TextStyle captionDark = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textSecondaryDark,
    letterSpacing: 0.4,
  );

  static const TextStyle overlineDark = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: ColorPalette.textSecondaryDark,
    letterSpacing: 1.5,
  );

  static const TextStyle buttonDark = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ColorPalette.primary,
    letterSpacing: 1.25,
  );

  // Custom text styles for veterinary app
  static const TextStyle petName = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: ColorPalette.petPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle medicalTerm = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ColorPalette.petSecondary,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle emergencyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: ColorPalette.emergency,
    letterSpacing: 0.5,
  );

  static const TextStyle statusActive = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ColorPalette.success,
  );

  static const TextStyle statusInactive = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ColorPalette.textSecondary,
  );

  static const TextStyle priceText = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ColorPalette.primary);

  static const TextStyle discountText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ColorPalette.error,
    decoration: TextDecoration.lineThrough,
  );

  // Helper methods to create custom styles
  static TextStyle withColor(TextStyle style, Color color) => style.copyWith(color: color);

  static TextStyle withWeight(TextStyle style, FontWeight weight) => style.copyWith(fontWeight: weight);

  static TextStyle withSize(TextStyle style, double size) => style.copyWith(fontSize: size);

  static TextStyle withOpacity(TextStyle style, double opacity) =>
      style.copyWith(color: style.color?.withValues(alpha: opacity));

  // Create custom text style
  static TextStyle custom({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = ColorPalette.textPrimary,
    double letterSpacing = 0.0,
    double height = 1.0,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) => TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
    fontStyle: fontStyle,
  );
}
