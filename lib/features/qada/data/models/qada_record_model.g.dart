// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qada_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QadaRecordModelAdapter extends TypeAdapter<QadaRecordModel> {
  @override
  final int typeId = 4;

  @override
  QadaRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QadaRecordModel(
      id: fields[0] as String,
      prayerNameIndex: fields[1] as int,
      performedAtMs: fields[2] as int,
      isFromRecentMissed: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, QadaRecordModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.prayerNameIndex)
      ..writeByte(2)
      ..write(obj.performedAtMs)
      ..writeByte(3)
      ..write(obj.isFromRecentMissed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QadaRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
