import 'dart:math' as math;

/// Calcul de la position du soleil pour le mode solaire dynamique.
class SolarPositionUtils {
  SolarPositionUtils._();

  /// Retourne l'élévation du soleil en degrés pour une position et heure données.
  /// Algorithme simplifié basé sur les équations astronomiques de base.
  static double getSolarElevation({
    required double latitude,
    required double longitude,
    required DateTime dateTime,
  }) {
    final utcTime = dateTime.toUtc();
    final dayOfYear = _getDayOfYear(utcTime);
    final hourDecimal = utcTime.hour + utcTime.minute / 60.0;

    // Déclinaison solaire
    final declination = 23.45 *
        math.sin(math.pi / 180 * (360 / 365 * (dayOfYear - 81)));

    // Angle horaire
    final solarNoon = 12.0 - (longitude / 15.0);
    final hourAngle = 15.0 * (hourDecimal - solarNoon);

    // Élévation solaire
    final latRad = latitude * math.pi / 180;
    final decRad = declination * math.pi / 180;
    final hourRad = hourAngle * math.pi / 180;

    final elevation = math.asin(
      math.sin(latRad) * math.sin(decRad) +
          math.cos(latRad) * math.cos(decRad) * math.cos(hourRad),
    );

    return elevation * 180 / math.pi;
  }

  static int _getDayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays + 1;
  }
}
