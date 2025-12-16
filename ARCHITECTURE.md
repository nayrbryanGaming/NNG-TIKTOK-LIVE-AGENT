# LoopCaster - Architecture & Data Flow Diagrams

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter UI Layer                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ main_screen.dart                                     │   │
│  │ ├── NowPlayingCard (tracks playerState stream)      │   │
│  │ ├── TrackList (ReorderableListView)                 │   │
│  │ │   └── TrackTile (toggle, delete, drag handle)     │   │
│  │ └── FAB (add track button)                          │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ settings_screen.dart                                 │   │
│  │ ├── Dark mode toggle                                │   │
│  │ ├── Auto-play toggle                                │   │
│  │ └── Reset playlist button                           │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              State Management Layer (Riverpod)              │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ trackListProvider (StateNotifierProvider)            │   │
│  │ ├─ addTrack()                                        │   │
│  │ ├─ removeTrack()                                     │   │
│  │ ├─ toggleEnabled()                                   │   │
│  │ ├─ reorder()                                         │   │
│  │ └─ resetToDefaults()                                │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ audioServiceProvider (Provider)                      │   │
│  │ └─ Singleton AudioLoopService instance              │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ settingsProvider (StateNotifierProvider)             │   │
│  │ └─ Dark mode, auto-play, remember position         │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ initializationProvider (FutureProvider)              │   │
│  │ └─ Async app startup & data loading                 │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│            Services Layer (Business Logic)                  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ AudioLoopService                                     │   │
│  │ ├─ play() / pause() / stop()                        │   │
│  │ ├─ next() / previous() / seek()                     │   │
│  │ ├─ loadFromTracks()                                 │   │
│  │ ├─ Manages ConcatenatingAudioSource                │   │
│  │ ├─ Streams: playerState, position, duration, index │   │
│  │ └─ Uses: just_audio, audio_session                 │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ StorageService                                       │   │
│  │ ├─ init() - Initialize Hive                        │   │
│  │ ├─ getAllTracks() / addTrack()                      │   │
│  │ ├─ updateTrack() / removeTrack()                   │   │
│  │ ├─ Hive Box<Track> management                       │   │
│  │ └─ Hive Box<Settings> management                    │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ FileImportService                                    │   │
│  │ ├─ pickAudioFiles() - Open file picker              │   │
│  │ ├─ requestPermission() - Handle Android perms       │   │
│  │ └─ _extractTitle() - Clean filename                 │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│            Data Layer & External Libraries                 │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Hive Database                                        │   │
│  │ ├─ Box<Track> "tracks_box"                         │   │
│  │ ├─ Box "settings_box"                              │   │
│  │ └─ Local device storage (offline)                  │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ just_audio                                           │   │
│  │ ├─ AudioPlayer                                       │   │
│  │ ├─ ConcatenatingAudioSource (gapless)              │   │
│  │ ├─ LoopMode.all (endless looping)                  │   │
│  │ └─ Streams for playback state                       │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ External Services                                    │   │
│  │ ├─ file_picker (file selection)                     │   │
│  │ ├─ permission_handler (Android perms)               │   │
│  │ └─ audio_session (audio focus)                      │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Device Resources                                     │   │
│  │ ├─ Device storage (audio files)                     │   │
│  │ ├─ App assets (default tracks)                      │   │
│  │ └─ Android file system                              │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Data Flow: User Adds a Track

```
User Taps FAB
    ↓
[main_screen.dart] _addTracks()
    ↓
[FileImportService] pickAudioFiles()
    ├─ requestPermission() → Android READ_MEDIA_AUDIO
    ├─ FilePicker.platform.pickFiles() → User selects files
    └─ returns: List<FileImportResult>
    ↓
For each selected file:
    ├─ Extract title from filename
    └─ Create FileImportResult (path, filename, suggested title)
    ↓
ref.read(trackListProvider.notifier).addUserTrack(
    filePath: "file://path/to/song.mp3",
    title: "Song Name"
)
    ↓
[TrackListNotifier] addUserTrack()
    ├─ Create Track object:
    │   {
    │     id: UUID,
    │     title: "Song Name",
    │     sourceType: SourceType.file,
    │     source: "file://path/to/song.mp3",
    │     isEnabled: true,
    │     isDefault: false,
    │     orderIndex: maxOrder + 1
    │   }
    ├─ StorageService.addTrack() → Save to Hive
    ├─ state = [...state, track] → Update Riverpod state
    └─ audioService.loadFromTracks(state) → Rebuild playlist
    ↓
[AudioLoopService] loadFromTracks()
    ├─ Filter to enabled tracks only
    ├─ For each track:
    │   ├─ If sourceType == asset: AudioSource.uri('asset://...')
    │   └─ If sourceType == file: AudioSource.uri('file://...')
    ├─ Create ConcatenatingAudioSource(children: sources)
    ├─ player.setAudioSource(playlist)
    ├─ player.setLoopMode(LoopMode.all)
    └─ if wasPlaying: player.play()
    ↓
UI Updates:
    ├─ TrackTile appears in list for new track
    ├─ NowPlayingCard updates if now-playing changes
    └─ User sees "Added X track(s)" snackbar
    ↓
User can now:
    ├─ Enable/disable toggle for new track
    ├─ Reorder it in the playlist
    └─ It loops with all other enabled tracks
```

