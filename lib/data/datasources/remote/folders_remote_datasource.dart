import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/folder_model.dart';
import '../supabase_client.dart';

/// Remote data source for folders using Supabase
abstract class FoldersRemoteDataSource {
  Future<List<FolderModel>> getAllFolders();
  Future<FolderModel?> getFolderById(String id);
  Future<FolderModel> createFolder(FolderModel folder);
  Future<FolderModel> updateFolder(FolderModel folder);
  Future<void> deleteFolder(String id);
  Future<void> reorderFolders(List<String> folderIds);
  Stream<List<FolderModel>> watchFolders();
}

class FoldersRemoteDataSourceImpl implements FoldersRemoteDataSource {
  final SupabaseClient _client;

  FoldersRemoteDataSourceImpl() : _client = SupabaseClientWrapper.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<FolderModel>> getAllFolders() async {
    final response = await _client
        .from('folders')
        .select()
        .eq('user_id', _userId)
        .order('sort_order', ascending: true);

    return (response as List)
        .map((json) => FolderModel.fromJson(json))
        .toList();
  }

  @override
  Future<FolderModel?> getFolderById(String id) async {
    final response = await _client
        .from('folders')
        .select()
        .eq('id', id)
        .eq('user_id', _userId)
        .maybeSingle();

    if (response == null) return null;
    return FolderModel.fromJson(response);
  }

  @override
  Future<FolderModel> createFolder(FolderModel folder) async {
    final response = await _client
        .from('folders')
        .insert(folder.toJson())
        .select()
        .single();

    return FolderModel.fromJson(response);
  }

  @override
  Future<FolderModel> updateFolder(FolderModel folder) async {
    final response = await _client
        .from('folders')
        .update(folder.toJson())
        .eq('id', folder.id)
        .eq('user_id', _userId)
        .select()
        .single();

    return FolderModel.fromJson(response);
  }

  @override
  Future<void> deleteFolder(String id) async {
    // First, move all items in this folder to null (no folder)
    await _client
        .from('saved_items')
        .update({'folder_id': null})
        .eq('folder_id', id)
        .eq('user_id', _userId);

    // Then delete the folder
    await _client
        .from('folders')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }

  @override
  Future<void> reorderFolders(List<String> folderIds) async {
    // Update sort_order for each folder
    for (int i = 0; i < folderIds.length; i++) {
      await _client
          .from('folders')
          .update({'sort_order': i})
          .eq('id', folderIds[i])
          .eq('user_id', _userId);
    }
  }

  @override
  Stream<List<FolderModel>> watchFolders() {
    return _client
        .from('folders')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('sort_order', ascending: true)
        .map((list) => list.map((json) => FolderModel.fromJson(json)).toList());
  }
}
