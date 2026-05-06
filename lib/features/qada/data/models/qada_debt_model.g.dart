// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qada_debt_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QadaDebtModelAdapter extends TypeAdapter<QadaDebtModel> {
  @override
  final int typeId = 3;

  @override
  QadaDebtModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QadaDebtModel(
      stopDateMs: fields[0] as int,
      resumeDateMs: fields[1] as int,
      mensDaysDeducted: fields[2] as int,
      totalDaysOwed: fields[3] as int,
      targetDateMs: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, QadaDebtModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.stopDateMs)
      ..writeByte(1)
      ..write(obj.resumeDateMs)
      ..writeByte(2)
      ..write(obj.mensDaysDeducted)
      ..writeByte(3)
      ..write(obj.totalDaysOwed)
      ..writeByte(4)
      ..write(obj.targetDateMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QadaDebtModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
