import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/qada_local_datasource.dart';
import '../../data/repositories_impl/qada_repository_impl.dart';
import '../../domain/entities/qada_progress.dart';
import '../../domain/entities/qada_record.dart';
import '../../domain/entities/pending_missed_entry.dart';
import '../../domain/usecases/calculate_qada_debt_usecase.dart';
import '../../domain/usecases/get_qada_progress_usecase.dart';
import '../../domain/usecases/get_daily_qada_schedule_usecase.dart';
import '../../domain/usecases/record_qada_prayer_usecase.dart';
import '../../domain/usecases/set_qada_target_date_usecase.dart';
import '../../../prayer/domain/entities/prayer_record.dart';

// ── Dependencies ──────────────────────────────────────────────────────────────

final qadaLocalDataSourceProvider = Provider<QadaLocalDataSource>(
  (_) => QadaLocalDataSourceImpl(),
);

final qadaRepositoryProvider = Provider((ref) => QadaRepositoryImpl(
      local: ref.read(qadaLocalDataSourceProvider),
    ));

final calculateQadaDebtUseCaseProvider = Provider(
  (ref) => CalculateQadaDebtUseCase(ref.read(qadaRepositoryProvider)),
);
final getQadaProgressUseCaseProvider = Provider(
  (ref) => GetQadaProgressUseCase(ref.read(qadaRepositoryProvider)),
);
final recordQadaPrayerUseCaseProvider = Provider(
  (ref) => RecordQadaPrayerUseCase(ref.read(qadaRepositoryProvider)),
);
final setQadaTargetDateUseCaseProvider = Provider(
  (ref) => SetQadaTargetDateUseCase(ref.read(qadaRepositoryProvider)),
);
final getDailyQadaScheduleUseCaseProvider = Provider(
  (ref) => GetDailyQadaScheduleUseCase(ref.read(qadaRepositoryProvider)),
);

// ── Progress Notifier ─────────────────────────────────────────────────────────

class QadaProgressNotifier extends AsyncNotifier<QadaProgress> {
  @override
  Future<QadaProgress> build() async {
    final result =
        await ref.read(getQadaProgressUseCaseProvider).call();
    return result.fold(
      (f) => throw Exception(f.message),
      (p) => p,
    );
  }

  Future<void> recordPrayer(PrayerName prayerName,
      {bool isRecent = false}) async {
    const uuid = Uuid();
    final record = QadaRecord(
      id: uuid.v4(),
      prayerName: prayerName,
      performedAt: DateTime.now(),
      isFromRecentMissed: isRecent,
    );
    final result =
        await ref.read(recordQadaPrayerUseCaseProvider).call(record);
    result.fold(
      (f) => state = AsyncError(Exception(f.message), StackTrace.current),
      (_) {
        ref.invalidateSelf();
        ref.invalidate(todayQadaCountsProvider);
      },
    );
  }

  Future<void> removePrayer(PrayerName prayerName) async {
    final result =
        await ref.read(qadaRepositoryProvider).removeLastTodayRecord(prayerName);
    result.fold(
      (f) => state = AsyncError(Exception(f.message), StackTrace.current),
      (_) {
        ref.invalidateSelf();
        ref.invalidate(todayQadaCountsProvider);
      },
    );
  }

  Future<void> makeUpRecentMissed(String key, PrayerName name) async {
    final result =
        await ref.read(qadaRepositoryProvider).makeUpRecentMissed(key, name);
    result.fold(
      (f) => state = AsyncError(Exception(f.message), StackTrace.current),
      (_) {
        ref.invalidateSelf();
        ref.invalidate(pendingRecentMissedProvider);
        ref.invalidate(todayQadaCountsProvider);
      },
    );
  }

  Future<void> setTargetDate(DateTime date) async {
    await ref.read(setQadaTargetDateUseCaseProvider).call(date);
    ref.invalidateSelf();
  }

  Future<void> calculateDebt(CalculateQadaDebtParams params) async {
    await ref.read(calculateQadaDebtUseCaseProvider).call(params);
    ref.invalidateSelf();
  }
}

final qadaProgressProvider =
    AsyncNotifierProvider<QadaProgressNotifier, QadaProgress>(
  QadaProgressNotifier.new,
);

/// Prières manquées récentes en attente de rattrapage.
final pendingRecentMissedProvider =
    FutureProvider<List<PendingMissedEntry>>((ref) async {
  final result =
      await ref.read(qadaRepositoryProvider).getPendingMissedPrayers();
  return result.fold((_) => [], (list) => list);
});

/// Nombre de rattrapages effectués aujourd'hui par prière (long terme).
final todayQadaCountsProvider =
    FutureProvider<Map<PrayerName, int>>((ref) async {
  final result = await ref.read(qadaRepositoryProvider).getTodayRecords();
  final records = result.fold((_) => <QadaRecord>[], (r) => r);
  final counts = <PrayerName, int>{};
  for (final r in records) {
    counts[r.prayerName] = (counts[r.prayerName] ?? 0) + 1;
  }
  return counts;
});

/// Dette brute (pour afficher le détail de la déduction dans le calculateur).
final qadaDebtProvider = FutureProvider((ref) async {
  ref.watch(qadaProgressProvider); // se met à jour après recalcul
  final result = await ref.read(qadaRepositoryProvider).getQadaDebt();
  return result.fold((_) => null, (debt) => debt);
});

/// Affichage de l'objectif : true = jours, false = nombre de prières.
final qadaObjectiveInDaysProvider = StateProvider<bool>((ref) => true);

