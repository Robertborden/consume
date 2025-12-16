import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  /// Format as relative time (e.g., "2 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inDays > 365) {
      final years = (diff.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} ${diff.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Format as relative future time (e.g., "in 2 days")
  String get timeUntil {
    final now = DateTime.now();
    final diff = difference(now);

    if (diff.isNegative) return 'Expired';

    if (diff.inDays > 0) {
      return 'in ${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'}';
    } else if (diff.inHours > 0) {
      return 'in ${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'}';
    } else if (diff.inMinutes > 0) {
      return 'in ${diff.inMinutes} ${diff.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return 'Expiring soon';
    }
  }

  /// Format as short date (e.g., "Dec 16")
  String get shortDate => DateFormat('MMM d').format(this);

  /// Format as full date (e.g., "December 16, 2025")
  String get fullDate => DateFormat('MMMM d, y').format(this);

  /// Format as date and time (e.g., "Dec 16, 9:00 AM")
  String get dateTime => DateFormat('MMM d, h:mm a').format(this);

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is within last 7 days
  bool get isThisWeek {
    final now = DateTime.now();
    final diff = now.difference(this);
    return diff.inDays < 7 && diff.inDays >= 0;
  }

  /// Start of day (midnight)
  DateTime get startOfDay => DateTime(year, month, day);

  /// End of day (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
}
