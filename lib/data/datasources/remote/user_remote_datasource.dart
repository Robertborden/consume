import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';
import '../../models/statistics_model.dart';
import '../supabase_client.dart';

/// Remote data source for user data using Supabase
abstract class UserRemoteDataSource {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> createUserProfile(UserModel user);
  Future<UserModel> updateUserProfile(UserModel user);
  Future<UserStatisticsModel> getUserStatistics();
  Future<List<DailyStatisticsModel>> getDailyStatistics({int days = 30});
  Future<void> recordDailyActivity(DailyStatisticsModel stats);
  Future<void> updateStreak();
  Stream<UserModel?> watchUserProfile();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final SupabaseClient _client;

  UserRemoteDataSourceImpl() : _client = SupabaseClientWrapper.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<UserModel?> getCurrentUser() async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', _userId)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  @override
  Future<UserModel> createUserProfile(UserModel user) async {
    final response = await _client
        .from('users')
        .insert(user.toJson())
        .select()
        .single();

    return UserModel.fromJson(response);
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    final response = await _client
        .from('users')
        .update(user.toJson())
        .eq('id', _userId)
        .select()
        .single();

    return UserModel.fromJson(response);
  }

  @override
  Future<UserStatisticsModel> getUserStatistics() async {
    // Call Supabase function to get aggregated statistics
    final response = await _client
        .rpc('get_user_statistics', params: {'p_user_id': _userId});

    return UserStatisticsModel.fromJson(response);
  }

  @override
  Future<List<DailyStatisticsModel>> getDailyStatistics({int days = 30}) async {
    final startDate = DateTime.now().subtract(Duration(days: days));

    final response = await _client
        .from('daily_statistics')
        .select()
        .eq('user_id', _userId)
        .gte('date', startDate.toIso8601String().split('T')[0])
        .order('date', ascending: false);

    return (response as List)
        .map((json) => DailyStatisticsModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> recordDailyActivity(DailyStatisticsModel stats) async {
    // Upsert daily statistics (insert or update if exists for today)
    await _client
        .from('daily_statistics')
        .upsert(
          stats.toJson(),
          onConflict: 'user_id,date',
        );
  }

  @override
  Future<void> updateStreak() async {
    // Call Supabase function to update streak
    await _client.rpc('update_user_streak', params: {'p_user_id': _userId});
  }

  @override
  Stream<UserModel?> watchUserProfile() {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', _userId)
        .map((list) {
          if (list.isEmpty) return null;
          return UserModel.fromJson(list.first);
        });
  }
}
