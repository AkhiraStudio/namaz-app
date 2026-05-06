// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 5;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      languageCode: fields[0] as String,
      timeFormatIndex: fields[1] as int,
      travelerMode: fields[2] as bool,
      darkMode: fields[3] as bool,
      mensCycleDays: fields[4] as int,
      mensDurationDays: fields[5] as int,
      prayerNotifEnabled: fields[6] as bool?,
      qadaNotifEnabled: fields[7] as bool?,
      prayerAlertTypeIndex: fields[8] as int?,
      showSunnahPrayers: fields[9] as bool?,
      qadaMorningHour: fields[10] as int?,
      qadaEveningHour: fields[11] as int?,
      showStreak: fields[12] as bool?,
      calculationMethodIndex: fields[13] as int?,
      globalOffsetMinutes: fields[14] as int?,
      fajrOffsetMinutes: fields[15] as int?,
      dhuhrOffsetMinutes: fields[16] as int?,
      asrOffsetMinutes: fields[17] as int?,
      maghribOffsetMinutes: fields[18] as int?,
      ishaOffsetMinutes: fields[19] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.languageCode)
      ..writeByte(1)
      ..write(obj.timeFormatIndex)
      ..writeByte(2)
      ..write(obj.travelerMode)
      ..writeByte(3)
      ..write(obj.darkMode)
      ..writeByte(4)
      ..write(obj.mensCycleDays)
      ..writeByte(5)
      ..write(obj.mensDurationDays)
      ..writeByte(6)
      ..write(obj.prayerNotifEnabled)
      ..writeByte(7)
      ..write(obj.qadaNotifEnabled)
      ..writeByte(8)
      ..write(obj.prayerAlertTypeIndex)
      ..writeByte(9)
      ..write(obj.showSunnahPrayers)
      ..writeByte(10)
      ..write(obj.qadaMorningHour)
      ..writeByte(11)
      ..write(obj.qadaEveningHour)
      ..writeByte(12)
      ..write(obj.showStreak)
      ..writeByte(13)
      ..write(obj.calculationMethodIndex)
      ..writeByte(14)
      ..write(obj.globalOffsetMinutes)
      ..writeByte(15)
      ..write(obj.fajrOffsetMinutes)
      ..writeByte(16)
      ..write(obj.dhuhrOffsetMinutes)
      ..writeByte(17)
      ..write(obj.asrOffsetMinutes)
      ..writeByte(18)
      ..write(obj.maghribOffsetMinutes)
      ..writeByte(19)
      ..write(obj.ishaOffsetMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
