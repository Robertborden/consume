import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Entity representing a folder for organizing saved items
class Folder extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String colorHex;
  final String icon;
  final int itemCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Folder({
    required this.id,
    required this.userId,
    required this.name,
    this.colorHex = '#6366F1',
    this.icon = 'folder',
    this.itemCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, itemCount, updatedAt];

  /// Parse color from hex string
  Color get color {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF6366F1);
    }
  }

  /// Check if folder is empty
  bool get isEmpty => itemCount == 0;

  /// Get icon data from icon name
  IconData get iconData {
    switch (icon) {
      case 'folder':
        return Icons.folder;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'favorite':
        return Icons.favorite;
      case 'bookmark':
        return Icons.bookmark;
      case 'star':
        return Icons.star;
      case 'music':
        return Icons.music_note;
      case 'video':
        return Icons.video_library;
      case 'article':
        return Icons.article;
      case 'code':
        return Icons.code;
      case 'fitness':
        return Icons.fitness_center;
      case 'food':
        return Icons.restaurant;
      case 'travel':
        return Icons.flight;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.folder;
    }
  }

  /// Available folder icons
  static const List<String> availableIcons = [
    'folder',
    'work',
    'school',
    'favorite',
    'bookmark',
    'star',
    'music',
    'video',
    'article',
    'code',
    'fitness',
    'food',
    'travel',
    'shopping',
  ];

  /// Available folder colors
  static const List<String> availableColors = [
    '#6366F1', // Primary (Indigo)
    '#EC4899', // Pink
    '#F59E0B', // Amber
    '#10B981', // Emerald
    '#3B82F6', // Blue
    '#8B5CF6', // Violet
    '#EF4444', // Red
    '#06B6D4', // Cyan
    '#84CC16', // Lime
    '#F97316', // Orange
  ];

  Folder copyWith({
    String? id,
    String? userId,
    String? name,
    String? colorHex,
    String? icon,
    int? itemCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Folder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      icon: icon ?? this.icon,
      itemCount: itemCount ?? this.itemCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
