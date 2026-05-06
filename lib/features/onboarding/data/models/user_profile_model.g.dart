// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 0;

  @override
  UserProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileModel(
      id: fields[0] as String,
      name: fields[1] as String,
      genderIndex: fields[2] as int,
      languageCode: fields[3] as String,
      mosqueName: fields[4] as String?,
      mosqueLatitude: fields[5] as double?,
      mosqueLongitude: fields[6] as double?,
      travelerMode: fields[7] as bool,
      mensCycleDays: fields[8] as int?,
      mensDurationDays: fields[9] as int?,
      onboardingComplete: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.genderIndex)
      ..writeByte(3)
      ..write(obj.languageCode)
      ..writeByte(4)
      ..write(obj.mosqueName)
      ..writeByte(5)
      ..write(obj.mosqueLatitude)
      ..writeByte(6)
      ..write(obj.mosqueLongitude)
      ..writeByte(7)
      ..write(obj.travelerMode)
      ..writeByte(8)
      ..write(obj.mensCycleDays)
      ..writeByte(9)
      ..write(obj.mensDurationDays)
      ..writeByte(10)
      ..write(obj.onboardingComplete);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
