import '../entities/folder.dart';

/// Repository interface for folders
abstract class FoldersRepository {
  /// Get all folders for the current user
  Future<List<Folder>> getAllFolders();
  
  /// Get a single folder by ID
  Future<Folder?> getFolderById(String id);
  
  /// Create a new folder
  Future<Folder> createFolder(Folder folder);
  
  /// Update an existing folder
  Future<Folder> updateFolder(Folder folder);
  
  /// Delete a folder
  Future<void> deleteFolder(String id);
  
  /// Reorder folders
  Future<void> reorderFolders(List<String> folderIds);
  
  /// Watch folders stream for real-time updates
  Stream<List<Folder>> watchFolders();
}
