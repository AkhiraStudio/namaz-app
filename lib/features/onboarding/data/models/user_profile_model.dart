import 'package:hive/hive.dart';
import '../../domain/entities/user_profile.dart';
import '../../../../core/constants/hive_keys.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: HiveTypeIds.userProfileModel)
class UserProfileModel extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String name;
  @HiveField(2) late int genderIndex; // 0 = male, 1 = female
  @HiveField(3) late String languageCode;
  @HiveField(4) String? mosqueName;
  @HiveField(5) double? mosqueLatitude;
  @HiveField(6) double? mosqueLongitude;
  @HiveField(7) late bool travelerMode;
  @HiveField(8) int? mensCycleDays;
  @HiveField(9) int? mensDurationDays;
  @HiveField(10) late bool onboardingComplete;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.genderIndex,
    required this.languageCode,
    this.mosqueName,
    this.mosqueLatitude,
    this.mosqueLongitude,
    this.travelerMode = false,
    this.mensCycleDays,
    this.mensDurationDays,
    this.onboardingComplete = false,
  });

  factory UserProfileModel.fromEntity(UserProfile entity) => UserProfileModel(
        id: entity.id,
        name: entity.name,
        genderIndex: entity.gender.index,
        languageCode: entity.languageCode,
        mosqueName: entity.mosqueName,
        mosqueLatitude: entity.mosqueLatitude,
        mosqueLongitude: entity.mosqueLongitude,
        travelerMode: entity.travelerMode,
        mensCycleDays: entity.mensCycleDays,
        mensDurationDays: entity.mensDurationDays,
        onboardingComplete: entity.onboardingComplete,
      );

  static T _safeEnum<T>(List<T> values, int index, T fallback) =>
      (index >= 0 && index < values.length) ? values[index] : fallback;

  UserProfile toEntity() => UserProfile(
        id: id,
        name: name,
        gender: _safeEnum(UserGender.values, genderIndex, UserGender.male),
        languageCode: languageCode,
        mosqueName: mosqueName,
        mosqueLatitude: mosqueLatitude,
        mosqueLongitude: mosqueLongitude,
        travelerMode: travelerMode,
        mensCycleDays: mensCycleDays,
        mensDurationDays: mensDurationDays,
        onboardingComplete: onboardingComplete,
      );
}
