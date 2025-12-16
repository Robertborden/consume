import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/items_provider.dart';
import '../../providers/folders_provider.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/extensions/datetime_extensions.dart';
import '../../../domain/entities/saved_item.dart';

class ItemDetailPage extends ConsumerWidget {
  final String itemId;

  const ItemDetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(savedItemsProvider);
    final folders = ref.watch(foldersProvider);

    return items.when(
      data: (list) {
        final item = list.where((i) => i.id == itemId).firstOrNull;
        
        if (item == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Item not found')),
          );
        }

        final folder = folders.valueOrNull
            ?.where((f) => f.id == item.folderId)
            .firstOrNull;

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: Icon(
                  item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                ),
                onPressed: () {
                  ref.read(itemsControllerProvider).togglePin(itemId);
                },
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'copy',
                    child: ListTile(
                      leading: Icon(Icons.copy),
                      title: Text('Copy URL'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: ListTile(
                      leading: Icon(Icons.share),
                      title: Text('Share'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'archive',
                    child: ListTile(
                      leading: Icon(Icons.archive),
                      title: Text('Archive'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                onSelected: (value) => _handleMenuAction(context, ref, value, item),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                if (item.thumbnailUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
                    child: Image.network(
                      item.thumbnailUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                if (item.thumbnailUrl != null)
                  const SizedBox(height: Spacing.lg),
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
                // Title
                Text(
                  item.title ?? 'Untitled',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                // URL
                InkWell(
                  onTap: () => _openUrl(item.url),
                  child: Text(
                    item.url,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                // Description
                if (item.description != null) ...[
                  Text(
                    item.description!,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: Spacing.lg),
                ],
                // Metadata
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.md),
                    child: Column(
                      children: [
                        _MetadataRow(
                          icon: Icons.access_time,
                          label: 'Saved',
                          value: item.createdAt.timeAgo,
                        ),
                        const Divider(),
                        _MetadataRow(
                          icon: Icons.hourglass_bottom,
                          label: 'Expires',
                          value: item.expiresAt?.timeUntil ?? 'Never',
                          valueColor: item.isExpiringSoon ? Colors.orange : null,
                        ),
                        const Divider(),
                        _MetadataRow(
                          icon: Icons.folder,
                          label: 'Folder',
                          value: folder?.name ?? 'None',
                        ),
                        const Divider(),
                        _MetadataRow(
                          icon: Icons.label,
                          label: 'Status',
                          value: item.status.name.toUpperCase(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                // Tags
                if (item.tags.isNotEmpty) ...[
                  Text(
                    'Tags',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Wrap(
                    spacing: Spacing.sm,
                    children: item.tags.map((tag) => Chip(
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                  const SizedBox(height: Spacing.lg),
                ],
                // Notes
                if (item.notes != null) ...[
                  Text(
                    'Notes',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(item.notes!),
                ],
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(itemsControllerProvider).markAsConsumed(itemId);
                        context.pop();
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Mark Consumed'),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _openUrl(item.url),
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Open'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    SavedItem item,
  ) {
    switch (action) {
      case 'copy':
        Clipboard.setData(ClipboardData(text: item.url));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL copied to clipboard')),
        );
        break;
      case 'share':
        // TODO: Implement share
        break;
      case 'archive':
        ref.read(itemsControllerProvider).archiveItem(itemId);
        context.pop();
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Item?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  ref.read(itemsControllerProvider).deleteItem(itemId);
                  Navigator.pop(context);
                  context.pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _MetadataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.outline),
          const SizedBox(width: Spacing.sm),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
