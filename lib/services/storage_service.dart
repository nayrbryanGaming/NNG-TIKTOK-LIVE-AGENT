import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import '../models/track.dart';

class StorageService {
  static const String tracksBoxName = 'tracks_box';
  static const String settingsBoxName = 'settings_box';

  static bool _isInitialized = false;
  static bool _isWeb = false;

  // In-memory storage for web
  static final Map<String, Map<dynamic, dynamic>> _memoryStorage = {
    tracksBoxName: {},
    settingsBoxName: {},
  };

  static Future<void> init() async {
    if (_isInitialized) return;

    // Detect if running on web using kIsWeb constant
    _isWeb = kIsWeb;

    // On web, skip Hive initialization - use fallback
    if (_isWeb) {
      print('Running on web - using in-memory storage');
      _isInitialized = true;
      return;
    }

    try {
      // Initialize Hive and register adapters (desktop/mobile only)
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TrackAdapter());
      }

      // Open boxes if not already open
      if (!Hive.isBoxOpen(tracksBoxName)) {
        await Hive.openBox<Track>(tracksBoxName);
      }
      if (!Hive.isBoxOpen(settingsBoxName)) {
        await Hive.openBox(settingsBoxName);
      }

      _isInitialized = true;
    } catch (e) {
      print('Hive initialization error: $e');
      // Fallback to in-memory storage
      _isWeb = true;
      _isInitialized = true;
    }
  }


  static Box<Track> get tracksBox {
    if (!_isInitialized) {
      print('Warning: Storage not initialized, using in-memory fallback');
      return _InMemoryBox<Track>(_memoryStorage[tracksBoxName]!);
    }

    if (_isWeb) {
      return _InMemoryBox<Track>(_memoryStorage[tracksBoxName]!);
    }

    try {
      if (Hive.isBoxOpen(tracksBoxName)) {
        return Hive.box<Track>(tracksBoxName);
      } else {
        print('Warning: tracksBox not open, using in-memory fallback');
        return _InMemoryBox<Track>(_memoryStorage[tracksBoxName]!);
      }
    } catch (e) {
      print('Error accessing tracksBox: $e');
      return _InMemoryBox<Track>(_memoryStorage[tracksBoxName]!);
    }
  }

  static Box<dynamic> get settingsBox {
    if (!_isInitialized) {
      print('Warning: Storage not initialized, using in-memory fallback');
      return _InMemoryBox<dynamic>(_memoryStorage[settingsBoxName]!);
    }

    if (_isWeb) {
      return _InMemoryBox<dynamic>(_memoryStorage[settingsBoxName]!);
    }

    try {
      if (Hive.isBoxOpen(settingsBoxName)) {
        return Hive.box(settingsBoxName);
      } else {
        print('Warning: settingsBox not open, using in-memory fallback');
        return _InMemoryBox<dynamic>(_memoryStorage[settingsBoxName]!);
      }
    } catch (e) {
      print('Error accessing settingsBox: $e');
      return _InMemoryBox<dynamic>(_memoryStorage[settingsBoxName]!);
    }
  }

  // CRUD helpers for tracks
  static List<Track> getAllTracks() {
    final box = tracksBox;
    final tracks = <Track>[];

    try {
      tracks.addAll(box.values.whereType<Track>().toList());
      tracks.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    } catch (_) {
      print('Error getting all tracks');
    }

    return tracks;
  }

  static Future<void> addTrack(Track track) async {
    final box = tracksBox;
    try {
      await box.put(track.id, track);
    } catch (_) {
      print('Error adding track');
    }
  }

  static Future<void> updateTrack(Track track) async {
    final box = tracksBox;
    try {
      await box.put(track.id, track);
    } catch (_) {
      print('Error updating track');
    }
  }

  static Future<void> removeTrack(String id) async {
    final box = tracksBox;
    try {
      await box.delete(id);
    } catch (_) {
      print('Error removing track');
    }
  }

  static Future<void> clearTracks() async {
    final box = tracksBox;
    try {
      await box.clear();
    } catch (_) {
      print('Error clearing tracks');
    }
  }

  // Get singleton instance
  static StorageService get instance => StorageService._();

  StorageService._();

  // Settings helpers (instance methods)
  Future<bool?> getDarkMode() async {
    final box = settingsBox;
    try {
      return box.get('darkMode') as bool?;
    } catch (_) {
      return null;
    }
  }

  Future<void> setDarkMode(bool value) async {
    final box = settingsBox;
    try {
      await box.put('darkMode', value);
    } catch (_) {
      print('Error setting dark mode');
    }
  }

  Future<bool?> getAutoPlayOnStart() async {
    final box = settingsBox;
    try {
      return box.get('autoPlayOnStart') as bool?;
    } catch (_) {
      return null;
    }
  }

  Future<void> setAutoPlayOnStart(bool value) async {
    final box = settingsBox;
    try {
      await box.put('autoPlayOnStart', value);
    } catch (_) {
      print('Error setting auto play on start');
    }
  }

  Future<bool?> getRememberPosition() async {
    final box = settingsBox;
    try {
      return box.get('rememberPosition') as bool?;
    } catch (_) {
      return null;
    }
  }

  Future<void> setRememberPosition(bool value) async {
    final box = settingsBox;
    try {
      await box.put('rememberPosition', value);
    } catch (_) {
      print('Error setting remember position');
    }
  }
}

