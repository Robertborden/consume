import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/folder.dart';

part 'folder_model.freezed.dart';
part 'folder_model.g.dart';

/// Data model for Folder with JSON serialization
@freezed
class FolderModel with _$FolderModel {
  const FolderModel._();

  const factory FolderModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    String? description,
    @JsonKey(name: 'color_hex') @Default('#6366F1') String colorHex,
    @JsonKey(name: 'icon_name') @Default('folder') String iconName,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @JsonKey(name: 'item_count') @Default(0) int itemCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _FolderModel;

  factory FolderModel.fromJson(Map<String, dynamic> json) =>
      _$FolderModelFromJson(json);

  /// Convert to domain entity
  Folder toEntity() {
    return Folder(
      id: id,
      userId: userId,
      name: name,
      description: description,
      colorHex: colorHex,
      iconName: iconName,
      sortOrder: sortOrder,
      parentId: parentId,
      isDefault: isDefault,
      itemCount: itemCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  static FolderModel fromEntity(Folder entity) {
    return FolderModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      description: entity.description,
      colorHex: entity.colorHex,
      iconName: entity.iconName,
      sortOrder: entity.sortOrder,
      parentId: entity.parentId,
      isDefault: entity.isDefault,
      itemCount: entity.itemCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
