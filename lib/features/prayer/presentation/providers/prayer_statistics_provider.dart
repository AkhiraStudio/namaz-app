import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/prayer_statistics.dart';
import '../../domain/entities/prayer_record.dart';
import '../../domain/repositories/sunnah_repository.dart';
import '../../domain/usecases/get_prayer_statistics_usecase.dart';
import '../../domain/usecases/get_sunnah_statistics_usecase.dart';
import '../../../../core/constants/hive_keys.dart';
import 'prayer_times_provider.dart';
import 'sunnah_provider.dart';

final getPrayerStatisticsUseCaseProvider = Provider((ref) {
  return GetPrayerStatisticsUseCase(ref.read(prayerRepositoryProvider));
});

/// Période de statistiques sélectionnée par l'utilisateur.
enum StatsPeriod { week, month, threeMonths, year }

final statsPeriodProvider = StateProvider<StatsPeriod>(
  (_) => StatsPeriod.month,
);

/// Plage de dates correspondant à la période sélectionnée.
({DateTime from, DateTime to}) _dateRange(StatsPeriod period) {
  final now = DateTime.now();
  final to = DateTime(now.year, now.month, now.day, 23, 59, 59);
  final from = switch (period) {
    StatsPeriod.week => to.subtract(const Duration(days: 6)),
    StatsPeriod.month => DateTime(now.year, now.month - 1, now.day),
    StatsPeriod.threeMonths => DateTime(now.year, now.month - 3, now.day),
    StatsPeriod.year => DateTime(now.year - 1, now.month, now.day),
  };
  return (from: from, to: to);
}

/// Statistiques des prières pour la période sélectionnée.
final prayerStatisticsProvider =
    FutureProvider<PrayerStatistics>((ref) async {
  final period = ref.watch(statsPeriodProvider);
  final range = _dateRange(period);
  final useCase = ref.read(getPrayerStatisticsUseCaseProvider);
  final result = await useCase(from: range.from, to: range.to);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stats) => stats,
  );
});

enum WeekTrend { improved, stable, declined }

typedef WeeklyReport = ({
  double currentRate,
  double previousRate,
  double delta,
  WeekTrend trend,
  String message,
  Map<PrayerName, int> struggleByPrayer,
});

/// Rapport semaine en cours vs semaine précédente.
final weeklyReportProvider = FutureProvider<WeeklyReport>((ref) async {
  final useCase = ref.read(getPrayerStatisticsUseCaseProvider);
  final now = DateTime.now();
  final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

  final currentFrom = todayEnd.subtract(const Duration(days: 6));
  final previousFrom = todayEnd.subtract(const Duration(days: 13));
  final previousTo = todayEnd.subtract(const Duration(days: 7));

  final currentResult =
      await useCase(from: currentFrom, to: todayEnd);
  final previousResult =
      await useCase(from: previousFrom, to: previousTo);

  final current = currentResult.fold((_) => null, (s) => s);
  final previous = previousResult.fold((_) => null, (s) => s);

  final currentRate = current?.adherenceRate ?? 0.0;
  final previousRate = previous?.adherenceRate ?? 0.0;
  final delta = currentRate - previousRate;

  final WeekTrend trend;
  final String message;

  if (delta >= 0.08) {
    trend = WeekTrend.improved;
    message = 'Excellent progrès cette semaine ! Continuez sur cette lancée.';
  } else if (delta >= 0.02) {
    trend = WeekTrend.improved;
    message = 'Légère amélioration par rapport à la semaine dernière. Bien joué !';
  } else if (delta <= -0.08) {
    trend = WeekTrend.declined;
    message = 'Cette semaine a été plus difficile. Chaque prière compte, ne vous découragez pas.';
  } else if (delta <= -0.02) {
    trend = WeekTrend.declined;
    message = 'Petit relâchement cette semaine. Reprenez le rythme, vous en êtes capable.';
  } else {
    trend = WeekTrend.stable;
    message = previousRate == 0.0
        ? 'Pas encore assez de données pour comparer.'
        : 'Votre régularité est constante. Maintenez cet effort !';
  }

  // Prières avec le plus de difficulté cette semaine (manquées + en retard)
  final struggleByPrayer = <PrayerName, int>{};
  if (current != null) {
    for (final name in PrayerName.values) {
      final score = (current.missedByPrayer[name] ?? 0) +
          (current.lateByPrayer[name] ?? 0);
      if (score > 0) struggleByPrayer[name] = score;
    }
  }

  return (
    currentRate: currentRate,
    previousRate: previousRate,
    delta: delta,
    trend: trend,
    message: message,
    struggleByPrayer: struggleByPrayer,
  );
});

