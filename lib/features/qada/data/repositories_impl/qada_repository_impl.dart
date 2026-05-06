import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/qada_debt.dart';
import '../../domain/entities/qada_record.dart';
import '../../domain/entities/qada_progress.dart';
import '../../domain/entities/pending_missed_entry.dart';
import '../../domain/repositories/qada_repository.dart';
import '../../../prayer/domain/entities/prayer_record.dart';
import '../../../../shared/extensions/datetime_extensions.dart';
import '../datasources/qada_local_datasource.dart';
import '../models/qada_record_model.dart';
import '../models/qada_debt_model.dart';

class QadaRepositoryImpl implements QadaRepository {
  final QadaLocalDataSource _local;
  const QadaRepositoryImpl({required QadaLocalDataSource local})
      : _local = local;

  @override
  Future<Either<Failure, QadaDebt?>> getQadaDebt() async {
    try {
      final model = await _local.getQadaDebt();
      return Right(model?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveQadaDebt(QadaDebt debt) async {
    try {
      await _local.saveQadaDebt(QadaDebtModel.fromEntity(debt));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> recordQadaPrayer(QadaRecord record) async {
    try {
      await _local.saveQadaRecord(QadaRecordModel.fromEntity(record));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeLastTodayRecord(PrayerName name) async {
    try {
      await _local.deleteLastTodayRecord(name.index);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, QadaProgress>> getProgress() async {
    try {
      final debtModel = await _local.getQadaDebt();
      final debt = debtModel?.toEntity();
      final records = await _local.getAllRecords();
      final totalOwed = (debt?.totalDaysOwed ?? 0) * 5;
      final done = records.length;

      // Jours distincts ayant au moins une prière rattrapée
      final activeDays = <String>{};
      for (final r in records) {
        final d = DateTime.fromMillisecondsSinceEpoch(r.performedAtMs);
        activeDays.add(d.dateKey);
      }

      // currentStreak : jours consécutifs remontant depuis aujourd'hui
      int currentStreak = 0;
      final today = DateTime.now();
      for (int i = 0; i < 365; i++) {
        final day = today.subtract(Duration(days: i));
        final key = day.dateKey;
        if (activeDays.contains(key)) {
          currentStreak++;
        } else {
          break;
        }
      }

      // longestStreak : parcourt les jours triés et cherche la séquence max
      int longestStreak = 0, tempStreak = 0;
      final sortedDays = activeDays.toList()..sort();
      DateTime? prevDay;
      for (final key in sortedDays) {
        final day = DateTime.parse(key);
        final isConsecutive =
            prevDay != null && day.difference(prevDay).inDays == 1;
        tempStreak = isConsecutive ? tempStreak + 1 : 1;
        if (tempStreak > longestStreak) longestStreak = tempStreak;
        prevDay = day;
      }
      // Comptage par prière
      final prayersDoneByName = <PrayerName, int>{};
      for (final r in records) {
        final idx = r.prayerNameIndex;
        if (idx < 0 || idx >= PrayerName.values.length) continue;
        final name = PrayerName.values[idx];
        prayersDoneByName[name] = (prayersDoneByName[name] ?? 0) + 1;
      }

      int dailyTarget = 5;
      if (debt?.targetCompletionDate != null) {
        final remaining = (totalOwed - done).clamp(0, totalOwed);
        final daysLeft = debt!.targetCompletionDate!
            .difference(DateTime.now())
            .inDays
            .clamp(1, 99999);
        dailyTarget = (remaining / daysLeft).ceil();
      }

      return Right(QadaProgress(
        totalPrayersOwed: totalOwed,
        totalPrayersDone: done,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        prayersDoneByName: prayersDoneByName,
        targetDate: debt?.targetCompletionDate,
        dailyTargetPrayers: dailyTarget,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<QadaRecord>>> getTodayRecords() async {
    try {
      final models = await _local.getTodayRecords();
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<PrayerName>>> getRecentMissedPrayers() async {
    try {
      final records = await _local.getAllRecords();
      final missed = records
          .where((r) =>
              r.isFromRecentMissed &&
              r.prayerNameIndex >= 0 &&
              r.prayerNameIndex < PrayerName.values.length)
          .map((r) => PrayerName.values[r.prayerNameIndex])
          .toList();
      return Right(missed);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<PendingMissedEntry>>> getPendingMissedPrayers() async {
    try {
      final raw = _local.getAllPendingMissed();
      final result = raw.entries.expand((entry) {
        final parts = entry.value.split(':');
        final idx = int.tryParse(parts[0]) ?? -1;
        if (idx < 0 || idx >= PrayerName.values.length || parts.length < 2) {
          return <PendingMissedEntry>[];
        }
        final name = PrayerName.values[idx];
        final ms = int.tryParse(parts[1]) ?? 0;
        final missedAt = DateTime.fromMillisecondsSinceEpoch(ms);
        return [PendingMissedEntry(key: entry.key, prayerName: name, missedAt: missedAt)];
      }).toList();
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addPendingMissedPrayer(
      String key, PrayerName name, DateTime missedAt) async {
    try {
      final value = '${name.index}:${missedAt.millisecondsSinceEpoch}';
      await _local.addPendingMissed(key, value);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removePendingMissedPrayerByKey(String key) async {
    try {
      await _local.removePendingMissed(key);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> makeUpRecentMissed(
      String key, PrayerName name) async {
    try {
      await _local.removePendingMissed(key);
      const uuid = Uuid();
      await _local.saveQadaRecord(QadaRecordModel.fromEntity(QadaRecord(
        id: uuid.v4(),
        prayerName: name,
        performedAt: DateTime.now(),
        isFromRecentMissed: true,
      )));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
