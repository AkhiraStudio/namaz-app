import '../../../prayer/domain/entities/prayer_record.dart';

/// Entrée du flux "prières manquées récentes" en attente de rattrapage.
class PendingMissedEntry {
  final String key;
  final PrayerName prayerName;
  final DateTime missedAt;

  const PendingMissedEntry({
    required this.key,
    required this.prayerName,
    required this.missedAt,
  });
}
