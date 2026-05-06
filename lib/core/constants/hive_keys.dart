/// Noms des boîtes Hive et clés de champs.
class HiveBoxNames {
  HiveBoxNames._();

  static const String userProfile = 'user_profile';
  static const String prayerTimes = 'prayer_times';
  static const String prayerRecords = 'prayer_records';
  static const String qadaDebt = 'qada_debt';
  static const String qadaRecords = 'qada_records';
  static const String settings = 'settings';
  static const String pendingRecentMissed = 'pending_recent_missed';
  static const String sunnahRecords = 'sunnah_records';
  static const String adhkarProgress = 'adhkar_progress';
  static const String adhkarCompletions = 'adhkar_completions';
  static const String tasbeehCompletions = 'tasbeeh_completions';
}

/// Type IDs Hive pour les HiveObjects (chaque classe doit avoir un ID unique).
class HiveTypeIds {
  HiveTypeIds._();

  static const int userProfileModel = 0;
  static const int prayerTimeModel = 1;
  static const int prayerRecordModel = 2;
  static const int qadaDebtModel = 3;
  static const int qadaRecordModel = 4;
  static const int settingsModel = 5;
}
