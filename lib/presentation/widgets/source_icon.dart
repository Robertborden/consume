import 'package:flutter/material.dart';
import '../../domain/entities/enums/content_source.dart';

/// Widget for displaying source icon with optional background
class SourceIcon extends StatelessWidget {
  final ContentSource source;
  final double size;
  final bool showBackground;

  const SourceIcon({
    super.key,
    required this.source,
    this.size = 24,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    if (showBackground) {
      return Container(
        width: size + 8,
        height: size + 8,
        decoration: BoxDecoration(
          color: source.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          source.icon,
          size: size,
          color: source.color,
        ),
      );
    }

    return Icon(
      source.icon,
      size: size,
      color: source.color,
    );
  }
}
