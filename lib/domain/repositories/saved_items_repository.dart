import '../entities/saved_item.dart';
import '../entities/enums/item_status.dart';

/// Repository interface for saved items
abstract class SavedItemsRepository {
  /// Get all saved items for the current user
  Future<List<SavedItem>> getAllItems();
  
  /// Get items filtered by status
  Future<List<SavedItem>> getItemsByStatus(ItemStatus status);
  
  /// Get items in a specific folder
  Future<List<SavedItem>> getItemsByFolder(String folderId);
  
  /// Get items expiring within the specified days
  Future<List<SavedItem>> getExpiringItems({int days = 3});
  
  /// Get a single item by ID
  Future<SavedItem?> getItemById(String id);
  
  /// Create a new saved item
  Future<SavedItem> createItem(SavedItem item);
  
  /// Update an existing item
  Future<SavedItem> updateItem(SavedItem item);
  
  /// Delete an item
  Future<void> deleteItem(String id);
  
  /// Mark expired items
  Future<void> markExpiredItems();
  
  /// Watch items stream for real-time updates
  Stream<List<SavedItem>> watchItems();
  
  /// Search items by query
  Future<List<SavedItem>> searchItems(String query);
}
