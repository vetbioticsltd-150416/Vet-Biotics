import 'package:intl/intl.dart';

/// Date utility functions
class DateUtils {
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Format date to string
  static String formatDate(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    final formatter = DateFormat(pattern);
    return formatter.format(date);
  }

  /// Format time to string
  static String formatTime(DateTime time) => _timeFormat.format(time);

  /// Format date and time to string
  static String formatDateTime(DateTime dateTime) => _dateTimeFormat.format(dateTime);

  /// Parse date from string
  static DateTime? parseDate(String dateString, {String pattern = 'dd/MM/yyyy'}) {
    try {
      final formatter = DateFormat(pattern);
      return formatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse date time from string
  static DateTime? parseDateTime(String dateTimeString) {
    try {
      return _dateTimeFormat.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  /// Get current date without time
  static DateTime getCurrentDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

  /// Get end of day
  static DateTime endOfDay(DateTime date) => DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return startOfDay(monday);
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final sunday = date.add(Duration(days: 7 - date.weekday));
    return endOfDay(sunday);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    return DateTime(nextMonth.year, nextMonth.month, 0, 23, 59, 59, 999);
  }

  /// Get start of year
  static DateTime startOfYear(DateTime date) => DateTime(date.year, 1, 1);

  /// Get end of year
  static DateTime endOfYear(DateTime date) => DateTime(date.year, 12, 31, 23, 59, 59, 999);

  /// Add days to date
  static DateTime addDays(DateTime date, int days) => date.add(Duration(days: days));

  /// Subtract days from date
  static DateTime subtractDays(DateTime date, int days) => date.subtract(Duration(days: days));

  /// Add months to date
  static DateTime addMonths(DateTime date, int months) {
    final newMonth = date.month + months;
    final newYear = date.year + (newMonth - 1) ~/ 12;
    final adjustedMonth = (newMonth - 1) % 12 + 1;
    return DateTime(newYear, adjustedMonth, date.day);
  }

  /// Subtract months from date
  static DateTime subtractMonths(DateTime date, int months) => addMonths(date, -months);

  /// Add years to date
  static DateTime addYears(DateTime date, int years) => DateTime(date.year + years, date.month, date.day);

  /// Subtract years from date
  static DateTime subtractYears(DateTime date, int years) => addYears(date, -years);

  /// Calculate age from birth date
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) => date.isBefore(DateTime.now());

  /// Check if date is in the future
  static bool isFuture(DateTime date) => date.isAfter(DateTime.now());

  /// Get time ago string
  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

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

  /// Get days in month
  static int getDaysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  /// Check if year is leap year
  static bool isLeapYear(int year) => year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  /// Get week number of year
  static int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).floor() + 1;
  }

  /// Get list of dates in a range
  static List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = startOfDay(start);

    while (current.isBefore(end) || current.isSameDay(end)) {
      dates.add(current);
      current = addDays(current, 1);
    }

    return dates;
  }

  /// Check if two dates are same day
  static bool isSameDay(DateTime date1, DateTime date2) =>
      date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;

  /// Check if date is between two dates
  static bool isBetween(DateTime date, DateTime start, DateTime end) => date.isAfter(start) && date.isBefore(end);
}

extension DateTimeUtils on DateTime {
  /// Format date using DateUtils
  String format([String pattern = 'dd/MM/yyyy']) => DateUtils.formatDate(this, pattern: pattern);

  /// Check if date is same day
  bool isSameDay(DateTime other) => DateUtils.isSameDay(this, other);

  /// Check if date is between two dates
  bool isBetween(DateTime start, DateTime end) => DateUtils.isBetween(this, start, end);

  /// Get time ago
  String get timeAgo => DateUtils.getTimeAgo(this);

  /// Add days
  DateTime addDays(int days) => DateUtils.addDays(this, days);

  /// Subtract days
  DateTime subtractDays(int days) => DateUtils.subtractDays(this, days);

  /// Add months
  DateTime addMonths(int months) => DateUtils.addMonths(this, months);

  /// Subtract months
  DateTime subtractMonths(int months) => DateUtils.subtractMonths(this, months);

  /// Add years
  DateTime addYears(int years) => DateUtils.addYears(this, years);

  /// Subtract years
  DateTime subtractYears(int years) => DateUtils.subtractYears(this, years);
}
