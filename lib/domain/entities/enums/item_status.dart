/// Status of a saved item
enum ItemStatus {
  unreviewed,
  kept,
  consumed,
  expired,
  archived;

  String get displayName {
    switch (this) {
      case ItemStatus.unreviewed:
        return 'Unreviewed';
      case ItemStatus.kept:
        return 'Kept';
      case ItemStatus.consumed:
        return 'Consumed';
      case ItemStatus.expired:
        return 'Expired';
      case ItemStatus.archived:
        return 'Archived';
    }
  }

  /// Check if item is still active (can be reviewed)
  bool get isActive => this == unreviewed || this == kept;

  /// Check if item has been processed
  bool get isProcessed => this == consumed || this == expired || this == archived;

  /// Convert to database string
  String toJson() => name;

  /// Parse from database string
  static ItemStatus fromJson(String value) {
    return ItemStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ItemStatus.unreviewed,
    );
  }
}
