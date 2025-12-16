import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/user_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../data/models/statistics_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/statistics.dart';

/// Provider for user data source
final userDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSourceImpl();
});

/// Provider for current user profile
final userProfileProvider = StreamProvider<AppUser?>((ref) {
  final dataSource = ref.watch(userDataSourceProvider);
  return dataSource.watchUserProfile().map(
    (model) => model?.toEntity(),
  );
});

/// Provider for user statistics
final userStatisticsProvider = FutureProvider<UserStatistics>((ref) async {
  final dataSource = ref.watch(userDataSourceProvider);
  final stats = await dataSource.getUserStatistics();
  return stats.toEntity();
});

/// Provider for daily statistics
final dailyStatisticsProvider = FutureProvider.family<List<DailyStatistics>, int>((ref, days) async {
  final dataSource = ref.watch(userDataSourceProvider);
  final stats = await dataSource.getDailyStatistics(days: days);
  return stats.map((model) => model.toEntity()).toList();
});

/// Provider for user controller
final userControllerProvider = Provider<UserController>((ref) {
  return UserController(ref);
});

/// Controller for managing user data
class UserController {
  final Ref _ref;
  
  UserController(this._ref);
  
  UserRemoteDataSource get _dataSource => _ref.read(userDataSourceProvider);
  
  /// Update user profile
  Future<AppUser> updateProfile(AppUser user) async {
    final model = UserModel.fromEntity(user);
    final result = await _dataSource.updateUserProfile(model);
    return result.toEntity();
  }
  
  /// Update notification settings
  Future<void> updateNotificationSettings({
    bool? enabled,
    String? reminderTime,
  }) async {
    final current = await _dataSource.getCurrentUser();
    if (current != null) {
      final updated = current.copyWith(
        notificationsEnabled: enabled ?? current.notificationsEnabled,
        reminderTime: reminderTime ?? current.reminderTime,
      );
      await _dataSource.updateUserProfile(updated);
    }
  }
  
  /// Update theme mode
  Future<void> updateThemeMode(String mode) async {
    final current = await _dataSource.getCurrentUser();
    if (current != null) {
      final updated = current.copyWith(themeMode: mode);
      await _dataSource.updateUserProfile(updated);
    }
  }
  
  /// Update default expiry days
  Future<void> updateDefaultExpiryDays(int days) async {
    final current = await _dataSource.getCurrentUser();
    if (current != null) {
      final updated = current.copyWith(defaultExpiryDays: days);
      await _dataSource.updateUserProfile(updated);
    }
  }
  
  /// Update daily review goal
  Future<void> updateDailyReviewGoal(int goal) async {
    final current = await _dataSource.getCurrentUser();
    if (current != null) {
      final updated = current.copyWith(dailyReviewGoal: goal);
      await _dataSource.updateUserProfile(updated);
    }
  }
  
  /// Record review activity and update streak
  Future<void> recordReviewActivity() async {
    await _dataSource.updateStreak();
  }
}
