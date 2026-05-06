// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_time_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerTimeModelAdapter extends TypeAdapter<PrayerTimeModel> {
  @override
  final int typeId = 1;

  @override
  PrayerTimeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerTimeModel(
      dateKey: fields[0] as String,
      fajrMs: fields[1] as int,
      sunriseMs: fields[2] as int,
      dhuhrMs: fields[3] as int,
      asrMs: fields[4] as int,
      maghribMs: fields[5] as int,
      ishaMs: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerTimeModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.dateKey)
      ..writeByte(1)
      ..write(obj.fajrMs)
      ..writeByte(2)
      ..write(obj.sunriseMs)
      ..writeByte(3)
      ..write(obj.dhuhrMs)
      ..writeByte(4)
      ..write(obj.asrMs)
      ..writeByte(5)
      ..write(obj.maghribMs)
      ..writeByte(6)
      ..write(obj.ishaMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTimeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
