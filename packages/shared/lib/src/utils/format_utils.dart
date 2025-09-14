import 'package:intl/intl.dart';

/// Formatting utility functions
class FormatUtils {
  static final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  static final NumberFormat _numberFormat = NumberFormat.decimalPattern('vi_VN');

  /// Format currency
  static String formatCurrency(num amount, {String symbol = '₫'}) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: symbol);
    return format.format(amount);
  }

  /// Format number with thousands separator
  static String formatNumber(num number) {
    return _numberFormat.format(number);
  }

  /// Format percentage
  static String formatPercentage(num value, {int decimals = 1}) {
    final format = NumberFormat.percentPattern('vi_VN');
    format.minimumFractionDigits = decimals;
    format.maximumFractionDigits = decimals;
    return format.format(value / 100);
  }

  /// Format phone number
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length != 10) return phoneNumber;

    return '${phoneNumber.substring(0, 4)} ${phoneNumber.substring(4, 7)} ${phoneNumber.substring(7)}';
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      final kb = (bytes / 1024).toStringAsFixed(1);
      return '$kb KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
      return '$mb MB';
    } else {
      final gb = (bytes / (1024 * 1024 * 1024)).toStringAsFixed(1);
      return '$gb GB';
    }
  }

  /// Format duration
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Format date
  static String formatDate(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    final format = DateFormat(pattern, 'vi_VN');
    return format.format(date);
  }

  /// Format date time
  static String formatDateTime(DateTime dateTime) {
    final format = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');
    return format.format(dateTime);
  }

  /// Format time
  static String formatTime(DateTime time) {
    final format = DateFormat('HH:mm', 'vi_VN');
    return format.format(time);
  }

  /// Format relative time (time ago)
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  /// Format name (capitalize first letter of each word)
  static String formatName(String name) {
    if (name.isEmpty) return name;

    return name
        .split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : word)
        .join(' ');
  }

  /// Format address
  static String formatAddress(String address) {
    if (address.isEmpty) return address;

    // Capitalize first letter and add comma if needed
    final formatted = address.trim();
    if (formatted.isEmpty) return formatted;

    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  /// Format credit card number
  static String formatCreditCardNumber(String number) {
    final cleanNumber = number.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.length != 16) return number;

    return '${cleanNumber.substring(0, 4)} ${cleanNumber.substring(4, 8)} ${cleanNumber.substring(8, 12)} ${cleanNumber.substring(12)}';
  }

  /// Mask credit card number
  static String maskCreditCardNumber(String number) {
    final cleanNumber = number.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.length != 16) return number;

    return '**** **** **** ${cleanNumber.substring(12)}';
  }

  /// Format ID number
  static String formatIdNumber(String idNumber) {
    final cleanId = idNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanId.length == 12) {
      return '${cleanId.substring(0, 4)} ${cleanId.substring(4, 8)} ${cleanId.substring(8)}';
    }
    return idNumber;
  }

  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  /// Format ordinal number
  static String formatOrdinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }

    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  /// Format list as comma-separated string
  static String formatList(List<String> items, {String separator = ', ', String lastSeparator = ' và '}) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items.first;
    if (items.length == 2) return items.join(lastSeparator);

    final allButLast = items.sublist(0, items.length - 1).join(separator);
    return '$allButLast$lastSeparator${items.last}';
  }

  /// Remove diacritics from Vietnamese text
  static String removeDiacritics(String text) {
    const diacritics = {
      'à': 'a',
      'á': 'a',
      'ả': 'a',
      'ã': 'a',
      'ạ': 'a',
      'ă': 'a',
      'ằ': 'a',
      'ắ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'ặ': 'a',
      'â': 'a',
      'ầ': 'a',
      'ấ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ậ': 'a',
      'è': 'e',
      'é': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ẹ': 'e',
      'ê': 'e',
      'ề': 'e',
      'ế': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ệ': 'e',
      'ì': 'i',
      'í': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ị': 'i',
      'ò': 'o',
      'ó': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ọ': 'o',
      'ô': 'o',
      'ồ': 'o',
      'ố': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ộ': 'o',
      'ơ': 'o',
      'ờ': 'o',
      'ớ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ợ': 'o',
      'ù': 'u',
      'ú': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ụ': 'u',
      'ư': 'u',
      'ừ': 'u',
      'ứ': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ự': 'u',
      'ỳ': 'y',
      'ý': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'ỵ': 'y',
      'đ': 'd',
    };

    return text
        .toLowerCase()
        .split('')
        .map((char) {
          return diacritics[char] ?? char;
        })
        .join('');
  }
}
