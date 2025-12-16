import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';

/// Abstract interface untuk audio service (works on all platforms)
abstract class AudioServiceInterface {
  Future<void> loadFromTracks(List<Track> tracks);

  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> skipToNext();
  Future<void> skipToPrevious();
  Future<void> skipToQueueItem(int index);

  Stream<Duration?> get durationStream;
  Stream<Duration> get positionStream;
  Stream<int?> get currentIndexStream;
  Stream<PlayerState> get playerStateStream;

  int? get currentIndex;
  bool get playing;

  Future<void> dispose();
}