---

## Data Flow: User Presses Play

```
User Presses Play Button
    ↓
[NowPlayingCard] onClick on Play button
    ↓
audioService.play()
    ↓
[AudioLoopService] play()
    ├─ Call _player.play()
    └─ AudioPlayer emits PlayerState.playing
    ↓
Streams Update:
    ├─ playerStateStream → emits PlayerState.playing
    ├─ currentIndexStream → emits first track index
    ├─ positionStream → emits current position
    └─ durationStream → emits current track duration
    ↓
UI Reacts:
    ├─ Play button icon changes to Pause icon
    ├─ NowPlayingCard title updates to current track
    ├─ Progress bar animates as position stream emits
    ├─ TrackTile highlights for current playing track
    └─ Current position shows "00:00" → "MM:SS" as plays
    ↓
Playback Behavior (just_audio automatically handles):
    ├─ Play first enabled track
    └─ When track finishes:
        ├─ ConcatenatingAudioSource auto-plays next
        └─ Gapless transition (no silence)
    ├─ After last track finishes:
        └─ LoopMode.all loops back to first
    ├─ Continue looping forever...
    ↓
Loop Continues Until:
    ├─ User presses Pause (pauses current track)
    ├─ User presses Stop (stops and resets to track 1)
    └─ User disables current track mid-playback
        └─ AudioLoopService moves to next enabled track
```

---

## Data Flow: User Disables a Track During Playback

```
User Taps Toggle Switch for Currently Playing Track
    ↓
[TrackTile] onChanged toggle
    ↓
ref.read(trackListProvider.notifier).toggleEnabled(trackId)
    ↓
[TrackListNotifier] toggleEnabled()
    ├─ Find track by id
    ├─ track.isEnabled = !track.isEnabled
    ├─ StorageService.updateTrack(track) → Persist to Hive
    ├─ state = [...state] → Trigger Riverpod update
    └─ audioService.loadFromTracks(state)
    ↓
[AudioLoopService] loadFromTracks()
    ├─ Get only enabled tracks
    ├─ Rebuild ConcatenatingAudioSource with new list
    ├─ Remove the disabled track's AudioSource
    ├─ If disabled track was playing:
    │   ├─ Capture current playback state
    │   ├─ Try to resume at same position
    │   └─ Move currentIndex to next enabled track
    └─ Continue playback (if was playing)
    ↓
UI Updates:
    ├─ TrackTile toggle is OFF
    ├─ If was playing: 
    │   ├─ Now-playing updates to next track
    │   └─ Playback continues seamlessly
    ├─ Track list updates (disabled track may be grayed out)
    └─ "Loop All" indicator still shows
```

---

## Data Flow: Reorder Tracks

```
User Drags Track Tile to New Position
    ↓
[ReorderableListView] onReorder(oldIndex, newIndex)
    ↓
ref.read(trackListProvider.notifier).reorder(oldIndex, newIndex)
    ↓
[TrackListNotifier] reorder()
    ├─ Move track in state list
    ├─ Recalculate orderIndex for all affected tracks
    ├─ For each track:
    │   └─ StorageService.updateTrack() → Persist new order
    ├─ state = newOrderedList
    └─ audioService.loadFromTracks(state)
    ↓
[AudioLoopService] loadFromTracks()
    ├─ Rebuild ConcatenatingAudioSource in new order
    ├─ If currently playing:
    │   ├─ Preserve same track as current (don't skip)
    │   └─ Playlist continues from that track
    └─ new order takes effect for next transitions
    ↓
UI Updates:
    ├─ TrackTile animates to new position
    ├─ List re-renders in new order
    ├─ If playing: continues same track (no interruption)
    └─ New order persists in Hive
    ↓
Result:
    └─ Next track after current will now be the new next track
```

---

## State Management Flow

