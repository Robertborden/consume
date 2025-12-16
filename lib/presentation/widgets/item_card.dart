import 'package:flutter/material.dart';
import '../../core/theme/spacing.dart';
import '../../domain/entities/saved_item.dart';

/// Card widget for displaying a saved item
class ItemCard extends StatelessWidget {
  final SavedItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showExpiration;

  const ItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.showExpiration = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            if (item.thumbnailUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  item.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      item.source.icon,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    item.source.icon,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: item.source.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.source.icon,
                              size: 12,
                              color: item.source.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.source.displayName,
                              style: TextStyle(
                                fontSize: 10,
                                color: item.source.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (item.isPinned)
                        Icon(
                          Icons.push_pin,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  // Title
                  Text(
                    item.title ?? 'Untitled',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Description
                  if (item.description != null) ...[
                    const SizedBox(height: Spacing.xs),
                    Text(
                      item.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // Expiration warning
                  if (showExpiration && item.isExpiringSoon) ...[
                    const SizedBox(height: Spacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer,
                            size: 12,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Expires ${item.timeUntilExpiration}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
