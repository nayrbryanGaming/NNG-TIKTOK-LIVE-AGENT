import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_notifier.dart';
import '../../providers/track_list_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // Appearance Section
          ListTile(
            title: Text(
              'APPEARANCE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: settings.darkMode,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setDarkMode(value);
            },
            secondary: const Icon(Icons.dark_mode),
          ),

          const Divider(),

          // Playback Section
          ListTile(
            title: Text(
              'PLAYBACK',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Auto-play on Start'),
            subtitle: const Text('Start playing when app opens'),
            value: settings.autoPlayOnStart,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setAutoPlayOnStart(value);
            },
            secondary: const Icon(Icons.play_circle),
          ),
          SwitchListTile(
            title: const Text('Remember Last Position'),
            subtitle: const Text('Resume from where you left off'),
            value: settings.rememberPosition,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setRememberPosition(value);
            },
            secondary: const Icon(Icons.history),
          ),

          const Divider(),

          // Playlist Section
          ListTile(
            title: Text(
              'PLAYLIST',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Reset to Default Tracks'),
            subtitle: const Text('Remove all user tracks and reset playlist'),
            onTap: () => _showResetDialog(context, ref),
          ),

          const Divider(),

          // About Section
          ListTile(
            title: Text(
              'ABOUT',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('NNG AGENT'),
            subtitle: Text('by nayrbryanGaming\n\nEndless audio loop player with gapless playback.\n\nBuilt with Flutter, just_audio, and Riverpod.'),
            isThreeLine: true,
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              '© 2025 nayrbryanGaming',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _showResetDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Playlist?'),
        content: const Text(
          'This will remove all user-added tracks and reset the playlist to default tracks only. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(trackListProvider.notifier).resetToDefaults();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Playlist reset to defaults')),
        );
        Navigator.pop(context);
      }
    }
  }
}

