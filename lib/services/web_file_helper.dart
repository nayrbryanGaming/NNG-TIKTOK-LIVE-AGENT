import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Helper class to handle file storage for web platform
class WebFileHelper {
  static final Map<String, Uint8List> _fileCache = {};

  /// Store file bytes in memory for web platform
  static void storeFileBytes(String fileName, Uint8List bytes) {
    if (kIsWeb) {
      _fileCache[fileName] = bytes;
    }
  }

  /// Get stored file bytes for web platform
  static Uint8List? getFileBytes(String fileName) {
    if (kIsWeb) {
      return _fileCache[fileName];
    }
    return null;
  }

  /// Clear cached file bytes
  static void clearCache() {
    _fileCache.clear();
  }

  /// Check if file exists in cache
  static bool hasFile(String fileName) {
    return _fileCache.containsKey(fileName);
  }
}

