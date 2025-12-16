import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../constants/app_constants.dart';

/// Service for handling local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - navigate to specific screen based on payload
    final payload = response.payload;
    if (payload != null) {
      // Parse payload and navigate accordingly
      // This will be handled by the app's navigation system
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iOS = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    if (iOS != null) {
      final granted = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// Schedule daily review reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      NotificationIds.dailyReminder,
      'Time to review your saved content!',
      'You have items waiting to be reviewed. Don\'t let them expire!',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminders',
          channelDescription: 'Daily reminder to review saved content',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule expiration warning notification
  Future<void> scheduleExpirationWarning({
    required String itemId,
    required String itemTitle,
    required DateTime expiresAt,
  }) async {
    final warningTime = expiresAt.subtract(
      const Duration(hours: AppConstants.expirationWarningHours),
    );

    if (warningTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      itemId.hashCode,
      'Content expiring soon!',
      '"$itemTitle" will expire in ${AppConstants.expirationWarningHours} hours. Review it now!',
      tz.TZDateTime.from(warningTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'expiration_warning',
          'Expiration Warnings',
          channelDescription: 'Notifications when content is about to expire',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'item:$itemId',
    );
  }

  /// Show streak achievement notification
  Future<void> showStreakAchievement(int streakDays) async {
    String title;
    String body;

    if (streakDays == 7) {
      title = '🔥 One Week Streak!';
      body = 'You\'ve reviewed content for 7 days in a row! Keep it up!';
    } else if (streakDays == 30) {
      title = '🏆 One Month Streak!';
      body = 'Amazing! 30 days of consistent content review!';
    } else if (streakDays % 100 == 0) {
      title = '⭐ $streakDays Day Streak!';
      body = 'Incredible dedication! You\'re a content consumption master!';
    } else {
      return; // No notification for other streak counts
    }

    await _notifications.show(
      NotificationIds.streakAchievement,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Achievements',
          channelDescription: 'Achievement notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Show item saved confirmation
  Future<void> showItemSaved(String title) async {
    await _notifications.show(
      NotificationIds.itemSaved,
      'Content Saved!',
      '"$title" has been added to your list.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'item_saved',
          'Item Saved',
          channelDescription: 'Confirmation when content is saved',
          importance: Importance.low,
          priority: Priority.low,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get the next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}

/// Notification IDs for different notification types
class NotificationIds {
  static const int dailyReminder = 1;
  static const int streakAchievement = 2;
  static const int itemSaved = 3;
  // Expiration warnings use item.hashCode as ID
}
