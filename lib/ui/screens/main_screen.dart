import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../providers/initialization_provider.dart';
import '../../providers/track_list_notifier.dart';
import '../../models/track.dart';
import '../../services/file_import_service.dart';
import 'settings_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(trackListProvider);
    final audioHandlerAsync = ref.watch(audioHandlerProvider);

    return audioHandlerAsync.when(
      data: (audioHandler) => Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/images/NNG.png',
                height: 40,
                width: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('❌ Logo load error: $error');
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple.shade300,
                    ),
                    child: const Icon(Icons.music_note, color: Colors.white, size: 24),
                  );
                },
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NNG AGENT', style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    'by nayrbryanGaming',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shuffle),
              tooltip: 'Shuffle tracks',
              onPressed: () async {
                await ref.read(trackListProvider.notifier).shuffle();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tracks shuffled!')),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Now Playing Card with Media Notification
            NowPlayingCard(audioHandler: audioHandler),

            const Divider(height: 1),

            // Track List
            Expanded(
              child: tracks.isEmpty
                  ? const Center(
                      child: Text('No tracks available'),
                    )
                  : ReorderableListView.builder(
                      itemCount: tracks.length,
                      onReorder: (oldIndex, newIndex) {
                        ref.read(trackListProvider.notifier).reorder(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        return TrackTile(
                          key: ValueKey(track.id),
                          track: track,
                          isCurrentlyPlaying: false,
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addTracks(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Track'),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error loading audio: $error')),
      ),
    );
  }

  Future<void> _addTracks(BuildContext context, WidgetRef ref) async {
    final results = await FileImportService.pickAudioFiles();

    if (results == null || results.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No files selected')),
        );
      }
      return;
    }

    for (final result in results) {
      await ref.read(trackListProvider.notifier).addUserTrack(
        filePath: result.filePath,
        title: result.suggestedTitle,
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${results.length} track(s)')),
      );
    }
  }
}

class NowPlayingCard extends ConsumerWidget {
  final dynamic audioHandler;

  const NowPlayingCard({Key? key, required this.audioHandler}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.album, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder<int?>(
                        stream: audioHandler.currentIndexStream,
                        builder: (context, snapshot) {
                          final tracks = ref.watch(trackListProvider);
                          final enabledTracks = tracks.where((t) => t.isEnabled).toList();
                          final currentIndex = snapshot.data;

                          if (currentIndex != null && currentIndex < enabledTracks.length) {
                            final track = enabledTracks[currentIndex];
                            return Text(
                              track.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          }

                          return const Text('No track playing');
                        },
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.all_inclusive, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Loop All',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            StreamBuilder<Duration>(
              stream: audioHandler.positionStream,
              builder: (context, posSnapshot) {
                return StreamBuilder<Duration?>(
                  stream: audioHandler.durationStream,
                  builder: (context, durSnapshot) {
                    final position = posSnapshot.data ?? Duration.zero;
                    final duration = durSnapshot.data ?? Duration.zero;

                    return Column(
                      children: [
                        Slider(
                          value: position.inMilliseconds.toDouble(),
                          max: duration.inMilliseconds.toDouble().clamp(1.0, double.infinity),
                          onChanged: (value) {
                            audioHandler.seek(Duration(milliseconds: value.toInt()));
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(position)),
                              Text(_formatDuration(duration)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 8),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () => audioHandler.skipToPrevious(),
                  iconSize: 32,
                ),
                StreamBuilder<PlayerState>(
                  stream: audioHandler.playerStateStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return IconButton(
                      icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
                      onPressed: () {
                        if (playing) {
                          audioHandler.pause();
                        } else {
                          audioHandler.play();
                        }
                      },
                      iconSize: 56,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () => audioHandler.stop(),
                  iconSize: 32,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () => audioHandler.skipToNext(),
                  iconSize: 32,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class TrackTile extends ConsumerWidget {
  final Track track;
  final bool isCurrentlyPlaying;

  const TrackTile({
    Key? key,
    required this.track,
    required this.isCurrentlyPlaying,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.drag_handle),
          const SizedBox(width: 8),
          Icon(
            track.isDefault ? Icons.library_music : Icons.audio_file,
            color: isCurrentlyPlaying ? Theme.of(context).colorScheme.primary : null,
          ),
        ],
      ),
      title: Text(
        track.title,
        style: TextStyle(
          fontWeight: isCurrentlyPlaying ? FontWeight.bold : FontWeight.normal,
          color: isCurrentlyPlaying ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      subtitle: Text(
        track.isDefault ? 'Default track' : 'User track',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: track.isEnabled,
            onChanged: (value) {
              ref.read(trackListProvider.notifier).toggleEnabled(track.id);
            },
          ),
          if (!track.isDefault)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ref.read(trackListProvider.notifier).removeTrack(track.id);
              },
            ),
        ],
      ),
    );
  }
}

