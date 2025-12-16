import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/items_provider.dart';
import '../../providers/user_provider.dart';
import '../../../core/theme/spacing.dart';
import '../../../domain/entities/saved_item.dart';
import '../../../domain/entities/enums/item_status.dart';

class ReviewPage extends ConsumerStatefulWidget {
  const ReviewPage({super.key});

  @override
  ConsumerState<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends ConsumerState<ReviewPage> {
  int _currentIndex = 0;
  List<SavedItem> _reviewItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    final items = ref.read(savedItemsProvider).valueOrNull ?? [];
    setState(() {
      _reviewItems = items
          .where((item) => item.status == ItemStatus.unreviewed)
          .toList();
    });
  }

  void _handleSwipe(bool isRight) async {
    if (_currentIndex >= _reviewItems.length) return;

    final item = _reviewItems[_currentIndex];
    final controller = ref.read(itemsControllerProvider);

    if (isRight) {
      // Keep - extend expiration
      await controller.markAsKept(item.id);
    } else {
      // Consumed
      await controller.markAsConsumed(item.id);
    }

    // Update streak
    await ref.read(userControllerProvider).recordReviewActivity();

    setState(() {
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review'),
        actions: [
          if (_reviewItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: Spacing.md),
              child: Center(
                child: Text(
                  '${_currentIndex + 1} / ${_reviewItems.length}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
        ],
      ),
      body: _reviewItems.isEmpty || _currentIndex >= _reviewItems.length
          ? _buildEmptyState(theme)
          : _buildReviewCard(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            'All caught up!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'No items to review right now.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ThemeData theme) {
    final item = _reviewItems[_currentIndex];

    return Padding(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _reviewItems.length,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: Spacing.lg),
          // Card
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! > 0) {
                    _handleSwipe(true); // Swipe right - Keep
                  } else {
                    _handleSwipe(false); // Swipe left - Consumed
                  }
                }
              },
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: Spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: item.source.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(Spacing.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.source.icon,
                              size: 16,
                              color: item.source.color,
                            ),
                            const SizedBox(width: Spacing.xs),
                            Text(
                              item.source.displayName,
                              style: TextStyle(color: item.source.color),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      // Thumbnail
                      if (item.thumbnailUrl != null)
                        Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Spacing.radiusMd),
                            child: Image.network(
                              item.thumbnailUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.image, size: 48),
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(Spacing.radiusMd),
                            ),
                            child: Center(
                              child: Icon(
                                item.source.icon,
                                size: 64,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: Spacing.md),
                      // Title
                      Text(
                        item.title ?? 'Untitled',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Spacing.sm),
                      // Description
                      if (item.description != null)
                        Text(
                          item.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const Spacer(),
                      // Expiration warning
                      if (item.isExpiringSoon)
                        Container(
                          padding: const EdgeInsets.all(Spacing.sm),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(Spacing.radiusSm),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.orange, size: 20),
                              const SizedBox(width: Spacing.sm),
                              Text(
                                'Expires ${item.timeUntilExpiration}',
                                style: const TextStyle(color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Consumed button
              FloatingActionButton.extended(
                heroTag: 'consumed',
                onPressed: () => _handleSwipe(false),
                backgroundColor: Colors.green,
                icon: const Icon(Icons.check),
                label: const Text('Consumed'),
              ),
              // Keep button
              FloatingActionButton.extended(
                heroTag: 'keep',
                onPressed: () => _handleSwipe(true),
                backgroundColor: theme.colorScheme.primary,
                icon: const Icon(Icons.bookmark),
                label: const Text('Keep'),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          // Hint text
          Text(
            'Swipe left to mark consumed, right to keep',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