final getSunnahStatisticsUseCaseProvider = Provider(
  (ref) => GetSunnahStatisticsUseCase(ref.read(sunnahRepositoryProvider)),
);

/// Statistiques des prières surérogatoires pour la période sélectionnée.
/// FutureProvider.autoDispose : calcul déporté hors du thread principal.
final sunnahStatisticsProvider =
    FutureProvider.autoDispose<SunnahStats>((ref) async {
  final period = ref.watch(statsPeriodProvider);
  final range = _dateRange(period);
  final useCase = ref.read(getSunnahStatisticsUseCaseProvider);
  final result = await useCase(from: range.from, to: range.to);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stats) => stats,
  );
});

// ── Stats adhkar + tasbih ─────────────────────────────────────────────────────

typedef SpiritualStats = ({
  int morningAdhkarDays,
  int eveningAdhkarDays,
  int sleepAdhkarDays,
  int tasbeehDays,
  int periodDays,
});

final spiritualStatsProvider = Provider<SpiritualStats>((ref) {
  final period = ref.watch(statsPeriodProvider);
  final days = switch (period) {
    StatsPeriod.week => 7,
    StatsPeriod.month => 30,
    StatsPeriod.threeMonths => 90,
    StatsPeriod.year => 365,
  };

  final now = DateTime.now();
  final adhkarBox = Hive.box<bool>(HiveBoxNames.adhkarCompletions);
  final tasbeehBox = Hive.box<bool>(HiveBoxNames.tasbeehCompletions);

  int morningDays = 0, eveningDays = 0, sleepDays = 0, tasbeehDays = 0;

  for (int i = 0; i < days; i++) {
    final d = now.subtract(Duration(days: i));
    final key =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (adhkarBox.get('morning_$key') == true) morningDays++;
    if (adhkarBox.get('evening_$key') == true) eveningDays++;
    if (adhkarBox.get('sleep_$key') == true) sleepDays++;
    // Tasbih : au moins une prière complétée ce jour
    const prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    if (prayers.any((p) => tasbeehBox.get('${p}_$key') == true)) {
      tasbeehDays++;
    }
  }

  return (
    morningAdhkarDays: morningDays,
    eveningAdhkarDays: eveningDays,
    sleepAdhkarDays: sleepDays,
    tasbeehDays: tasbeehDays,
    periodDays: days,
  );
});

/// Complétion des 7 jours de la semaine en cours (lundi → dimanche).
/// true = toutes les prières faites, aucune manquée (menstruation ignorée).
final weeklyPrayerDotsProvider = FutureProvider<List<bool>>((ref) async {
  final local = ref.read(prayerLocalDataSourceProvider);
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));

  String dk(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  final all = await local.getRecordsBetween(dk(monday), dk(monday.add(const Duration(days: 6))));

  final byDay = <String, List<dynamic>>{};
  for (final r in all) {
    final d = DateTime.fromMillisecondsSinceEpoch(r.dateMs);
    byDay.putIfAbsent(dk(d), () => []).add(r);
  }

  return List.generate(7, (i) {
    final day = monday.add(Duration(days: i));
    final records = byDay[dk(day)] ?? [];
    if (records.isEmpty) return false;
    final isMensDay = records.every((r) => r.statusIndex == 4);
    if (isMensDay) return true;
    final hasMissed = records.any((r) => r.statusIndex == 3);
    final nonMens = records.where((r) => r.statusIndex != 4).toList();
    return nonMens.length >= 5 && !hasMissed;
  });
});

/// Streak indépendant de la période sélectionnée — fenêtre 3 ans.
/// Ne dépend pas de [statsPeriodProvider] pour ne pas se recharger quand
/// l'utilisateur change l'onglet de période dans l'écran statistiques.
final homeStreakProvider = FutureProvider<int>((ref) async {
  final useCase = ref.read(getPrayerStatisticsUseCaseProvider);
  final now = DateTime.now();
  final to = DateTime(now.year, now.month, now.day, 23, 59, 59);
  final from = DateTime(now.year - 3, now.month, now.day);
  final result = await useCase(from: from, to: to);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stats) => stats.currentStreak,
  );
});
