import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Phases du cycle solaire qui influencent le thème visuel.
enum SolarPhase {
  fajr,       // Aube
  morning,    // Matin
  dhuhr,      // Midi
  afternoon,  // Après-midi
  maghrib,    // Crépuscule
  isha,       // Début de nuit
  night,      // Nuit profonde
}

/// Données visuelles associées à chaque phase solaire.
class SolarThemeData {
  final Color backgroundColor;
  final Color accentColor;
  final Color textColor;
  final String phaseName;

  const SolarThemeData({
    required this.backgroundColor,
    required this.accentColor,
    required this.textColor,
    required this.phaseName,
  });
}

/// Mappe chaque [SolarPhase] à ses données visuelles.
const Map<SolarPhase, SolarThemeData> solarThemeMap = {
  SolarPhase.fajr: SolarThemeData(
    backgroundColor: AppColors.solarFajr,
    accentColor: AppColors.gold,
    textColor: AppColors.textPrimary,
    phaseName: 'Fajr',
  ),
  SolarPhase.morning: SolarThemeData(
    backgroundColor: AppColors.solarMorning,
    accentColor: AppColors.deepPurple,
    textColor: AppColors.textPrimary,
    phaseName: 'Matin',
  ),
  SolarPhase.dhuhr: SolarThemeData(
    backgroundColor: AppColors.solarDhuhr,
    accentColor: AppColors.deepPurple,
    textColor: AppColors.textPrimary,
    phaseName: 'Dhuhr',
  ),
  SolarPhase.afternoon: SolarThemeData(
    backgroundColor: AppColors.solarAfternoon,
    accentColor: AppColors.deepPurple,
    textColor: AppColors.textPrimary,
    phaseName: 'Après-midi',
  ),
  SolarPhase.maghrib: SolarThemeData(
    backgroundColor: AppColors.solarMaghrib,
    accentColor: AppColors.gold,
    textColor: AppColors.deepPurple,
    phaseName: 'Maghrib',
  ),
  SolarPhase.isha: SolarThemeData(
    backgroundColor: AppColors.solarIsha,
    accentColor: AppColors.goldLight,
    textColor: AppColors.textOnDark,
    phaseName: 'Isha',
  ),
  SolarPhase.night: SolarThemeData(
    backgroundColor: AppColors.solarNight,
    accentColor: AppColors.mediumPurple,
    textColor: AppColors.textOnDark,
    phaseName: 'Nuit',
  ),
};

/// Détermine la [SolarPhase] en fonction des horaires de prière du jour.
SolarPhase computeSolarPhase({
  required DateTime now,
  required DateTime fajr,
  required DateTime dhuhr,
  required DateTime asr,
  required DateTime maghrib,
  required DateTime isha,
}) {
  final sunrise = fajr.add(const Duration(hours: 1, minutes: 30));
  final midMorning = dhuhr.subtract(const Duration(hours: 2));
  final midAfternoon = asr.add(const Duration(hours: 1));

  if (now.isBefore(fajr) || now.isAfter(isha.add(const Duration(hours: 3)))) {
    return SolarPhase.night;
  } else if (now.isBefore(sunrise)) {
    return SolarPhase.fajr;
  } else if (now.isBefore(midMorning)) {
    return SolarPhase.morning;
  } else if (now.isBefore(asr)) {
    return SolarPhase.dhuhr;
  } else if (now.isBefore(midAfternoon)) {
    return SolarPhase.afternoon;
  } else if (now.isBefore(isha)) {
    return SolarPhase.maghrib;
  } else {
    return SolarPhase.isha;
  }
}
