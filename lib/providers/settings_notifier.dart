import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class SettingsState {
  final bool darkMode;
  final bool autoPlayOnStart;
  final bool rememberPosition;

  const SettingsState({
    this.darkMode = false,
    this.autoPlayOnStart = false,
    this.rememberPosition = true,
  });

  SettingsState copyWith({
    bool? darkMode,
    bool? autoPlayOnStart,
    bool? rememberPosition,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      autoPlayOnStart: autoPlayOnStart ?? this.autoPlayOnStart,
      rememberPosition: rememberPosition ?? this.rememberPosition,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final StorageService _storage;

  SettingsNotifier(this._storage) : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final darkMode = await _storage.getDarkMode() ?? false;
      final autoPlay = await _storage.getAutoPlayOnStart() ?? false;
      final rememberPos = await _storage.getRememberPosition() ?? true;

      state = SettingsState(
        darkMode: darkMode,
        autoPlayOnStart: autoPlay,
        rememberPosition: rememberPos,
      );
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> setDarkMode(bool value) async {
    state = state.copyWith(darkMode: value);
    await _storage.setDarkMode(value);
  }

  Future<void> setAutoPlayOnStart(bool value) async {
    state = state.copyWith(autoPlayOnStart: value);
    await _storage.setAutoPlayOnStart(value);
  }

  Future<void> setRememberPosition(bool value) async {
    state = state.copyWith(rememberPosition: value);
    await _storage.setRememberPosition(value);
  }
}

// Provider untuk storage service
final storageProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

// Provider untuk settings
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final storage = ref.watch(storageProvider);
  return SettingsNotifier(storage);
});