/// Schedule du jour (liste des prières à rattraper).
final dailyQadaScheduleProvider =
    FutureProvider<List<PrayerName>>((ref) async {
  final progress = await ref.watch(qadaProgressProvider.future);
  final result = await ref
      .read(getDailyQadaScheduleUseCaseProvider)
      .call(progress.dailyTargetPrayers);
  return result.fold((_) => [], (s) => s);
});

// ── Statistiques par période ──────────────────────────────────────────────────

class QadaStats {
  final int last7days;
  final int last30days;
  final int last90days;
  final int last365days;
  final int currentStreak;
  final int longestStreak;
  final int totalDone;
  final Map<PrayerName, int> perPrayer;

  const QadaStats({
    required this.last7days,
    required this.last30days,
    required this.last90days,
    required this.last365days,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalDone,
    required this.perPrayer,
  });
}

// ── Rapport hebdomadaire qada ─────────────────────────────────────────────────

enum QadaWeekTrend { improved, stable, declined }

typedef QadaWeeklyReport = ({
  int currentWeek,
  int previousWeek,
  int delta,
  QadaWeekTrend trend,
  String message,
});

final qadaWeeklyReportProvider = FutureProvider<QadaWeeklyReport>((ref) async {
  ref.watch(qadaProgressProvider);
  final ds = ref.read(qadaLocalDataSourceProvider);
  final records = await ds.getAllRecords();

  final now = DateTime.now();
  final cut0  = now;
  final cut7  = now.subtract(const Duration(days: 7));
  final cut14 = now.subtract(const Duration(days: 14));

  int current = 0, previous = 0;
  for (final r in records) {
    final d = DateTime.fromMillisecondsSinceEpoch(r.performedAtMs);
    if (d.isAfter(cut7) && d.isBefore(cut0)) {
      current++;
    } else if (d.isAfter(cut14) && !d.isAfter(cut7)) {
      previous++;
    }
  }

  final delta = current - previous;

  final QadaWeekTrend trend;
  final String message;

  if (delta >= 5) {
    trend = QadaWeekTrend.improved;
    message = 'Excellente semaine ! +$delta prières de plus que la semaine dernière. BarakAllahu feek !';
  } else if (delta > 0) {
    trend = QadaWeekTrend.improved;
    message = 'Bonne progression ! Vous avez rattrapé $delta prière${delta > 1 ? 's' : ''} de plus cette semaine. Continuez !';
  } else if (delta == 0) {
    trend = QadaWeekTrend.stable;
    message = previous == 0
        ? 'Pas encore de données sur deux semaines pour comparer.'
        : 'Rythme stable. La constance est une des meilleures vertus en Islam.';
  } else if (delta >= -4) {
    trend = QadaWeekTrend.declined;
    message = 'Cette semaine a été un peu plus calme. Chaque prière rattrapée est une récompense — reprenez l\'élan !';
  } else {
    trend = QadaWeekTrend.declined;
    message = 'Ne vous découragez pas ! Allah aime les actions accomplies avec constance, même petites. Une prière à la fois.';
  }

  return (
    currentWeek: current,
    previousWeek: previous,
    delta: delta,
    trend: trend,
    message: message,
  );
});

// ── Statistiques par période ──────────────────────────────────────────────────

final qadaStatsProvider = FutureProvider<QadaStats>((ref) async {
  ref.watch(qadaProgressProvider); // se rafraîchit à chaque enregistrement
  final ds = ref.read(qadaLocalDataSourceProvider);
  final records = await ds.getAllRecords();

  final now = DateTime.now();
  final cut7   = now.subtract(const Duration(days: 7));
  final cut30  = now.subtract(const Duration(days: 30));
  final cut90  = now.subtract(const Duration(days: 90));
  final cut365 = now.subtract(const Duration(days: 365));

  int c7 = 0, c30 = 0, c90 = 0, c365 = 0;
  final perPrayer = <PrayerName, int>{for (final n in PrayerName.values) n: 0};

  for (final r in records) {
    final d = DateTime.fromMillisecondsSinceEpoch(r.performedAtMs);
    final pn = PrayerName.values[r.prayerNameIndex % PrayerName.values.length];
    perPrayer[pn] = (perPrayer[pn] ?? 0) + 1;
    if (d.isAfter(cut365)) {
      c365++;
      if (d.isAfter(cut90)) {
        c90++;
        if (d.isAfter(cut30)) {
          c30++;
          if (d.isAfter(cut7)) c7++;
        }
      }
    }
  }

  final progress = await ref.read(qadaProgressProvider.future);
  return QadaStats(
    last7days: c7,
    last30days: c30,
    last90days: c90,
    last365days: c365,
    currentStreak: progress.currentStreak,
    longestStreak: progress.longestStreak,
    totalDone: progress.totalPrayersDone,
    perPrayer: perPrayer,
  );
});

/// Complétion des 7 jours de la semaine en cours pour le qada.
/// true = nombre de prières rattrapées ce jour >= objectif journalier.
final weeklyQadaDotsProvider = FutureProvider<List<bool>>((ref) async {
  final progress = await ref.watch(qadaProgressProvider.future);
  final dailyTarget = progress.dailyTargetPrayers;
  final ds = ref.read(qadaLocalDataSourceProvider);
  final allRecords = await ds.getAllRecords();

  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));

  String dk(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  final countByDay = <String, int>{};
  for (final r in allRecords) {
    final d = DateTime.fromMillisecondsSinceEpoch(r.performedAtMs);
    final key = dk(d);
    if (!d.isBefore(monday) && d.isBefore(monday.add(const Duration(days: 7)))) {
      countByDay[key] = (countByDay[key] ?? 0) + 1;
    }
  }

  return List.generate(7, (i) {
    final day = monday.add(Duration(days: i));
    return (countByDay[dk(day)] ?? 0) >= dailyTarget;
  });
});
