import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/items_provider.dart';
import '../../providers/user_provider.dart';
import '../../router/app_router.dart';
import '../../../core/theme/spacing.dart';
import '../../../domain/entities/enums/item_status.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(savedItemsProvider);
    final userProfile = ref.watch(userProfileProvider);
    final unreviewedCount = ref.watch(unreviewedCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CONSUME'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(savedItemsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Header with stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    userProfile.when(
                      data: (user) => Text(
                        'Hello, ${user?.displayName ?? 'there'}!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: Spacing.sm),
                    // Quick stats card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              icon: Icons.inbox,
                              label: 'To Review',
                              value: unreviewedCount.toString(),
                              color: theme.colorScheme.primary,
                            ),
                            userProfile.when(
                              data: (user) => _StatItem(
                                icon: Icons.local_fire_department,
                                label: 'Streak',
                                value: '${user?.currentStreak ?? 0}',
                                color: Colors.orange,
                              ),
                              loading: () => const _StatItem(
                                icon: Icons.local_fire_department,
                                label: 'Streak',
                                value: '-',
                                color: Colors.orange,
                              ),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                            items.when(
                              data: (list) => _StatItem(
                                icon: Icons.check_circle,
                                label: 'Consumed',
                                value: list
                                    .where((i) => i.status == ItemStatus.consumed)
                                    .length
                                    .toString(),
                                color: Colors.green,
                              ),
                              loading: () => const _StatItem(
                                icon: Icons.check_circle,
                                label: 'Consumed',
                                value: '-',
                                color: Colors.green,
                              ),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    // Review CTA
                    if (unreviewedCount > 0)
                      FilledButton.icon(
                        onPressed: () => context.go(AppRoutes.review),
                        icon: const Icon(Icons.swipe),
                        label: Text('Review $unreviewedCount items'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg,
                  vertical: Spacing.sm,
                ),
                child: Text(
                  'Recent Items',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Items list
            items.when(
              data: (list) {
                if (list.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_outline,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: Spacing.md),
                          Text(
                            'No saved items yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: Spacing.sm),
                          Text(
                            'Share content from other apps to save it here',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = list[index];
                      return ListTile(
                        leading: item.faviconUrl != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(item.faviconUrl!),
                              )
                            : CircleAvatar(
                                child: Icon(item.source.icon),
                              ),
                        title: Text(
                          item.title ?? item.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          item.source.displayName,
                          style: TextStyle(color: item.source.color),
                        ),
                        trailing: item.isPinned
                            ? const Icon(Icons.push_pin, size: 16)
                            : null,
                        onTap: () => context.push(
                          AppRoutes.itemDetailPath(item.id),
                        ),
                      );
                    },
                    childCount: list.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: Spacing.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
