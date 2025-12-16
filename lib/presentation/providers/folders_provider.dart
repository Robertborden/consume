import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/folders_remote_datasource.dart';
import '../../data/models/folder_model.dart';
import '../../domain/entities/folder.dart';

/// Provider for folders data source
final foldersDataSourceProvider = Provider<FoldersRemoteDataSource>((ref) {
  return FoldersRemoteDataSourceImpl();
});

/// Provider for all folders
final foldersProvider = StreamProvider<List<Folder>>((ref) {
  final dataSource = ref.watch(foldersDataSourceProvider);
  return dataSource.watchFolders().map(
    (items) => items.map((model) => model.toEntity()).toList(),
  );
});

/// Provider for selected folder
final selectedFolderProvider = StateProvider<Folder?>((ref) => null);

/// Provider for folders controller
final foldersControllerProvider = Provider<FoldersController>((ref) {
  return FoldersController(ref);
});

/// Controller for managing folders
class FoldersController {
  final Ref _ref;
  
  FoldersController(this._ref);
  
  FoldersRemoteDataSource get _dataSource => _ref.read(foldersDataSourceProvider);
  
  /// Create a new folder
  Future<Folder> createFolder(Folder folder) async {
    final model = FolderModel.fromEntity(folder);
    final result = await _dataSource.createFolder(model);
    return result.toEntity();
  }
  
  /// Update an existing folder
  Future<Folder> updateFolder(Folder folder) async {
    final model = FolderModel.fromEntity(folder);
    final result = await _dataSource.updateFolder(model);
    return result.toEntity();
  }
  
  /// Delete a folder
  Future<void> deleteFolder(String folderId) async {
    await _dataSource.deleteFolder(folderId);
  }
  
  /// Reorder folders
  Future<void> reorderFolders(List<String> folderIds) async {
    await _dataSource.reorderFolders(folderIds);
  }
}
