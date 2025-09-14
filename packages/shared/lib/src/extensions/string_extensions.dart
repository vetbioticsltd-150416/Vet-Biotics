import 'package:intl/intl.dart';

/// Extension methods for String
extension StringExtensions on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalize first letter of each word
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.isNotEmpty ? word.capitalize() : word).join(' ');
  }

  /// Check if string is a valid email
  bool isValidEmail() {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegex.hasMatch(this);
  }

  /// Check if string is a valid phone number
  bool isValidPhoneNumber() {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(this);
  }

  /// Check if string contains only numbers
  bool isNumeric() {
    final numericRegex = RegExp(r'^\d+$');
    return numericRegex.hasMatch(this);
  }

  /// Check if string contains only alphabets
  bool isAlphabetic() {
    final alphabeticRegex = RegExp(r'^[a-zA-Z\s]+$');
    return alphabeticRegex.hasMatch(this);
  }

  /// Remove all whitespace
  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Check if string is empty or null
  bool get isNullOrEmpty => trim().isEmpty;

  /// Check if string is not empty and not null
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Convert to camel case
  String toCamelCase() {
    if (isEmpty) return this;
    final words = split(RegExp(r'[\s_-]+'));
    final camelCase = words[0].toLowerCase() + words.skip(1).map((word) => word.capitalize()).join('');
    return camelCase;
  }

  /// Convert to snake case
  String toSnakeCase() {
    if (isEmpty) return this;
    return replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match.group(1)}_${match.group(2)}').toLowerCase();
  }

  /// Format as currency
  String formatAsCurrency({String symbol = '\$', String locale = 'en_US'}) {
    final number = double.tryParse(this);
    if (number == null) return this;

    final format = NumberFormat.currency(locale: locale, symbol: symbol);
    return format.format(number);
  }

  /// Format as phone number
  String formatAsPhoneNumber({String pattern = '###-###-####'}) {
    if (isEmpty) return this;

    final cleanNumber = replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.length != 10) return this;

    final formatted = pattern.replaceAllMapped(
      RegExp(r'#'),
      (match) => cleanNumber[pattern.indexOf('#', match.start) % cleanNumber.length],
    );

    return formatted;
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Get file extension
  String get fileExtension {
    final lastDot = lastIndexOf('.');
    return lastDot != -1 ? substring(lastDot + 1).toLowerCase() : '';
  }

  /// Get file name without extension
  String get fileNameWithoutExtension {
    final lastDot = lastIndexOf('.');
    return lastDot != -1 ? substring(0, lastDot) : this;
  }

  /// Convert to base64 (simple implementation)
  String toBase64() {
    final bytes = codeUnits;
    return String.fromCharCodes(bytes);
  }

  /// Remove special characters
  String removeSpecialCharacters() {
    return replaceAll(RegExp(r'[^\w\s]'), '');
  }

  /// Check if string contains only digits and letters
  bool isAlphanumeric() {
    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
    return alphanumericRegex.hasMatch(this);
  }
}
