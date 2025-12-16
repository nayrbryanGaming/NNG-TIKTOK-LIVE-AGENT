import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/track.dart';
import '../services/storage_service.dart';
import '../services/audio_service_interface.dart';
import 'initialization_provider.dart';

// StateNotifier to manage the track list
class TrackListNotifier extends StateNotifier<List<Track>> {
  final AudioServiceInterface _audioHandler;
  final Uuid _uuid = const Uuid();

  TrackListNotifier(this._audioHandler) : super([]) {
    _loadTracks();
  }

  void _loadTracks() {
    state = StorageService.getAllTracks();
  }

  Future<void> addTrack(Track track) async {
    await StorageService.addTrack(track);
    state = [...state, track];
    await _audioHandler.loadFromTracks(state);
  }

  Future<void> addUserTrack({
    required String filePath,
    required String title,
    String? artist,
  }) async {
    final maxOrder = state.isEmpty ? 0 : state.map((t) => t.orderIndex).reduce((a, b) => a > b ? a : b);
    final track = Track(
      id: _uuid.v4(),
      title: title,
      artist: artist,
      sourceType: SourceType.file,
      source: filePath,
      isDefault: false,
      orderIndex: maxOrder + 1,
      isEnabled: true,
    );
    await addTrack(track);
  }

  Future<void> removeTrack(String id) async {
    final track = state.firstWhere((t) => t.id == id);
    if (track.isDefault) {
      // Don't allow removing default tracks, just disable them
      return;
    }
    await StorageService.removeTrack(id);
    state = state.where((t) => t.id != id).toList();
    await _audioHandler.loadFromTracks(state);
  }

  Future<void> toggleEnabled(String id) async {
    final index = state.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final track = state[index];
    track.isEnabled = !track.isEnabled;
    await StorageService.updateTrack(track);

    state = [...state];
    await _audioHandler.loadFromTracks(state);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final tracks = [...state];
    final track = tracks.removeAt(oldIndex);
    tracks.insert(newIndex, track);

    // Update order indices
    for (var i = 0; i < tracks.length; i++) {
      tracks[i].orderIndex = i;
      await StorageService.updateTrack(tracks[i]);
    }

    state = tracks;
    await _audioHandler.loadFromTracks(state);
  }

  Future<void> resetToDefaults() async {
    // Disable all user tracks, enable all default tracks
    for (final track in state) {
      if (track.isDefault) {
        track.isEnabled = true;
      } else {
        await StorageService.removeTrack(track.id);
      }
    }
    state = state.where((t) => t.isDefault).toList();
    await _audioHandler.loadFromTracks(state);
  }

  Future<void> shuffle() async {
    // Shuffle the track list randomly
    final tracks = [...state];
    final random = Random();

    for (var i = tracks.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      // Swap
      final temp = tracks[i];
      tracks[i] = tracks[j];
      tracks[j] = temp;
    }

    // Update order indices
    for (var i = 0; i < tracks.length; i++) {
      tracks[i].orderIndex = i;
      await StorageService.updateTrack(tracks[i]);
    }

    state = tracks;
    await _audioHandler.loadFromTracks(state);
  }
}

// Provider untuk TrackListNotifier - depends on audioHandler being ready
final trackListProvider = StateNotifierProvider<TrackListNotifier, List<Track>>((ref) {
  // This will throw if not ready, but that's ok because we wait in initialization
  final audioHandler = ref.watch(audioHandlerProvider).value!;
  return TrackListNotifier(audioHandler);
});