/// Simple in-memory box implementation for web
class _InMemoryBox<T> implements Box<T> {
  final Map<dynamic, dynamic> _data;

  _InMemoryBox(this._data);

  @override
  Future<int> add(T value) async {
    final key = _data.length;
    _data[key] = value;
    return key;
  }

  @override
  Future<Iterable<int>> addAll(Iterable<T> values) async {
    final keys = <int>[];
    for (final value in values) {
      final key = _data.length;
      _data[key] = value;
      keys.add(key);
    }
    return keys;
  }

  @override
  Future<int> clear() async {
    final count = _data.length;
    _data.clear();
    return count;
  }

  @override
  Future<void> compact() async {}

  @override
  bool containsKey(dynamic key) => _data.containsKey(key);

  @override
  Future<void> delete(dynamic key) async => _data.remove(key);

  @override
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    for (final key in keys) {
      _data.remove(key);
    }
  }

  @override
  Future<void> deleteAt(int index) async {}

  @override
  Future<int> deleteWhere(bool Function(T) filter) async {
    var count = 0;
    final keysToRemove = <dynamic>[];
    for (final entry in _data.entries) {
      if (filter(entry.value as T)) {
        keysToRemove.add(entry.key);
        count++;
      }
    }
    for (final key in keysToRemove) {
      _data.remove(key);
    }
    return count;
  }

  @override
  Future<void> flush() async {}

  @override
  T? get(dynamic key, {T? defaultValue}) =>
      _data[key] as T? ?? defaultValue;

  @override
  T? getAt(int index) {
    if (index < 0 || index >= _data.length) return null;
    return _data.values.toList()[index] as T?;
  }

  @override
  Future<T?> getAsync(dynamic key, {T? defaultValue}) async =>
      get(key, defaultValue: defaultValue);

  @override
  Future<T?> getAsyncAt(int index) async => getAt(index);

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  bool get isOpen => true;

  @override
  bool get lazy => false;

  @override
  dynamic keyAt(int index) {
    if (index < 0 || index >= _data.length) return null;
    return _data.keys.toList()[index];
  }

  @override
  Iterable<dynamic> get keys => _data.keys;

  @override
  int get length => _data.length;

  @override
  String get name => 'in_memory_box';

  @override
  String? get path => null;

  @override
  Future<void> put(dynamic key, T value) async => _data[key] = value;

  @override
  Future<void> putAll(Map<dynamic, T> entries) async => _data.addAll(entries);

  @override
  Future<void> putAt(int index, T value) async {
    if (index >= 0 && index < _data.length) {
      final key = _data.keys.toList()[index];
      _data[key] = value;
    }
  }

  @override
  Future<int> putWhere(T value, bool Function(T) filter) async {
    var count = 0;
    final entriesToUpdate = <dynamic, T>{};
    for (final entry in _data.entries) {
      if (filter(entry.value as T)) {
        entriesToUpdate[entry.key] = value;
        count++;
      }
    }
    _data.addAll(entriesToUpdate);
    return count;
  }

  @override
  Map<dynamic, T> toMap() => Map<dynamic, T>.from(_data);

  @override
  Iterable<T> valuesBetween({dynamic startKey, dynamic endKey}) =>
      _data.values.whereType<T>();

  @override
  Stream<BoxEvent> watch({dynamic key}) => Stream.empty();

  @override
  Iterable<T> get values => _data.values.whereType<T>();

  @override
  Future<void> putIfAbsent(dynamic key, T Function() ifAbsent,
      {bool save = true}) async {
    if (!_data.containsKey(key)) {
      _data[key] = ifAbsent();
    }
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> deleteFromDisk() async {}
}

