/// Constantes globales de l'application Namaz App.
class AppConstants {
  AppConstants._();

  // API Aladhan
  static const String aladhanBaseUrl = 'https://api.aladhan.com/v1';
  static const int apiTimeoutSeconds = 15;

  // Fenêtres de prière (en minutes)
  static const int earlyWindowMinutes = 30;   // Vert : dans les 30min après l'adhan
  static const int lateWindowMinutes = 30;    // Rouge : dans les 30min avant la fin

  // Nombre de prières par jour
  static const int dailyPrayerCount = 5;

  // Tasbih post-prière
  static const int tasbeehCount = 33;

  // Pagination mosquées
  static const int mosqueSearchRadius = 20000; // mètres

  // Cache horaires de prière
  static const int prayerTimeCacheDays = 7;

  // Jardin Qada — paliers (10 paliers × 10%)
  static const int gardenTotalStages = 10;
  static const double gardenStagePercent = 0.10;
}
