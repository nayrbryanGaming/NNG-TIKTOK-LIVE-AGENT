import 'package:hive/hive.dart';

part 'track.g.dart'; // Note: we will provide a manual adapter below; keep part for compatibility

@HiveType(typeId: 0)
class Track extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? artist;

  @HiveField(3)
  int? durationMs;

  @HiveField(4)
  SourceType sourceType;

  @HiveField(5)
  String source; // asset path or file path / uri

  @HiveField(6)
  bool isEnabled;

  @HiveField(7)
  bool isDefault;

  @HiveField(8)
  int orderIndex;

  @HiveField(9)
  DateTime addedAt;

  Track({
    required this.id,
    required this.title,
    this.artist,
    this.durationMs,
    required this.sourceType,
    required this.source,
    this.isEnabled = true,
    this.isDefault = false,
    required this.orderIndex,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
}

enum SourceType { asset, file }

// Manual Hive TypeAdapter for Track (to avoid build_runner in this example)
class TrackAdapter extends TypeAdapter<Track> {
  @override
  final int typeId = 0;

  @override
  Track read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return Track(
      id: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String?,
      durationMs: fields[3] as int?,
      sourceType: SourceType.values[fields[4] as int],
      source: fields[5] as String,
      isEnabled: fields[6] as bool,
      isDefault: fields[7] as bool,
      orderIndex: fields[8] as int,
      addedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.durationMs)
      ..writeByte(4)
      ..write(obj.sourceType.index)
      ..writeByte(5)
      ..write(obj.source)
      ..writeByte(6)
      ..write(obj.isEnabled)
      ..writeByte(7)
      ..write(obj.isDefault)
      ..writeByte(8)
      ..write(obj.orderIndex)
      ..writeByte(9)
      ..write(obj.addedAt);
  }
}


