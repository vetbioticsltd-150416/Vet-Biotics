import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Utility class for input validation and conversion
class InputConverter {
  /// Convert string to unsigned int
  Either<Failure, int> stringToUnsignedInteger(String str) {
    try {
      final integer = int.parse(str);
      if (integer < 0) {
        return const Left(ValidationFailure('Number must be positive'));
      }
      return Right(integer);
    } on FormatException {
      return const Left(ValidationFailure('Invalid number format'));
    }
  }

  /// Convert string to double
  Either<Failure, double> stringToDouble(String str) {
    try {
      final doubleValue = double.parse(str);
      return Right(doubleValue);
    } on FormatException {
      return const Left(ValidationFailure('Invalid number format'));
    }
  }

  /// Validate email format
  Either<Failure, String> validateEmail(String email) {
    const emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    if (RegExp(emailRegex).hasMatch(email)) {
      return Right(email);
    } else {
      return const Left(ValidationFailure('Invalid email format'));
    }
  }

  /// Validate phone number format
  Either<Failure, String> validatePhoneNumber(String phone) {
    // Simple phone validation - adjust as needed
    const phoneRegex = r'^\+?[\d\s\-\(\)]{10,}$';
    if (RegExp(phoneRegex).hasMatch(phone)) {
      return Right(phone);
    } else {
      return const Left(ValidationFailure('Invalid phone number format'));
    }
  }

  /// Validate password strength
  Either<Failure, String> validatePassword(String password) {
    if (password.length < 8) {
      return const Left(ValidationFailure('Password must be at least 8 characters'));
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return const Left(ValidationFailure('Password must contain at least one uppercase letter'));
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return const Left(ValidationFailure('Password must contain at least one lowercase letter'));
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return const Left(ValidationFailure('Password must contain at least one number'));
    }
    return Right(password);
  }

  /// Validate required string
  Either<Failure, String> validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return Left(ValidationFailure('$fieldName is required'));
    }
    return Right(value.trim());
  }

  /// Validate string length
  Either<Failure, String> validateLength(String value, int minLength, int maxLength, String fieldName) {
    if (value.length < minLength) {
      return Left(ValidationFailure('$fieldName must be at least $minLength characters'));
    }
    if (value.length > maxLength) {
      return Left(ValidationFailure('$fieldName must not exceed $maxLength characters'));
    }
    return Right(value);
  }

  /// Sanitize string input
  String sanitizeString(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Convert to title case
  String toTitleCase(String input) {
    if (input.isEmpty) return input;
    return input
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult(this.isValid, [this.errorMessage]);

  factory ValidationResult.valid() => const ValidationResult(true);
  factory ValidationResult.invalid(String message) => ValidationResult(false, message);
}
