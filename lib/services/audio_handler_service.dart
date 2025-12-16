import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';
import 'audio_service_interface.dart';

/// AudioHandler untuk media notification dan background playback (Mobile only)
class NNGAgentAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler
    implements AudioServiceInterface {
  final AudioPlayer _player = AudioPlayer();
  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  final Map<String, int> _idToIndex = {};
  List<Track> _currentTracks = [];

  NNGAgentAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // Configure player for gapless loop
    await _player.setLoopMode(LoopMode.all);

    // Listen to player state and broadcast to notification
    _player.playbackEventStream.listen(_broadcastState);

    // Listen to current index changes and update mediaItem
    _player.currentIndexStream.listen((index) {
      if (index != null && index < _currentTracks.length) {
        final track = _currentTracks[index];
        mediaItem.add(MediaItem(
          id: track.id,
          album: 'NNG AGENT by nayrbryanGaming',
          title: track.title,
          artUri: Uri.parse('asset:///assets/images/NNG.png'),
          duration: Duration.zero, // Will update when loaded
        ));
      }
    });

    // Listen to duration and update mediaItem
    _player.durationStream.listen((duration) {
      final current = mediaItem.value;
      if (current != null && duration != null) {
        mediaItem.add(current.copyWith(duration: duration));
      }
    });
  }

  // Broadcast player state to notification
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _player.currentIndex,
    ));
  }

  // Load playlist from tracks
  Future<void> loadFromTracks(List<Track> tracks) async {
    _currentTracks = tracks.where((t) => t.isEnabled).toList();

    final children = <AudioSource>[];
    final queue = <MediaItem>[];
    _idToIndex.clear();

    int idx = 0;
    for (final track in _currentTracks) {
      AudioSource? source;

      try {
        if (track.sourceType == SourceType.asset) {
          // Asset files
          source = AudioSource.uri(Uri.parse('asset://${track.source}'));
        } else if (track.sourceType == SourceType.file) {
          // User-selected files - use file URI for native platforms
          source = AudioSource.uri(Uri.file(track.source));
        }

        if (source != null) {
          children.add(source);

          queue.add(MediaItem(
            id: track.id,
            album: 'NNG AGENT by nayrbryanGaming',
            title: track.title,
            artUri: Uri.parse('asset://assets/images/NNG.png'),
          ));

          _idToIndex[track.id] = idx;
          idx++;
        }
      } catch (e) {
        print('⚠️ Error loading track ${track.title}: $e');
        // Skip this track
      }
    }

    if (children.isEmpty) {
      print('⚠️ No valid audio sources to load');
      return;
    }

    _playlist = ConcatenatingAudioSource(children: children);
    await _player.setAudioSource(_playlist, initialIndex: 0, initialPosition: Duration.zero);
    await _player.setLoopMode(LoopMode.all);

    // Update queue
    this.queue.add(queue);

    // Set initial mediaItem
    if (_currentTracks.isNotEmpty) {
      mediaItem.add(queue.first);
    }

    print('✅ Loaded ${children.length} track(s) into player');
  }
    }
  }

  // Playback controls
  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await _player.seek(Duration.zero, index: 0);
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _currentTracks.length) return;
    await _player.seek(Duration.zero, index: index);
  }

  // Streams exposed for UI
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  int? get currentIndex => _player.currentIndex;
  bool get playing => _player.playing;

  // Cleanup
  @override
  Future<void> dispose() async {
    await _player.dispose();
  }
}

