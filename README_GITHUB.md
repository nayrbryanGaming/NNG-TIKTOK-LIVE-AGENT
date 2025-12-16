# 🎵 NNG TikTok Live Agent

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue)
![Dart](https://img.shields.io/badge/Dart-3.0%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)

A powerful Flutter music player application designed for TikTok Live streaming with continuous audio loop support, multi-platform compatibility, and a beautiful modern UI.

## ✨ Features

### 🎧 Audio Playback
- **Seamless Loop** - Continuous audio playback without gaps
- **Multi-Track Support** - Load and manage multiple audio files
- **Shuffle Mode** - Random playback order
- **Track Reordering** - Drag and drop to rearrange playlist

### 📱 Cross-Platform
- ✅ Android (Primary)
- ✅ iOS
- ✅ Windows
- ✅ macOS
- ✅ Linux
- ✅ Web

### 🎨 User Interface
- **Modern Material Design** - Clean and intuitive UI
- **Purple Theme** - Eye-catching gradient design
- **NNG Branding** - Custom logo and icons
- **Responsive Layout** - Works on all screen sizes

### 🔧 Technical Features
- **Audio Service** - Background playback support
- **Storage Persistence** - Saves your playlist
- **Permission Handling** - Auto-requests storage access
- **File Picker** - Import audio files easily
- **Notification Controls** - Control playback from notification shade

## 📸 Screenshots

### Main Screen
```
┌─────────────────────────────────┐
│  🎨 NNG AGENT   🔀 ⚙️          │
│  by nayrbryanGaming              │
├─────────────────────────────────┤
│                                  │
│  ♪  Now Playing                 │
│     Track Name                   │
│     Artist Name                  │
│     ───────●─────────            │
│     00:00          03:45         │
│                                  │
├─────────────────────────────────┤
│  📋 Track List (6 tracks)       │
│                                  │
│  ≡  Track 1           ⋮         │
│  ≡  Track 2           ⋮         │
│  ≡  Track 3           ⋮         │
│                                  │
│           ⊕ Add Track            │
└─────────────────────────────────┘
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code
- Android Device/Emulator or iOS Simulator

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/nayrbryanGaming/NNG-TIKTOK-LIVE-AGENT.git
cd NNG-TIKTOK-LIVE-AGENT
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate launcher icons**
```bash
flutter pub run flutter_launcher_icons
```

4. **Run the app**
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome
```

## 📦 Project Structure

```
nng_tiktok_live_agent/
├── lib/
│   ├── main.dart                      # App entry point
│   ├── models/
│   │   ├── track.dart                 # Track model
│   │   └── track.g.dart               # Generated Hive adapter
│   ├── services/
│   │   ├── audio_handler_service.dart # Audio service
│   │   ├── audio_loop_service.dart    # Loop logic
│   │   ├── file_import_service.dart   # File picker
│   │   ├── storage_service.dart       # Persistence
│   │   └── simple_audio_service.dart  # Simple player
│   ├── providers/
│   │   ├── track_list_notifier.dart   # Playlist state
│   │   ├── settings_notifier.dart     # Settings state
│   │   └── initialization_provider.dart
│   └── ui/
│       └── screens/
│           ├── main_screen.dart       # Main UI
│           └── settings_screen.dart   # Settings UI
├── assets/
│   ├── images/
│   │   ├── NNG.png                    # App logo
│   │   └── LOGO.png                   # Alternative logo
│   └── audio/
│       ├── sample1.mp3                # Sample tracks
│       ├── sample2.mp3
│       └── sample3.mp3
├── android/                           # Android-specific files
├── ios/                               # iOS-specific files
├── web/                               # Web-specific files
├── linux/                             # Linux-specific files
├── macos/                             # macOS-specific files
├── windows/                           # Windows-specific files
└── pubspec.yaml                       # Dependencies
```

## 🔧 Configuration

### pubspec.yaml
```yaml
dependencies:
  just_audio: ^0.9.46
  audio_session: ^0.1.25
  audio_service: ^0.18.12
  flutter_riverpod: ^2.6.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  file_picker: ^8.3.7
  permission_handler: ^11.4.0
  path_provider: ^2.1.1
  uuid: ^4.0.0
```

### Android Permissions (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

## 🎨 Customization

### Change App Name
Edit `pubspec.yaml`:
```yaml
name: your_app_name
```

### Change Logo
Replace files in:
- `assets/images/NNG.png` - Main logo
- Run `flutter pub run flutter_launcher_icons` to regenerate icons

### Change Theme
Edit `lib/main.dart`:
```dart
primarySwatch: Colors.purple,
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.purple,
),
```

## 🐛 Troubleshooting

### Issue: File picker not working
**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Permission denied
**Solution:**
- Check AndroidManifest.xml permissions
- Request permissions at runtime
- Enable storage access in device settings

### Issue: Audio not looping
**Solution:**
- Verify `AudioLoopService` is properly initialized
- Check `loopEnabled` setting
- Ensure audio files are valid MP3 format

### Issue: Logo not showing
**Solution:**
```bash
flutter pub run flutter_launcher_icons
flutter clean
flutter run
```

## 📱 Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**nayrbryanGaming**
- GitHub: [@nayrbryanGaming](https://github.com/nayrbryanGaming)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Just Audio package for audio playback
- Audio Service for background playback
- All contributors and users

## 📞 Support

For support, please open an issue on GitHub or contact the author.

---

⭐ **If you like this project, please give it a star!** ⭐

Made with ❤️ by nayrbryanGaming for TikTok Live streaming

