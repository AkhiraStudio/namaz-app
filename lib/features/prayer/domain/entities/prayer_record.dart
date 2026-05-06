import 'package:equatable/equatable.dart';

/// Statut d'une prière validée par l'utilisateur.
enum PrayerStatus {
  early,          // Prié tôt   — Vert
  onTime,         // Prié à l'heure — Orange
  late,           // Prié tard   — Rouge
  missed,         // Prière manquée — Noir (envoyée en rattrapage automatiquement)
  menstruation,   // Menstrues (féminin) — Rose (pas de rattrapage, pas d'impact score)
}

/// Noms des 5 prières.
enum PrayerName { fajr, dhuhr, asr, maghrib, isha }

/// Enregistrement d'une prière effectuée (ou manquée) pour un jour donné.
class PrayerRecord extends Equatable {
  final String id;
  final DateTime date;
  final PrayerName prayerName;
  final PrayerStatus status;
  final DateTime? recordedAt;

  const PrayerRecord({
    required this.id,
    required this.date,
    required this.prayerName,
    required this.status,
    this.recordedAt,
  });

  bool get isMissed => status == PrayerStatus.missed;

  @override
  List<Object?> get props => [id, date, prayerName, status, recordedAt];
}
