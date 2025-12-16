import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:consume/core/theme/colors.dart';

/// Daily statistics record
class DailyStatistics extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final int itemsSaved;
  final int itemsConsumed;
  final int itemsExpired;
  final int itemsArchived;
  final int reviewSessions;
  final int timeSpentSeconds;

  const DailyStatistics({
    required this.id,
    required this.userId,
    required this.date,
    this.itemsSaved = 0,
    this.itemsConsumed = 0,
    this.itemsExpired = 0,
    this.itemsArchived = 0,
    this.reviewSessions = 0,
    this.timeSpentSeconds = 0,
  });

  @override
  List<Object?> get props => [id, date];

  /// Time spent as Duration
  Duration get timeSpent => Duration(seconds: timeSpentSeconds);

  /// Total items processed in this day
  int get totalProcessed => itemsConsumed + itemsExpired + itemsArchived;

  /// Check if user was active on this day
  bool get wasActive => itemsConsumed > 0 || reviewSessions > 0;
}

/// Aggregated user statistics
class UserStatistics extends Equatable {
  final int totalSaved;
  final int totalConsumed;
  final int totalExpired;
  final int totalArchived;
  final int currentStreak;
  final int longestStreak;
  final double consumptionRate;
  final List<DailyStatistics> recentDays;

  const UserStatistics({
    this.totalSaved = 0,
    this.totalConsumed = 0,
    this.totalExpired = 0,
    this.totalArchived = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.consumptionRate = 0.0,
    this.recentDays = const [],
  });

  @override
  List<Object?> get props => [totalSaved, totalConsumed, currentStreak];

  /// Items still pending review
  int get totalPending => totalSaved - totalConsumed - totalExpired - totalArchived;

  /// Guilt level (0-100, higher = more items expired)
  double get guiltLevel {
    if (totalSaved == 0) return 0.0;
    return ((totalExpired / totalSaved) * 100).clamp(0.0, 100.0);
  }

  /// Health score (inverse of guilt)
  double get healthScore => 100.0 - guiltLevel;

  /// Color based on consumption rate
  Color get rateColor => AppColors.guiltMeterColor(consumptionRate);

  /// Status message based on consumption rate
  String get statusMessage {
    if (consumptionRate >= 80) return 'Excellent!';
    if (consumptionRate >= 60) return 'Great job!';
    if (consumptionRate >= 40) return 'Keep going!';
    if (consumptionRate >= 20) return 'Room to improve';
    return 'Time to consume!';
  }

  /// Emoji based on consumption rate
  String get statusEmoji {
    if (consumptionRate >= 80) return '🌟';
    if (consumptionRate >= 60) return '👍';
    if (consumptionRate >= 40) return '💪';
    if (consumptionRate >= 20) return '🔄';
    return '⚠️';
  }

  /// Average items consumed per day (last 7 days)
  double get averageDaily {
    if (recentDays.isEmpty) return 0.0;
    final total = recentDays.fold<int>(0, (sum, day) => sum + day.itemsConsumed);
    return total / recentDays.length;
  }
}
