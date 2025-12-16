import 'package:equatable/equatable.dart';

/// Entity representing the app user
class AppUser extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;

  // Settings
  final bool dailyReminderEnabled;
  final String dailyReminderTime;
  final int defaultExpiryDays;
  final String themeMode; // 'light', 'dark', 'system'

  // Statistics
  final int totalItemsSaved;
  final int totalItemsConsumed;
  final int totalItemsExpired;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastReviewDate;

  // Subscription
  final bool isPro;
  final DateTime? subscriptionExpiresAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.dailyReminderEnabled = true,
    this.dailyReminderTime = '09:00',
    this.defaultExpiryDays = 7,
    this.themeMode = 'system',
    this.totalItemsSaved = 0,
    this.totalItemsConsumed = 0,
    this.totalItemsExpired = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastReviewDate,
    this.isPro = false,
    this.subscriptionExpiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, email, totalItemsSaved, currentStreak, isPro];

  /// User's display name or email prefix
  String get name => displayName ?? email.split('@').first;

  /// Consumption rate percentage (0-100)
  double get consumptionRate {
    if (totalItemsSaved == 0) return 100.0;
    return (totalItemsConsumed / totalItemsSaved * 100).clamp(0.0, 100.0);
  }

  /// Items remaining to review
  int get itemsRemaining {
    final remaining = totalItemsSaved - totalItemsConsumed - totalItemsExpired;
    return remaining < 0 ? 0 : remaining;
  }

  /// Check if user has active Pro subscription
  bool get hasActiveSubscription {
    if (!isPro) return false;
    if (subscriptionExpiresAt == null) return true; // Lifetime
    return DateTime.now().isBefore(subscriptionExpiresAt!);
  }

  /// Check if user can save more items (free tier limit)
  bool canSaveMore(int currentItemCount, {int freeLimit = 50}) {
    if (hasActiveSubscription) return true;
    return currentItemCount < freeLimit;
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    bool? dailyReminderEnabled,
    String? dailyReminderTime,
    int? defaultExpiryDays,
    String? themeMode,
    int? totalItemsSaved,
    int? totalItemsConsumed,
    int? totalItemsExpired,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastReviewDate,
    bool? isPro,
    DateTime? subscriptionExpiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      defaultExpiryDays: defaultExpiryDays ?? this.defaultExpiryDays,
      themeMode: themeMode ?? this.themeMode,
      totalItemsSaved: totalItemsSaved ?? this.totalItemsSaved,
      totalItemsConsumed: totalItemsConsumed ?? this.totalItemsConsumed,
      totalItemsExpired: totalItemsExpired ?? this.totalItemsExpired,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      isPro: isPro ?? this.isPro,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
