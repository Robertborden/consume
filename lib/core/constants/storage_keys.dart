/// Keys for SharedPreferences and SecureStorage
class StorageKeys {
  StorageKeys._();

  // User Preferences
  static const String themeMode = 'theme_mode';
  static const String onboardingComplete = 'onboarding_complete';
  static const String dailyReminderEnabled = 'daily_reminder_enabled';
  static const String dailyReminderTime = 'daily_reminder_time';
  static const String defaultExpiryDays = 'default_expiry_days';

  // Cache
  static const String lastSyncTime = 'last_sync_time';
  static const String cachedUserId = 'cached_user_id';

  // Secure Storage
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
}
