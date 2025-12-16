import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../providers/items_provider.dart';
import '../../../core/theme/spacing.dart';
import '../../../domain/entities/enums/item_status.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(userStatisticsProvider);
    final items = ref.watch(savedItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userStatisticsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Guilt Meter
              stats.when(
                data: (data) => _GuiltMeterCard(
                  percentage: data.guiltMeterPercentage,
                ),
                loading: () => const _GuiltMeterCard(percentage: 0),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: Spacing.lg),
              // Overview Stats
              Text(
                'Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Spacing.md),
              stats.when(
                data: (data) => Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Saved',
                        value: data.totalSaved.toString(),
                        icon: Icons.bookmark,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: _StatCard(
                        title: 'Consumed',
                        value: data.totalConsumed.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: Spacing.md),
              stats.when(
                data: (data) => Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Expired',
                        value: data.totalExpired.toString(),
                        icon: Icons.timer_off,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: _StatCard(
                        title: 'Consume Rate',
                        value: '${data.consumptionRate.toStringAsFixed(1)}%',
                        icon: Icons.trending_up,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: Spacing.xl),
              // Streaks
              Text(
                'Streaks',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Spacing.md),
              stats.when(
                data: (data) => Row(
                  children: [
                    Expanded(
                      child: _StreakCard(
                        title: 'Current Streak',
                        days: data.currentStreak,
                        isActive: true,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: _StreakCard(
                        title: 'Longest Streak',
                        days: data.longestStreak,
                        isActive: false,
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: Spacing.xl),
              // Items by Source
              Text(
                'Items by Source',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Spacing.md),
              items.when(
                data: (list) {
                  final sourceCounts = <String, int>{};
                  for (final item in list) {
                    final source = item.source.displayName;
                    sourceCounts[source] = (sourceCounts[source] ?? 0) + 1;
                  }
                  
                  final sortedSources = sourceCounts.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));

                  if (sortedSources.isEmpty) {
                    return const Text('No data yet');
                  }

                  return Column(
                    children: sortedSources.take(5).map((entry) {
                      final percentage = (entry.value / list.length) * 100;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.sm),
                        child: _SourceBar(
                          source: entry.key,
                          count: entry.value,
                          percentage: percentage,
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuiltMeterCard extends StatelessWidget {
  final double percentage;

  const _GuiltMeterCard({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = percentage > 70
        ? Colors.red
        : percentage > 40
            ? Colors.orange
            : Colors.green;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Guilt Meter',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  percentage > 70
                      ? Icons.sentiment_very_dissatisfied
                      : percentage > 40
                          ? Icons.sentiment_neutral
                          : Icons.sentiment_very_satisfied,
                  color: color,
                  size: 32,
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              '${percentage.toStringAsFixed(1)}% of items unreviewed',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: Spacing.sm),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final String title;
  final int days;
  final bool isActive;

  const _StreakCard({
    required this.title,
    required this.days,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: isActive ? Colors.orange.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          children: [
            Icon(
              Icons.local_fire_department,
              color: isActive ? Colors.orange : theme.colorScheme.outline,
              size: 32,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              '$days',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.orange : null,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceBar extends StatelessWidget {
  final String source;
  final int count;
  final double percentage;

  const _SourceBar({
    required this.source,
    required this.count,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(source),
            Text('$count items'),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
