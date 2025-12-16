import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_file_helper.dart';

class FileImportService {
  /// Request storage permission if needed (Android/iOS)
  static Future<bool> requestPermission() async {
    if (kIsWeb) {
      // Web doesn't need permissions
      return true;
    }

    if (io.Platform.isAndroid) {
      // For Android 13+ (API 33+), use READ_MEDIA_AUDIO
      // For Android 10-12, use READ_EXTERNAL_STORAGE
      final status = await Permission.audio.request();

      if (status.isDenied || status.isPermanentlyDenied) {
        // Fallback to storage permission for older Android
        final storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      }

      return status.isGranted;
    }

    if (io.Platform.isIOS) {
      // iOS doesn't need explicit permission for file picker
      return true;
    }

    // Desktop (Windows/macOS/Linux) and Web don't need permissions
    return true;
  }

  /// Pick audio files from device storage (cross-platform)
  static Future<List<FileImportResult>?> pickAudioFiles() async {
    try {
      print('🔍 File picker: Starting...');
      print('📱 Platform: ${kIsWeb ? 'WEB' : (io.Platform.isAndroid ? 'ANDROID' : 'OTHER')}');

      // Request permission first (not needed on desktop/web, but safe to call)
      if (!kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS)) {
        print('🔐 Requesting permission...');
        final hasPermission = await requestPermission();
        print('🔐 Permission: ${hasPermission ? 'GRANTED' : 'DENIED'}');
        if (!hasPermission) {
          print('❌ Permission denied, aborting file picker');
          return null;
        }
      }

      // Open file picker with audio filter
      // Works on: Android, iOS, Windows, macOS, Linux, Web
      print('📂 Opening file picker dialog...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
        allowCompression: false,
      );

      print('✅ File picker dialog closed');
      print('📄 Result: ${result == null ? 'NULL' : '${result.files.length} files'}'  );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      // Convert to our result format
      final imports = <FileImportResult>[];
      for (final file in result.files) {
        String? filePath;
        Uint8List? fileBytes;

        if (kIsWeb) {
          // On web, use the file name as path identifier
          if (file.bytes != null) {
            fileBytes = file.bytes!;
            filePath = file.name; // Use filename as identifier

            // Store bytes in cache for web playback
            WebFileHelper.storeFileBytes(file.name, fileBytes);
            print('✅ Web: Stored ${file.name} (${fileBytes.length} bytes)');
          }
        } else {
          // On native platforms, use the actual file path
          filePath = file.path;
        }

        if (filePath != null) {
          final fileName = file.name;
          final title = _extractTitle(fileName);

          imports.add(FileImportResult(
            filePath: filePath,
            fileName: fileName,
            suggestedTitle: title,
            bytes: fileBytes,
          ));
        }
      }

      if (imports.isEmpty) {
        print('⚠️ No valid files selected');
        return null;
      }

      print('✅ Selected ${imports.length} file(s)');
      return imports;
    } catch (e) {
      print('Error picking files: $e');
      return null;
    }
  }

  /// Extract a clean title from filename
  static String _extractTitle(String fileName) {
    // Remove extension
    var title = fileName;
    final lastDot = title.lastIndexOf('.');
    if (lastDot > 0) {
      title = title.substring(0, lastDot);
    }

    // Replace underscores and dashes with spaces
    title = title.replaceAll('_', ' ').replaceAll('-', ' ');

    // Capitalize first letter of each word
    final words = title.split(' ');
    title = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return title;
  }
}

class FileImportResult {
  final String filePath;
  final String fileName;
  final String suggestedTitle;
  final List<int>? bytes; // For web platform

  FileImportResult({
    required this.filePath,
    required this.fileName,
    required this.suggestedTitle,
    this.bytes,
  });
}

