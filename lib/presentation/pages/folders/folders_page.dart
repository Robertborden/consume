import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/folders_provider.dart';
import '../../providers/items_provider.dart';
import '../../../core/theme/spacing.dart';
import '../../../domain/entities/folder.dart';

class FoldersPage extends ConsumerWidget {
  const FoldersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final folders = ref.watch(foldersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateFolderDialog(context, ref),
          ),
        ],
      ),
      body: folders.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    'No folders yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  FilledButton.icon(
                    onPressed: () => _showCreateFolderDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Folder'),
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(Spacing.md),
            itemCount: list.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              final folderIds = list.map((f) => f.id).toList();
              final id = folderIds.removeAt(oldIndex);
              folderIds.insert(newIndex, id);
              ref.read(foldersControllerProvider).reorderFolders(folderIds);
            },
            itemBuilder: (context, index) {
              final folder = list[index];
              return _FolderTile(
                key: ValueKey(folder.id),
                folder: folder,
                onTap: () => _showFolderItems(context, ref, folder),
                onEdit: () => _showEditFolderDialog(context, ref, folder),
                onDelete: () => _confirmDelete(context, ref, folder),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedColor = Folder.availableColors.first;
    String selectedIcon = Folder.availableIcons.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Folder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Folder Name',
                  hintText: 'e.g., Work, Personal, Read Later',
                ),
                autofocus: true,
              ),
              const SizedBox(height: Spacing.md),
              // Color picker
              Wrap(
                spacing: Spacing.sm,
                children: Folder.availableColors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: selectedColor == color
                            ? Border.all(width: 3, color: Colors.black)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                
                final folder = Folder(
                  id: '',
                  userId: '',
                  name: nameController.text.trim(),
                  colorHex: selectedColor,
                  iconName: selectedIcon,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                
                await ref.read(foldersControllerProvider).createFolder(folder);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFolderDialog(BuildContext context, WidgetRef ref, Folder folder) {
    final nameController = TextEditingController(text: folder.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Folder'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Folder Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              
              final updated = folder.copyWith(
                name: nameController.text.trim(),
                updatedAt: DateTime.now(),
              );
              
              await ref.read(foldersControllerProvider).updateFolder(updated);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Folder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder?'),
        content: Text(
          'Are you sure you want to delete "${folder.name}"? Items in this folder will be moved to Inbox.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await ref.read(foldersControllerProvider).deleteFolder(folder.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFolderItems(BuildContext context, WidgetRef ref, Folder folder) {
    ref.read(selectedFolderProvider.notifier).state = folder;
    // Navigate to folder items view or show bottom sheet
  }
}

class _FolderTile extends StatelessWidget {
  final Folder folder;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FolderTile({
    super.key,
    required this.folder,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(int.parse(folder.colorHex.replaceFirst('#', '0xFF')));

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            Icons.folder,
            color: color,
          ),
        ),
        title: Text(folder.name),
        subtitle: Text('${folder.itemCount} items'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (folder.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Text(
                  'Default',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (!folder.isDefault)
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ],
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
            ),
            ReorderableDragStartListener(
              index: 0,
              child: const Icon(Icons.drag_handle),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
