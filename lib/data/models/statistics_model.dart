import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/statistics.dart';

part 'statistics_model.freezed.dart';
part 'statistics_model.g.dart';

/// Data model for DailyStatistics with JSON serialization
@freezed
class DailyStatisticsModel with _$DailyStatisticsModel {
  const DailyStatisticsModel._();

  const factory DailyStatisticsModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required DateTime date,
    @JsonKey(name: 'items_saved') @Default(0) int itemsSaved,
    @JsonKey(name: 'items_consumed') @Default(0) int itemsConsumed,
    @JsonKey(name: 'items_expired') @Default(0) int itemsExpired,
    @JsonKey(name: 'items_reviewed') @Default(0) int itemsReviewed,
    @JsonKey(name: 'review_time_seconds') @Default(0) int reviewTimeSeconds,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _DailyStatisticsModel;

  factory DailyStatisticsModel.fromJson(Map<String, dynamic> json) =>
      _$DailyStatisticsModelFromJson(json);

  /// Convert to domain entity
  DailyStatistics toEntity() {
    return DailyStatistics(
      id: id,
      userId: userId,
      date: date,
      itemsSaved: itemsSaved,
      itemsConsumed: itemsConsumed,
      itemsExpired: itemsExpired,
      itemsReviewed: itemsReviewed,
      reviewTimeSeconds: reviewTimeSeconds,
      createdAt: createdAt,
    );
  }

  /// Create from domain entity
  static DailyStatisticsModel fromEntity(DailyStatistics entity) {
    return DailyStatisticsModel(
      id: entity.id,
      userId: entity.userId,
      date: entity.date,
      itemsSaved: entity.itemsSaved,
      itemsConsumed: entity.itemsConsumed,
      itemsExpired: entity.itemsExpired,
      itemsReviewed: entity.itemsReviewed,
      reviewTimeSeconds: entity.reviewTimeSeconds,
      createdAt: entity.createdAt,
    );
  }
}

/// Data model for UserStatistics with JSON serialization
@freezed
class UserStatisticsModel with _$UserStatisticsModel {
  const UserStatisticsModel._();

  const factory UserStatisticsModel({
    @JsonKey(name: 'total_saved') @Default(0) int totalSaved,
    @JsonKey(name: 'total_consumed') @Default(0) int totalConsumed,
    @JsonKey(name: 'total_expired') @Default(0) int totalExpired,
    @JsonKey(name: 'total_active') @Default(0) int totalActive,
    @JsonKey(name: 'consumption_rate') @Default(0.0) double consumptionRate,
    @JsonKey(name: 'avg_time_to_consume_hours') @Default(0.0) double avgTimeToConsumeHours,
    @JsonKey(name: 'current_streak') @Default(0) int currentStreak,
    @JsonKey(name: 'longest_streak') @Default(0) int longestStreak,
    @JsonKey(name: 'items_by_source') @Default({}) Map<String, int> itemsBySource,
    @JsonKey(name: 'items_by_folder') @Default({}) Map<String, int> itemsByFolder,
    @JsonKey(name: 'weekly_activity') @Default([]) List<int> weeklyActivity,
    @JsonKey(name: 'guilt_meter_percentage') @Default(0.0) double guiltMeterPercentage,
  }) = _UserStatisticsModel;

  factory UserStatisticsModel.fromJson(Map<String, dynamic> json) =>
      _$UserStatisticsModelFromJson(json);

  /// Convert to domain entity
  UserStatistics toEntity() {
    return UserStatistics(
      totalSaved: totalSaved,
      totalConsumed: totalConsumed,
      totalExpired: totalExpired,
      totalActive: totalActive,
      consumptionRate: consumptionRate,
      avgTimeToConsumeHours: avgTimeToConsumeHours,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      itemsBySource: itemsBySource,
      itemsByFolder: itemsByFolder,
      weeklyActivity: weeklyActivity,
      guiltMeterPercentage: guiltMeterPercentage,
    );
  }

  /// Create from domain entity
  static UserStatisticsModel fromEntity(UserStatistics entity) {
    return UserStatisticsModel(
      totalSaved: entity.totalSaved,
      totalConsumed: entity.totalConsumed,
      totalExpired: entity.totalExpired,
      totalActive: entity.totalActive,
      consumptionRate: entity.consumptionRate,
      avgTimeToConsumeHours: entity.avgTimeToConsumeHours,
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      itemsBySource: entity.itemsBySource,
      itemsByFolder: entity.itemsByFolder,
      weeklyActivity: entity.weeklyActivity,
      guiltMeterPercentage: entity.guiltMeterPercentage,
    );
  }
}
