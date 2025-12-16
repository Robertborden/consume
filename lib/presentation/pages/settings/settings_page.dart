import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../router/app_router.dart';
import '../../../core/theme/spacing.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userProfile = ref.watch(userProfileProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile Section
          userProfile.when(
            data: (user) => ListTile(
              leading: CircleAvatar(
                backgroundImage: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl!)
                    : null,
                child: user?.avatarUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(user?.displayName ?? 'User'),
              subtitle: Text(user?.email ?? ''),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to profile edit
              },
            ),
            loading: () => const ListTile(
              leading: CircleAvatar(child: CircularProgressIndicator()),
              title: Text('Loading...'),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const Divider(),
          // Preferences Section
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Text(
              'PREFERENCES',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Theme
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(_getThemeModeLabel(themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(context, ref),
          ),
          // Default Expiry
          userProfile.when(
            data: (user) => ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Default Expiry'),
              subtitle: Text('${user?.defaultExpiryDays ?? 7} days'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showExpiryPicker(context, ref, user?.defaultExpiryDays ?? 7),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Daily Review Goal
          userProfile.when(
            data: (user) => ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Daily Review Goal'),
              subtitle: Text('${user?.dailyReviewGoal ?? 5} items'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showGoalPicker(context, ref, user?.dailyReviewGoal ?? 5),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const Divider(),
          // Notifications Section
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Text(
              'NOTIFICATIONS',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          userProfile.when(
            data: (user) => SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('Push Notifications'),
              subtitle: const Text('Daily reminders and expiration alerts'),
              value: user?.notificationsEnabled ?? true,
              onChanged: (value) {
                ref.read(userControllerProvider).updateNotificationSettings(
                  enabled: value,
                );
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          userProfile.when(
            data: (user) => ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Reminder Time'),
              subtitle: Text(user?.reminderTime ?? '09:00'),
              trailing: const Icon(Icons.chevron_right),
              enabled: user?.notificationsEnabled ?? true,
              onTap: () => _showTimePicker(context, ref),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const Divider(),
          // About Section
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Text(
              'ABOUT',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outlined),
            title: const Text('About CONSUME'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'CONSUME',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Save less. Consume more.',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // Open privacy policy URL
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // Open terms URL
            },
          ),
          const Divider(),
          // Danger Zone
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Text(
              'ACCOUNT',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Sign Out',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _confirmSignOut(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _confirmDeleteAccount(context, ref),
          ),
          const SizedBox(height: Spacing.xl),
        ],
      ),
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_auto),
            title: const Text('System'),
            onTap: () {
              ref.read(themeModeProvider.notifier).setTheme(ThemeMode.system);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.light_mode),
            title: const Text('Light'),
            onTap: () {
              ref.read(themeModeProvider.notifier).setTheme(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark'),
            onTap: () {
              ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showExpiryPicker(BuildContext context, WidgetRef ref, int currentValue) {
    final options = [3, 5, 7, 14, 21, 30];
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((days) => ListTile(
          title: Text('$days days'),
          trailing: days == currentValue ? const Icon(Icons.check) : null,
          onTap: () {
            ref.read(userControllerProvider).updateDefaultExpiryDays(days);
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }

  void _showGoalPicker(BuildContext context, WidgetRef ref, int currentValue) {
    final options = [3, 5, 10, 15, 20];
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((goal) => ListTile(
          title: Text('$goal items per day'),
          trailing: goal == currentValue ? const Icon(Icons.check) : null,
          onTap: () {
            ref.read(userControllerProvider).updateDailyReviewGoal(goal);
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }

  void _showTimePicker(BuildContext context, WidgetRef ref) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (time != null) {
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      ref.read(userControllerProvider).updateNotificationSettings(
        reminderTime: timeString,
      );
    }
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(authControllerProvider).signOut();
              if (context.mounted) {
                Navigator.pop(context);
                context.go(AppRoutes.login);
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
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
              // TODO: Implement account deletion
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
