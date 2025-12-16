import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/saved_item.dart';
import '../../domain/entities/enums/item_status.dart';
import '../../domain/entities/enums/content_source.dart';

part 'saved_item_model.freezed.dart';
part 'saved_item_model.g.dart';

/// Data model for SavedItem with JSON serialization
@freezed
class SavedItemModel with _$SavedItemModel {
  const SavedItemModel._();

  const factory SavedItemModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String url,
    String? title,
    String? description,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'favicon_url') String? faviconUrl,
    @Default('unreviewed') String status,
    @Default('other') String source,
    @JsonKey(name: 'source_app_name') String? sourceAppName,
    @JsonKey(name: 'folder_id') String? folderId,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'consumed_at') DateTime? consumedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @Default([]) List<String> tags,
    String? notes,
    @JsonKey(name: 'is_pinned') @Default(false) bool isPinned,
    @JsonKey(name: 'reminder_at') DateTime? reminderAt,
    @JsonKey(name: 'share_count') @Default(0) int shareCount,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
  }) = _SavedItemModel;

  factory SavedItemModel.fromJson(Map<String, dynamic> json) =>
      _$SavedItemModelFromJson(json);

  /// Convert to domain entity
  SavedItem toEntity() {
    return SavedItem(
      id: id,
      userId: userId,
      url: url,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      faviconUrl: faviconUrl,
      status: ItemStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => ItemStatus.unreviewed,
      ),
      source: ContentSource.values.firstWhere(
        (e) => e.name == source,
        orElse: () => ContentSource.other,
      ),
      sourceAppName: sourceAppName,
      folderId: folderId,
      expiresAt: expiresAt,
      consumedAt: consumedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tags: tags,
      notes: notes,
      isPinned: isPinned,
      reminderAt: reminderAt,
      shareCount: shareCount,
      viewCount: viewCount,
    );
  }

  /// Create from domain entity
  static SavedItemModel fromEntity(SavedItem entity) {
    return SavedItemModel(
      id: entity.id,
      userId: entity.userId,
      url: entity.url,
      title: entity.title,
      description: entity.description,
      thumbnailUrl: entity.thumbnailUrl,
      faviconUrl: entity.faviconUrl,
      status: entity.status.name,
      source: entity.source.name,
      sourceAppName: entity.sourceAppName,
      folderId: entity.folderId,
      expiresAt: entity.expiresAt,
      consumedAt: entity.consumedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      tags: entity.tags,
      notes: entity.notes,
      isPinned: entity.isPinned,
      reminderAt: entity.reminderAt,
      shareCount: entity.shareCount,
      viewCount: entity.viewCount,
    );
  }
}
