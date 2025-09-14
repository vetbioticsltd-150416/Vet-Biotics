import 'package:intl/intl.dart';

/// Extension methods for DateTime
extension DateTimeExtensions on DateTime {
  /// Format date as string
  String format([String pattern = 'dd/MM/yyyy']) {
    final formatter = DateFormat(pattern);
    return formatter.format(this);
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
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

  /// Add days to date
  DateTime addDays(int days) => add(Duration(days: days));

  /// Subtract days from date
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// Add months to date
  DateTime addMonths(int months) {
    final newMonth = month + months;
    final newYear = year + (newMonth - 1) ~/ 12;
    final adjustedMonth = (newMonth - 1) % 12 + 1;
    return DateTime(newYear, adjustedMonth, day);
  }

  /// Subtract months from date
  DateTime subtractMonths(int months) => addMonths(-months);

  /// Add years to date
  DateTime addYears(int years) => DateTime(year + years, month, day);

  /// Subtract years from date
  DateTime subtractYears(int years) => addYears(-years);

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Get start of week (Monday)
  DateTime get startOfWeek {
    final monday = subtract(Duration(days: weekday - 1));
    return monday.startOfDay;
  }

  /// Get end of week (Sunday)
  DateTime get endOfWeek {
    final sunday = add(Duration(days: 7 - weekday));
    return sunday.endOfDay;
  }

  /// Get start of month
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Get end of month
  DateTime get endOfMonth {
    final nextMonth = addMonths(1);
    return DateTime(nextMonth.year, nextMonth.month, 0).endOfDay;
  }

  /// Get start of year
  DateTime get startOfYear => DateTime(year, 1, 1);

  /// Get end of year
  DateTime get endOfYear => DateTime(year, 12, 31).endOfDay;

  /// Check if date is between two dates
  bool isBetween(DateTime start, DateTime end) {
    return isAfter(start) && isBefore(end);
  }

  /// Check if date is same day as another date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Check if date is same week as another date
  bool isSameWeek(DateTime other) {
    final startOfThisWeek = startOfWeek;
    final startOfOtherWeek = other.startOfWeek;
    return startOfThisWeek.isSameDay(startOfOtherWeek);
  }

  /// Check if date is same month as another date
  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  /// Check if date is same year as another date
  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  /// Get age from birth date
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Get days in month
  int get daysInMonth {
    final nextMonth = addMonths(1);
    return DateTime(nextMonth.year, nextMonth.month, 0).day;
  }

  /// Get week number of year
  int get weekNumber {
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysSinceFirstDay = difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).floor() + 1;
  }
}
