/// Constantes liées aux prières islamiques.
class PrayerConstants {
  PrayerConstants._();

  /// Noms des 5 prières (ordre chronologique).
  static const List<String> prayerNames = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  /// Clés API Aladhan correspondantes.
  static const Map<String, String> aladhanKeys = {
    'Fajr': 'Fajr',
    'Dhuhr': 'Dhuhr',
    'Asr': 'Asr',
    'Maghrib': 'Maghrib',
    'Isha': 'Isha',
  };

  /// Prières avec adhkar du matin (après Fajr).
  static const List<String> morningAdhkarPrayers = ['Fajr'];

  /// Prières avec adhkar du soir (après Asr).
  static const List<String> eveningAdhkarPrayers = ['Asr'];

  /// Nombre de rakat par prière (fard).
  static const Map<String, int> rakatCount = {
    'Fajr': 2,
    'Dhuhr': 4,
    'Asr': 4,
    'Maghrib': 3,
    'Isha': 4,
  };

  /// Nombre de prières à rattraper par jour manqué.
  static const int prayersPerDay = 5;

  /// Coordonnées de La Mecque (Kaaba) pour le calcul Qibla.
  static const double kaabatLat = 21.4225;
  static const double kaabatLng = 39.8262;
}
