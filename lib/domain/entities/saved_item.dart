import 'package:equatable/equatable.dart';
import 'enums/item_status.dart';
import 'enums/content_source.dart';

/// Core entity representing a saved content item
class SavedItem extends Equatable {
  final String id;
  final String userId;
  final String? folderId;
  final String url;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final ContentSource source;
  final ItemStatus status;
  final bool isFavorite;
  final String? note;
  final List<String> tags;
  final DateTime savedAt;
  final DateTime? expiresAt;
  final DateTime? consumedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedItem({
    required this.id,
    required this.userId,
    this.folderId,
    required this.url,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.source = ContentSource.other,
    this.status = ItemStatus.unreviewed,
    this.isFavorite = false,
    this.note,
    this.tags = const [],
    required this.savedAt,
    this.expiresAt,
    this.consumedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, status, updatedAt];

  /// Check if item is expiring soon (within 24 hours)
  bool get isExpiringSoon {
    if (expiresAt == null) return false;
    final now = DateTime.now();
    final diff = expiresAt!.difference(now);
    return diff.inHours <= 24 && diff.inHours > 0;
  }

  /// Check if item has expired
  bool get hasExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Time remaining until expiration
  Duration? get timeUntilExpiration {
    if (expiresAt == null) return null;
    final diff = expiresAt!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Domain name from URL
  String get domain {
    try {
      return Uri.parse(url).host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  /// Display title (fallback to domain if no title)
  String get displayTitle => title ?? domain;

  /// Check if item can be reviewed
  bool get canReview => status.isActive;

  SavedItem copyWith({
    String? id,
    String? userId,
    String? folderId,
    String? url,
    String? title,
    String? description,
    String? thumbnailUrl,
    ContentSource? source,
    ItemStatus? status,
    bool? isFavorite,
    String? note,
    List<String>? tags,
    DateTime? savedAt,
    DateTime? expiresAt,
    DateTime? consumedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      folderId: folderId ?? this.folderId,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      source: source ?? this.source,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      savedAt: savedAt ?? this.savedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      consumedAt: consumedAt ?? this.consumedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
