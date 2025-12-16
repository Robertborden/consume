import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/saved_item_model.dart';
import '../supabase_client.dart';

/// Remote data source for saved items using Supabase
abstract class SavedItemsRemoteDataSource {
  Future<List<SavedItemModel>> getAllItems();
  Future<List<SavedItemModel>> getItemsByStatus(String status);
  Future<List<SavedItemModel>> getItemsByFolder(String folderId);
  Future<List<SavedItemModel>> getExpiringItems({int days = 3});
  Future<SavedItemModel?> getItemById(String id);
  Future<SavedItemModel> createItem(SavedItemModel item);
  Future<SavedItemModel> updateItem(SavedItemModel item);
  Future<void> deleteItem(String id);
  Future<void> deleteExpiredItems();
  Stream<List<SavedItemModel>> watchItems();
}

class SavedItemsRemoteDataSourceImpl implements SavedItemsRemoteDataSource {
  final SupabaseClient _client;

  SavedItemsRemoteDataSourceImpl() : _client = SupabaseClientWrapper.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<SavedItemModel>> getAllItems() async {
    final response = await _client
        .from('saved_items')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => SavedItemModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<SavedItemModel>> getItemsByStatus(String status) async {
    final response = await _client
        .from('saved_items')
        .select()
        .eq('user_id', _userId)
        .eq('status', status)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => SavedItemModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<SavedItemModel>> getItemsByFolder(String folderId) async {
    final response = await _client
        .from('saved_items')
        .select()
        .eq('user_id', _userId)
        .eq('folder_id', folderId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => SavedItemModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<SavedItemModel>> getExpiringItems({int days = 3}) async {
    final now = DateTime.now();
    final threshold = now.add(Duration(days: days));

    final response = await _client
        .from('saved_items')
        .select()
        .eq('user_id', _userId)
        .eq('status', 'unreviewed')
        .lte('expires_at', threshold.toIso8601String())
        .gt('expires_at', now.toIso8601String())
        .order('expires_at', ascending: true);

    return (response as List)
        .map((json) => SavedItemModel.fromJson(json))
        .toList();
  }

  @override
  Future<SavedItemModel?> getItemById(String id) async {
    final response = await _client
        .from('saved_items')
        .select()
        .eq('id', id)
        .eq('user_id', _userId)
        .maybeSingle();

    if (response == null) return null;
    return SavedItemModel.fromJson(response);
  }

  @override
  Future<SavedItemModel> createItem(SavedItemModel item) async {
    final response = await _client
        .from('saved_items')
        .insert(item.toJson())
        .select()
        .single();

    return SavedItemModel.fromJson(response);
  }

  @override
  Future<SavedItemModel> updateItem(SavedItemModel item) async {
    final response = await _client
        .from('saved_items')
        .update(item.toJson())
        .eq('id', item.id)
        .eq('user_id', _userId)
        .select()
        .single();

    return SavedItemModel.fromJson(response);
  }

  @override
  Future<void> deleteItem(String id) async {
    await _client
        .from('saved_items')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }

  @override
  Future<void> deleteExpiredItems() async {
    final now = DateTime.now();
    await _client
        .from('saved_items')
        .update({'status': 'expired'})
        .eq('user_id', _userId)
        .eq('status', 'unreviewed')
        .lt('expires_at', now.toIso8601String());
  }

  @override
  Stream<List<SavedItemModel>> watchItems() {
    return _client
        .from('saved_items')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .map((list) => list.map((json) => SavedItemModel.fromJson(json)).toList());
  }
}