```
                    Application State Tree (Riverpod)
                                  │
                 ┌────────────────┼────────────────┐
                 ↓                ↓                ↓
          trackListProvider  audioServiceProvider settingsProvider
                 │                ↓                ↓
                 │           AudioLoopService   AppSettings
                 │           ├─ play/pause       ├─ darkMode
        StateNotifier         ├─ ConcatenatingSource
        <List<Track>>         └─ streams          ├─ autoPlayOnStart
                 │                                └─ rememberPosition
        TrackListNotifier
        ├─ state = List<Track>
        ├─ listeners on UI
        └─ methods:
          ├─ addTrack()
          ├─ removeTrack()
          ├─ toggleEnabled()
          └─ reorder()
```

---

## Database Schema (Hive)

```
┌─── Hive Database ────────────────────────────────────┐
│                                                      │
│  Box<Track> "tracks_box"                           │
│  ├─ Key: track.id (UUID)                           │
│  └─ Value: Track object                            │
│     {                                               │
│       id: "550e8400-e29b-41d4-a716-446655440000"   │
│       title: "My Song"                             │
│       artist: "Artist Name" (nullable)             │
│       durationMs: 180000                           │
│       sourceType: 1 (enum index for .file)         │
│       source: "file:///path/to/song.mp3"           │
│       isEnabled: true                              │
│       isDefault: false                             │
│       orderIndex: 3                                │
│       addedAt: DateTime.now()                      │
│     }                                               │
│                                                    │
│  Box "settings_box"                                │
│  ├─ "darkMode" → bool (false)                      │
│  ├─ "autoPlayOnStart" → bool (false)               │
│  ├─ "rememberPosition" → bool (true)               │
│  └─ ... (other settings as key-value)              │
│                                                    │
└────────────────────────────────────────────────────┘
```

---

## Gapless Looping Technical Details

```
                    just_audio Gapless Architecture
                                    │
                ┌───────────────────┼───────────────────┐
                ↓                   ↓                   ↓
        ConcatenatingAudioSource    AudioPlayer      LoopMode
        
        ┌─ Track 1 (0:00-0:30)
        ├─ Track 2 (0:00-0:30)     Seamless      LoopMode.all
        └─ Track 3 (0:00-0:25)     Transition    │
             ↓                      ↓             ↓
           Play order          No silence    Loop back
                               between       to Track 1
                               tracks
```

### How Gapless Works:
1. `ConcatenatingAudioSource` holds list of `AudioSource` items
2. When one track finishes, next is queued (no reload delay)
3. `LoopMode.all` automatically loops entire playlist
4. No seek/reload between tracks = zero silence gap
5. For assets: `AudioSource.uri('asset://...')` loads from bundle
6. For files: `AudioSource.uri('file://...')` reads from device storage

---

## Initialization Sequence

```
main()
  ↓
ProviderScope(child: LoopCasterApp)
  ↓
LoopCasterApp.build()
  ├─ Watches settingsProvider (theme)
  └─ Returns AppInitializer
  ↓
AppInitializer.build()
  ├─ Watches initializationProvider
  └─ Shows loading spinner while initializing
  ↓
initializationProvider (FutureProvider)
  ├─ StorageService.init()
  │  ├─ Hive.initFlutter()
  │  ├─ Hive.registerAdapter(TrackAdapter())
  │  ├─ Open Box<Track>("tracks_box")
  │  └─ Open Box("settings_box")
  │
  ├─ audioService.init()
  │  ├─ AudioSession.configure(music)
  │  ├─ setLoopMode(LoopMode.all)
  │  └─ setAudioSource(empty playlist)
  │
  ├─ Load default tracks if empty
  │  ├─ Create 3 Track objects (assets/audio/sample*.mp3)
  │  └─ StorageService.addTrack() for each
  │
  ├─ Load all tracks from storage
  │  └─ audioService.loadFromTracks(allTracks)
  │
  └─ Return void (done)
  ↓
AppInitializer.when(data: MainScreen)
  ↓
MainScreen renders
  ├─ Widgets watch trackListProvider
  ├─ Widgets stream from audioServiceProvider
  └─ UI is interactive and fully functional
```

---

## Error Handling Flow

```
User Action → Service Call → Error?
                              ├─ YES:
                              │  ├─ Catch exception
                              │  ├─ Log error
                              │  ├─ Show SnackBar to user
                              │  └─ Revert state if needed
                              │
                              └─ NO:
                                 ├─ Update state
                                 ├─ Notify listeners
                                 └─ UI updates
```

### Examples:
- **Missing File:** AudioLoopService skips file, shows warning icon
- **Permission Denied:** file_picker handles gracefully
- **Storage Error:** Hive transaction rolls back
- **Playback Error:** just_audio error stream caught, displayed

---

This architecture ensures:
✅ **Gapless playback** (core feature)
✅ **Offline operation** (no network)
✅ **Reactive UI** (Riverpod streams)
✅ **Data persistence** (Hive)
✅ **Clean separation** (services/providers/UI)
✅ **Error resilience** (handles edge cases)

