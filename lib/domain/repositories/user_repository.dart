import '../entities/user.dart';
import '../entities/statistics.dart';

/// Repository interface for user data
abstract class UserRepository {
  /// Get the current user profile
  Future<AppUser?> getCurrentUser();
  
  /// Create a new user profile
  Future<AppUser> createUserProfile(AppUser user);
  
  /// Update user profile
  Future<AppUser> updateUserProfile(AppUser user);
  
  /// Get aggregated user statistics
  Future<UserStatistics> getUserStatistics();
  
  /// Get daily statistics for the past N days
  Future<List<DailyStatistics>> getDailyStatistics({int days = 30});
  
  /// Record daily activity
  Future<void> recordDailyActivity(DailyStatistics stats);
  
  /// Update user streak
  Future<void> updateStreak();
  
  /// Watch user profile for real-time updates
  Stream<AppUser?> watchUserProfile();
}
