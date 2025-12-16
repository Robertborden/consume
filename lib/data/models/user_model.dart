import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Data model for AppUser with JSON serialization
@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    String? email,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'is_premium') @Default(false) bool isPremium,
    @JsonKey(name: 'subscription_tier') @Default('free') String subscriptionTier,
    @JsonKey(name: 'subscription_expires_at') DateTime? subscriptionExpiresAt,
    @JsonKey(name: 'default_expiry_days') @Default(7) int defaultExpiryDays,
    @JsonKey(name: 'daily_review_goal') @Default(5) int dailyReviewGoal,
    @JsonKey(name: 'notifications_enabled') @Default(true) bool notificationsEnabled,
    @JsonKey(name: 'reminder_time') String? reminderTime,
    @JsonKey(name: 'theme_mode') @Default('system') String themeMode,
    @JsonKey(name: 'current_streak') @Default(0) int currentStreak,
    @JsonKey(name: 'longest_streak') @Default(0) int longestStreak,
    @JsonKey(name: 'total_items_saved') @Default(0) int totalItemsSaved,
    @JsonKey(name: 'total_items_consumed') @Default(0) int totalItemsConsumed,
    @JsonKey(name: 'last_review_date') DateTime? lastReviewDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convert to domain entity
  AppUser toEntity() {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName,
      avatarUrl: avatarUrl,
      isPremium: isPremium,
      subscriptionTier: subscriptionTier,
      subscriptionExpiresAt: subscriptionExpiresAt,
      defaultExpiryDays: defaultExpiryDays,
      dailyReviewGoal: dailyReviewGoal,
      notificationsEnabled: notificationsEnabled,
      reminderTime: reminderTime,
      themeMode: themeMode,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalItemsSaved: totalItemsSaved,
      totalItemsConsumed: totalItemsConsumed,
      lastReviewDate: lastReviewDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  static UserModel fromEntity(AppUser entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      avatarUrl: entity.avatarUrl,
      isPremium: entity.isPremium,
      subscriptionTier: entity.subscriptionTier,
      subscriptionExpiresAt: entity.subscriptionExpiresAt,
      defaultExpiryDays: entity.defaultExpiryDays,
      dailyReviewGoal: entity.dailyReviewGoal,
      notificationsEnabled: entity.notificationsEnabled,
      reminderTime: entity.reminderTime,
      themeMode: entity.themeMode,
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      totalItemsSaved: entity.totalItemsSaved,
      totalItemsConsumed: entity.totalItemsConsumed,
      lastReviewDate: entity.lastReviewDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
