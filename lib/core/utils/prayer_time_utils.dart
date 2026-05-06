import '../constants/app_constants.dart';

/// Statut d'une prière par rapport à sa fenêtre horaire.
enum PrayerWindowStatus {
  early,   // Dans les 30 min après l'adhan — Vert
  onTime,  // Entre 30 min après et 30 min avant la fin — Orange
  late,    // Dans les 30 min avant la fin — Rouge
  missed,  // Heure dépassée — Noir
}

/// Utilitaires pour les calculs liés aux horaires de prière.
class PrayerTimeUtils {
  PrayerTimeUtils._();

  /// Détermine le [PrayerWindowStatus] d'une prière à [now].
  /// [prayerStart] : heure de l'adhan.
  /// [nextPrayerStart] : heure de l'adhan suivant (définit la fin de la fenêtre).
  static PrayerWindowStatus getWindowStatus({
    required DateTime now,
    required DateTime prayerStart,
    required DateTime nextPrayerStart,
  }) {
    final earlyEnd = prayerStart.add(
      const Duration(minutes: AppConstants.earlyWindowMinutes),
    );
    final lateStart = nextPrayerStart.subtract(
      const Duration(minutes: AppConstants.lateWindowMinutes),
    );

    if (now.isBefore(prayerStart)) return PrayerWindowStatus.missed;
    if (now.isAfter(nextPrayerStart)) return PrayerWindowStatus.missed;
    if (now.isBefore(earlyEnd)) return PrayerWindowStatus.early;
    if (now.isAfter(lateStart)) return PrayerWindowStatus.late;
    return PrayerWindowStatus.onTime;
  }

  /// Calcule l'heure du tiers de nuit.
  /// Le tiers de nuit commence après les 2 premiers tiers de la nuit
  /// (entre Isha et Fajr du lendemain).
  static DateTime calculateLastThirdOfNight({
    required DateTime isha,
    required DateTime fajrNextDay,
  }) {
    final nightDuration = fajrNextDay.difference(isha);
    final thirdDuration = nightDuration ~/ 3;
    return isha.add(thirdDuration * 2);
  }

  /// Retourne la progression (0.0 à 1.0) dans la fenêtre de la prière courante.
  static double getPrayerProgress({
    required DateTime now,
    required DateTime prayerStart,
    required DateTime nextPrayerStart,
  }) {
    if (now.isBefore(prayerStart)) return 0.0;
    if (now.isAfter(nextPrayerStart)) return 1.0;
    final total = nextPrayerStart.difference(prayerStart).inSeconds;
    final elapsed = now.difference(prayerStart).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}
