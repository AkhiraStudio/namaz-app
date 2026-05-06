import 'package:equatable/equatable.dart';
import '../../../prayer/domain/entities/prayer_record.dart';

/// État de progression du rattrapage.
class QadaProgress extends Equatable {
  final int totalPrayersOwed;     // Stock initial (totalDaysOwed × 5)
  final int totalPrayersDone;     // Rattrapées à ce jour (toutes prières)
  final int currentStreak;
  final int longestStreak;
  final DateTime? targetDate;
  final int dailyTargetPrayers;
  /// Nombre de rattrapages effectués par prière.
  final Map<PrayerName, int> prayersDoneByName;

  const QadaProgress({
    required this.totalPrayersOwed,
    required this.totalPrayersDone,
    required this.currentStreak,
    required this.longestStreak,
    required this.prayersDoneByName,
    this.targetDate,
    this.dailyTargetPrayers = 5,
  });

  /// Jours de dette (chaque jour = 5 prières).
  int get totalDaysOwed => totalPrayersOwed ~/ 5;

  int get remaining => (totalPrayersOwed - totalPrayersDone).clamp(0, totalPrayersOwed);

  /// Progression globale 0.0–1.0.
  double get progressPercent {
    if (totalPrayersOwed == 0) return 1.0;
    return (totalPrayersDone / totalPrayersOwed).clamp(0.0, 1.0);
  }

  /// Progression 0.0–1.0 pour une prière spécifique.
  double prayerProgressPercent(PrayerName name) {
    if (totalDaysOwed == 0) return 1.0;
    final done = prayersDoneByName[name] ?? 0;
    return (done / totalDaysOwed).clamp(0.0, 1.0);
  }

  /// Palier du jardin atteint (0–10).
  int get gardenStage => (progressPercent * 10).floor().clamp(0, 10);

  @override
  List<Object?> get props => [
        totalPrayersOwed, totalPrayersDone, currentStreak,
        longestStreak, targetDate, dailyTargetPrayers, prayersDoneByName,
      ];
}
