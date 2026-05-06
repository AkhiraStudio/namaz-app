import 'package:equatable/equatable.dart';
import 'prayer_record.dart';

/// Agrégats statistiques des prières sur une période.
class PrayerStatistics extends Equatable {
  final int totalPrayed;
  final int totalMissed;
  final int totalEarly;
  final int totalOnTime;
  final int totalLate;
  final int currentStreak;   // Jours consécutifs sans manquer de prière
  final int longestStreak;
  final Map<PrayerName, int> missedByPrayer;
  final Map<PrayerName, int> lateByPrayer;

  const PrayerStatistics({
    required this.totalPrayed,
    required this.totalMissed,
    required this.totalEarly,
    required this.totalOnTime,
    required this.totalLate,
    required this.currentStreak,
    required this.longestStreak,
    required this.missedByPrayer,
    required this.lateByPrayer,
  });

  double get adherenceRate {
    final total = totalPrayed + totalMissed;
    if (total == 0) return 0;
    return totalPrayed / total;
  }

  @override
  List<Object?> get props => [
        totalPrayed, totalMissed, totalEarly, totalOnTime,
        totalLate, currentStreak, longestStreak, missedByPrayer, lateByPrayer,
      ];
}
