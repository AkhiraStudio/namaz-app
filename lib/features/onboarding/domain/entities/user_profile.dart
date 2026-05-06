import 'package:equatable/equatable.dart';

/// Genre de l'utilisateur, influe sur la gestion des menstrues (Qada).
enum UserGender { male, female }

/// Entité domaine représentant le profil utilisateur.
class UserProfile extends Equatable {
  final String id;
  final String name;
  final UserGender gender;
  final String languageCode;
  final String? mosqueName;
  final double? mosqueLatitude;
  final double? mosqueLongitude;
  final bool travelerMode;

  // Données cycle (femme uniquement)
  final int? mensCycleDays;      // Durée moyenne du cycle en jours
  final int? mensDurationDays;   // Durée moyenne des règles en jours

  final bool onboardingComplete;

  const UserProfile({
    required this.id,
    required this.name,
    required this.gender,
    required this.languageCode,
    this.mosqueName,
    this.mosqueLatitude,
    this.mosqueLongitude,
    this.travelerMode = false,
    this.mensCycleDays,
    this.mensDurationDays,
    this.onboardingComplete = false,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    UserGender? gender,
    String? languageCode,
    String? mosqueName,
    double? mosqueLatitude,
    double? mosqueLongitude,
    bool? travelerMode,
    int? mensCycleDays,
    int? mensDurationDays,
    bool? onboardingComplete,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      languageCode: languageCode ?? this.languageCode,
      mosqueName: mosqueName ?? this.mosqueName,
      mosqueLatitude: mosqueLatitude ?? this.mosqueLatitude,
      mosqueLongitude: mosqueLongitude ?? this.mosqueLongitude,
      travelerMode: travelerMode ?? this.travelerMode,
      mensCycleDays: mensCycleDays ?? this.mensCycleDays,
      mensDurationDays: mensDurationDays ?? this.mensDurationDays,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  @override
  List<Object?> get props => [
        id, name, gender, languageCode, mosqueName,
        mosqueLatitude, mosqueLongitude, travelerMode,
        mensCycleDays, mensDurationDays, onboardingComplete,
      ];
}
