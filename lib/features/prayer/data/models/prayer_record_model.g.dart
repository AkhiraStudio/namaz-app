// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerRecordModelAdapter extends TypeAdapter<PrayerRecordModel> {
  @override
  final int typeId = 2;

  @override
  PrayerRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerRecordModel(
      id: fields[0] as String,
      dateMs: fields[1] as int,
      prayerNameIndex: fields[2] as int,
      statusIndex: fields[3] as int,
      recordedAtMs: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerRecordModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dateMs)
      ..writeByte(2)
      ..write(obj.prayerNameIndex)
      ..writeByte(3)
      ..write(obj.statusIndex)
      ..writeByte(4)
      ..write(obj.recordedAtMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
