// lib/utils/extensions/date_extensions.dart

extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
  
  bool isToday() {
    final now = DateTime.now();
    return isSameDate(now);
  }
  
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
  
  DateTime addDays(int days) => add(Duration(days: days));
  DateTime subtractDays(int days) => subtract(Duration(days: days));
  
  int daysSince(DateTime other) {
    return difference(other).inDays;
  }
  
  String format(String pattern) {
    // Simple formatting - in production use intl package
    if (pattern == 'yyyy-MM-dd') {
      return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    }
    if (pattern == 'MMM dd') {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[month - 1]} ${day.toString().padLeft(2, '0')}';
    }
    return toString();
  }
  
  bool isBetween(DateTime start, DateTime end) {
    return !isBefore(start) && !isAfter(end);
  }
}
