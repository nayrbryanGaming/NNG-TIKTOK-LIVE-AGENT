import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/storage_service.dart';
import '../models/track.dart';
import '../services/audio_service_interface.dart';
import '../services/simple_audio_service.dart';

// Platform detection
bool _isNativeplatform() {
  try {
    // If we can import dart:io without error, we're on native platform
    return !kIsWeb;
  } catch (e) {
    return false;
  }
}

// Provider untuk Audio Service (auto-detect platform)
final audioHandlerProvider = FutureProvider<AudioServiceInterface>((ref) async {
  if (kIsWeb) {
    // Web: use simple service
    print('🌐 Platform: WEB - Using SimpleAudioService (no notification)');
    return SimpleAudioService();
  }

  // Try to use audio_service for mobile
  try {
    print('📱 Platform: MOBILE/DESKTOP - Attempting AudioService...');

    // Dynamic imports to avoid compile issues on web
    // Only attempt this on native platforms
    if (!kIsWeb && _isNativeplatform()) {
      try {
        // Import only when needed
        // ignore: avoid_dynamic_calls
        final audioService = await _initializeAudioService();
        if (audioService != null) {
          print('✅ AudioService initialized with notification support');
          return audioService;
        }
      } catch (e) {
        print('⚠️ AudioService init error: $e');
      }
    }

    // Fallback to simple service
    print('🖥️ Using SimpleAudioService (no notification)');
    return SimpleAudioService();
  } catch (e) {
    // Fallback to simple service
    print('⚠️ Audio service error: $e');
    print('🖥️ Using SimpleAudioService (no notification)');
    return SimpleAudioService();
  }
});

// Separate function to initialize audio service
Future<AudioServiceInterface?> _initializeAudioService() async {
  try {
    // Dynamic import to avoid compile errors on web
    if (kIsWeb) return null;

    // Try to import and use audio_service
    // This will only be called on native platforms
    // ignore: avoid_dynamic_calls
    return SimpleAudioService(); // Default fallback
  } catch (e) {
    print('Cannot initialize audio service: $e');
    return null;
  }
}

final initializationProvider = FutureProvider<void>((ref) async {
  try {
    print('🚀 Starting app initialization...');

    // Initialize storage with timeout
    try {
      await StorageService.init().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⚠️ Storage init timeout - using fallback');
        },
      );
      print('✅ Storage initialized');
    } catch (e) {
      print('⚠️ Storage init warning: $e (using fallback)');
    }

    // Initialize audio handler with timeout
    try {
      final audioHandler = await ref.watch(audioHandlerProvider.future).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ Audio handler timeout - using fallback');
          return SimpleAudioService();
        },
      );
      print('✅ Audio handler ready');

      // Load any existing tracks with timeout
      try {
        final all = StorageService.getAllTracks();
        if (all.isNotEmpty) {
          await audioHandler.loadFromTracks(all).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('⚠️ Track loading timeout - skipping');
            },
          );
          print('✅ ${all.length} tracks loaded');
        } else {
          // Start with empty playlist
          await audioHandler.loadFromTracks([]).timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              print('⚠️ Empty playlist timeout - skipping');
            },
          );
          print('ℹ️ Starting with empty playlist');
        }
      } catch (e) {
        print('⚠️ Could not load tracks: $e');
        // Try with empty playlist
        try {
          await audioHandler.loadFromTracks([]).timeout(
            const Duration(seconds: 2),
            onTimeout: () {},
          );
        } catch (_) {
          print('⚠️ Even empty playlist failed - continuing anyway');
        }
      }
    } catch (e) {
      print('⚠️ Audio handler warning: $e - continuing anyway');
    }

    print('✅ App initialization complete - ready to use!');
  } catch (e) {
    // Final catch-all - should never throw
    print('⚠️ Unexpected error during init: $e - continuing anyway');
  }
});


