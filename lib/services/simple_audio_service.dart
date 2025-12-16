import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/track.dart';
import 'audio_service_interface.dart';
import 'web_file_helper.dart';

/// Simple audio service for Web/Desktop (no notification support)
/// Fallback when audio_service is not available
class SimpleAudioService implements AudioServiceInterface {
  final AudioPlayer _player = AudioPlayer();
  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  final Map<String, int> _idToIndex = {};
  List<Track> _currentTracks = [];

  SimpleAudioService() {
    _init();
  }

  Future<void> _init() async {
    // Configure player for gapless loop
    await _player.setLoopMode(LoopMode.all);
    await _player.setAudioSource(_playlist);
  }

  // Load playlist from tracks
  Future<void> loadFromTracks(List<Track> tracks) async {
    _currentTracks = tracks.where((t) => t.isEnabled).toList();

    final children = <AudioSource>[];
    _idToIndex.clear();

    int idx = 0;
    for (final track in _currentTracks) {
      AudioSource? source;

      try {
        if (track.sourceType == SourceType.asset) {
          // Asset files - work on all platforms
          source = AudioSource.uri(Uri.parse('asset://${track.source}'));
        } else if (track.sourceType == SourceType.file) {
          // File from file picker
          if (kIsWeb) {
            // On web, check if we have bytes cached
            final bytes = WebFileHelper.getFileBytes(track.source);
            if (bytes != null) {
              // Create audio source from bytes for web
              source = AudioSource.uri(
                Uri.dataFromBytes(bytes, mimeType: 'audio/mpeg'),
              );
              print('✅ Web: Loaded ${track.title} from bytes (${bytes.length} bytes)');
            } else {
              print('⚠️ Web: No bytes found for ${track.source}');
              continue; // Skip this track
            }
          } else {
            // On native platforms, use file path
            source = AudioSource.uri(Uri.file(track.source));
          }
        }

        if (source != null) {
          children.add(source);
          _idToIndex[track.id] = idx;
          idx++;
        }
      } catch (e) {
        print('⚠️ Error loading track ${track.title}: $e');
        // Skip this track and continue
      }
    }

    if (children.isEmpty) {
      print('⚠️ No valid audio sources to load');
      _playlist = ConcatenatingAudioSource(children: []);
      await _player.setAudioSource(_playlist);
      return;
    }

    _playlist = ConcatenatingAudioSource(children: children);
    await _player.setAudioSource(_playlist, initialIndex: 0, initialPosition: Duration.zero);
    await _player.setLoopMode(LoopMode.all);

    print('✅ Loaded ${children.length} track(s) into player');
  }

  // Playback controls
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();

  Future<void> stop() async {
    await _player.stop();
    await _player.seek(Duration.zero, index: 0);
  }

  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> skipToNext() => _player.seekToNext();
  Future<void> skipToPrevious() => _player.seekToPrevious();

  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _currentTracks.length) return;
    await _player.seek(Duration.zero, index: index);
  }

  // Streams exposed for UI
  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  @override
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  @override
  int? get currentIndex => _player.currentIndex;

  @override
  bool get playing => _player.playing;

  // Cleanup
  @override
  Future<void> dispose() async {
    await _player.dispose();
  }
}

