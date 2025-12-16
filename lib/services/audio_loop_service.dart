import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

import '../models/track.dart';

class AudioLoopService {
  final AudioPlayer _player = AudioPlayer();
  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  // Map from track id to current playlist index
  final Map<String, int> _idToIndex = {};

  AudioLoopService();

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Configure player for gapless playback
    await _player.setLoopMode(LoopMode.all);

    // Optionally set crossfade
    // _player.setCrossfadeEnabled(true);
    // _player.setCrossfadeDuration(Duration(milliseconds: 300));

    // Set empty playlist initially
    await _player.setAudioSource(_playlist);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  int? get currentIndex => _player.currentIndex;
  bool get playing => _player.playing;

  // Build playlist from a list of Tracks (only include enabled ones). This replaces the playlist.
  Future<void> loadFromTracks(List<Track> tracks) async {
    // Build children
    final children = <AudioSource>[];
    _idToIndex.clear();
    int idx = 0;
    for (final t in tracks.where((t) => t.isEnabled)) {
      AudioSource source;
      if (t.sourceType == SourceType.asset) {
        // just_audio supports AudioSource.asset helper via AudioSource.uri with asset scheme
        source = AudioSource.uri(Uri.parse('asset://${t.source}'), tag: t);
      } else {
        // file or uri
        source = AudioSource.uri(Uri.parse(t.source), tag: t);
      }
      children.add(source);
      _idToIndex[t.id] = idx;
      idx++;
    }

    _playlist = ConcatenatingAudioSource(children: children);

    // If the player was playing, remember current position & index to try to restore
    final wasPlaying = _player.playing;
    final savedIndex = _player.currentIndex;
    final savedPosition = _player.position;

    await _player.setAudioSource(_playlist, initialIndex: savedIndex ?? 0, initialPosition: savedPosition);
    await _player.setLoopMode(LoopMode.all);

    if (wasPlaying) {
      await _player.play();
    }
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    // reset to start
    if (_playlist.children.isNotEmpty) {
      await _player.seek(Duration.zero, index: 0);
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> next() async {
    try {
      await _player.seekToNext();
    } catch (_) {}
  }

  Future<void> previous() async {
    try {
      await _player.seekToPrevious();
    } catch (_) {}
  }

  // Insert a track's audio source at index (or end)
  Future<void> insertTrack(Track track, {int? atIndex}) async {
    AudioSource source;
    if (track.sourceType == SourceType.asset) {
      source = AudioSource.uri(Uri.parse('asset://${track.source}'), tag: track);
    } else {
      source = AudioSource.uri(Uri.parse(track.source), tag: track);
    }
    final insertIndex = atIndex ?? _playlist.length;
    await _playlist.insert(insertIndex, source);
    // rebuild idToIndex map
    await _rebuildIdIndexMap();
  }

  Future<void> removeTrackById(String id) async {
    final index = _idToIndex[id];
    if (index == null) return;
    await _playlist.removeAt(index);
    await _rebuildIdIndexMap();
  }

  Future<void> moveTrack(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || newIndex < 0 || oldIndex >= _playlist.length || newIndex >= _playlist.length) return;
    await _playlist.move(oldIndex, newIndex);
    await _rebuildIdIndexMap();
  }

  Future<void> _rebuildIdIndexMap() async {
    _idToIndex.clear();
    // Rebuild map based on current playlist children count
    // In just_audio 0.9.46+, we track by index position, not by tag
    // Since we control the order, index position = track position
    for (var i = 0; i < _playlist.children.length; i++) {
      _idToIndex['track_$i'] = i;
    }
  }
}


