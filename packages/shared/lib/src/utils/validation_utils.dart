/// Validation utility functions
class ValidationUtils {
  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }

    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất một chữ hoa';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất một chữ thường';
    }

    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất một số';
    }

    return null;
  }

  /// Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số điện thoại không được để trống';
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Số điện thoại không hợp lệ';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, {String fieldName = 'Trường này'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }

    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, {String fieldName = 'Trường này'}) {
    if (value == null || value.length < minLength) {
      return '$fieldName phải có ít nhất $minLength ký tự';
    }

    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, {String fieldName = 'Trường này'}) {
    if (value != null && value.length > maxLength) {
      return '$fieldName không được vượt quá $maxLength ký tự';
    }

    return null;
  }

  /// Validate numeric value
  static String? validateNumeric(String? value, {String fieldName = 'Trường này'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống';
    }

    if (double.tryParse(value) == null) {
      return '$fieldName phải là số';
    }

    return null;
  }

  /// Validate integer value
  static String? validateInteger(String? value, {String fieldName = 'Trường này'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống';
    }

    if (int.tryParse(value) == null) {
      return '$fieldName phải là số nguyên';
    }

    return null;
  }

  /// Validate date
  static String? validateDate(String? value, {String fieldName = 'Ngày'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống';
    }

    try {
      final date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) {
        return '$fieldName không được là ngày trong tương lai';
      }
    } catch (e) {
      return '$fieldName không hợp lệ';
    }

    return null;
  }

  /// Validate date of birth
  static String? validateDateOfBirth(String? value) {
    final dateError = validateDate(value, fieldName: 'Ngày sinh');
    if (dateError != null) return dateError;

    final date = DateTime.parse(value!);
    final age = DateTime.now().year - date.year;
    if (age < 0 || age > 150) {
      return 'Ngày sinh không hợp lệ';
    }

    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value, {String fieldName = 'URL'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống';
    }

    final urlRegex = RegExp(r'^https?://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(?:/.*)?$');

    if (!urlRegex.hasMatch(value)) {
      return '$fieldName không hợp lệ';
    }

    return null;
  }

  /// Validate file size
  static String? validateFileSize(int fileSizeInBytes, int maxSizeInMB) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    if (fileSizeInBytes > maxSizeInBytes) {
      return 'File không được vượt quá ${maxSizeInMB}MB';
    }

    return null;
  }

  /// Validate file extension
  static String? validateFileExtension(String fileName, List<String> allowedExtensions) {
    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'Chỉ chấp nhận file có định dạng: ${allowedExtensions.join(", ")}';
    }

    return null;
  }

  /// Validate multiple validations
  static String? validateMultiple(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }

    return null;
  }

  /// Check if all fields are valid
  static bool isValid(Map<String, String?> errors) {
    return errors.values.every((error) => error == null);
  }

  /// Get first error from map
  static String? getFirstError(Map<String, String?> errors) {
    return errors.values.firstWhere((error) => error != null, orElse: () => null);
  }
}
