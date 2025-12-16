/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'CONSUME';
  static const String appTagline = 'Save Less. Consume More.';
  static const String appVersion = '1.0.0';

  // Default Settings
  static const int defaultExpiryDays = 7;
  static const String defaultReminderTime = '09:00';
  static const int maxFreeItems = 50;

  // Swipe Thresholds
  static const double swipeThreshold = 100.0;
  static const double swipeVelocityThreshold = 300.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Pagination
  static const int defaultPageSize = 20;

  // Cache
  static const Duration cacheExpiry = Duration(hours: 24);

  // URLs
  static const String privacyPolicyUrl = 'https://consume.app/privacy';
  static const String termsOfServiceUrl = 'https://consume.app/terms';
  static const String supportUrl = 'https://consume.app/support';
}
