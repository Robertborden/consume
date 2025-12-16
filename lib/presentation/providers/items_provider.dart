import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/saved_items_remote_datasource.dart';
import '../../data/models/saved_item_model.dart';
import '../../domain/entities/saved_item.dart';
import '../../domain/entities/enums/item_status.dart';

/// Provider for saved items data source
final savedItemsDataSourceProvider = Provider<SavedItemsRemoteDataSource>((ref) {
  return SavedItemsRemoteDataSourceImpl();
});

/// Provider for all saved items
final savedItemsProvider = StreamProvider<List<SavedItem>>((ref) {
  final dataSource = ref.watch(savedItemsDataSourceProvider);
  return dataSource.watchItems().map(
    (items) => items.map((model) => model.toEntity()).toList(),
  );
});

/// Provider for items by status
final itemsByStatusProvider = FutureProvider.family<List<SavedItem>, ItemStatus>((ref, status) async {
  final dataSource = ref.watch(savedItemsDataSourceProvider);
  final items = await dataSource.getItemsByStatus(status.name);
  return items.map((model) => model.toEntity()).toList();
});

/// Provider for unreviewed items count
final unreviewedCountProvider = Provider<int>((ref) {
  final items = ref.watch(savedItemsProvider).valueOrNull ?? [];
  return items.where((item) => item.status == ItemStatus.unreviewed).length;
});

/// Provider for expiring soon items
final expiringSoonProvider = FutureProvider<List<SavedItem>>((ref) async {
  final dataSource = ref.watch(savedItemsDataSourceProvider);
  final items = await dataSource.getExpiringItems(days: 3);
  return items.map((model) => model.toEntity()).toList();
});

/// Provider for items controller
final itemsControllerProvider = Provider<ItemsController>((ref) {
  return ItemsController(ref);
});

/// Controller for managing saved items
class ItemsController {
  final Ref _ref;
  
  ItemsController(this._ref);
  
  SavedItemsRemoteDataSource get _dataSource => _ref.read(savedItemsDataSourceProvider);
  
  /// Create a new saved item
  Future<SavedItem> createItem(SavedItem item) async {
    final model = SavedItemModel.fromEntity(item);
    final result = await _dataSource.createItem(model);
    return result.toEntity();
  }
  
  /// Update an existing item
  Future<SavedItem> updateItem(SavedItem item) async {
    final model = SavedItemModel.fromEntity(item);
    final result = await _dataSource.updateItem(model);
    return result.toEntity();
  }
  
  /// Mark item as consumed
  Future<void> markAsConsumed(String itemId) async {
    final existing = await _dataSource.getItemById(itemId);
    if (existing != null) {
      final updated = existing.copyWith(
        status: 'consumed',
        consumedAt: DateTime.now(),
      );
      await _dataSource.updateItem(updated);
    }
  }
  
  /// Mark item as kept (extend expiration)
  Future<void> markAsKept(String itemId, {int days = 7}) async {
    final existing = await _dataSource.getItemById(itemId);
    if (existing != null) {
      final updated = existing.copyWith(
        status: 'kept',
        expiresAt: DateTime.now().add(Duration(days: days)),
      );
      await _dataSource.updateItem(updated);
    }
  }
  
  /// Archive an item
  Future<void> archiveItem(String itemId) async {
    final existing = await _dataSource.getItemById(itemId);
    if (existing != null) {
      final updated = existing.copyWith(status: 'archived');
      await _dataSource.updateItem(updated);
    }
  }
  
  /// Delete an item
  Future<void> deleteItem(String itemId) async {
    await _dataSource.deleteItem(itemId);
  }
  
  /// Move item to folder
  Future<void> moveToFolder(String itemId, String? folderId) async {
    final existing = await _dataSource.getItemById(itemId);
    if (existing != null) {
      final updated = existing.copyWith(folderId: folderId);
      await _dataSource.updateItem(updated);
    }
  }
  
  /// Toggle pin status
  Future<void> togglePin(String itemId) async {
    final existing = await _dataSource.getItemById(itemId);
    if (existing != null) {
      final updated = existing.copyWith(isPinned: !existing.isPinned);
      await _dataSource.updateItem(updated);
    }
  }
}
