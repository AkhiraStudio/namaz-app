import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/mosque.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/entities/prayer_record.dart';
import '../../domain/entities/prayer_statistics.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../../../../shared/extensions/datetime_extensions.dart';
import '../datasources/prayer_local_datasource.dart';
import '../datasources/prayer_remote_datasource.dart';
import '../models/prayer_record_model.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerRemoteDataSource _remote;
  final PrayerLocalDataSource _local;
  final NetworkInfo _networkInfo;
  final FirestoreService? _firestore;

  const PrayerRepositoryImpl({
    required PrayerRemoteDataSource remote,
    required PrayerLocalDataSource local,
    required NetworkInfo networkInfo,
    FirestoreService? firestore,
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo,
        _firestore = firestore;

  @override
  Future<Either<Failure, PrayerTime>> getPrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    int method = 12,
  }) async {
    final key = '${date.dateKey}_m$method';
    try {
      // Offline-first : cache Hive en priorité
      final cached = await _local.getCachedPrayerTimes(key);
      if (cached != null) return Right(cached.toEntity());

      // Fallback réseau
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        return const Left(NetworkFailure());
      }
      final model = await _remote.getPrayerTimes(
        latitude: latitude,
        longitude: longitude,
        date: date,
        method: method,
      );
      await _local.cachePrayerTimes(model);
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> recordPrayer(PrayerRecord record) async {
    try {
      final model = PrayerRecordModel.fromEntity(record);
      await _local.savePrayerRecord(model);
      // Fire-and-forget Firestore sync
      _firestore?.savePrayerRecord({
        'id': record.id,
        'dateMs': record.date.millisecondsSinceEpoch,
        'prayerNameIndex': record.prayerName.index,
        'statusIndex': record.status.index,
        'recordedAtMs': record.recordedAt?.millisecondsSinceEpoch,
      });
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  Future<void> restoreFromCloud() async {
    try {
      if (await _local.hasAnyRecord()) return;
      final records = await _firestore?.getPrayerRecords() ?? [];
      for (final r in records) {
        final model = PrayerRecordModel(
          id: r['id'] as String? ?? '',
          dateMs: (r['dateMs'] as num?)?.toInt() ?? 0,
          prayerNameIndex: (r['prayerNameIndex'] as num?)?.toInt() ?? 0,
          statusIndex: (r['statusIndex'] as num?)?.toInt() ?? 0,
          recordedAtMs: (r['recordedAtMs'] as num?)?.toInt(),
        );
        await _local.savePrayerRecord(model);
      }
    } catch (_) {}
  }

  @override
  Future<Either<Failure, List<PrayerRecord>>> getDayRecords(
      DateTime date) async {
    try {
      final models = await _local.getDayRecords(date.dateKey);
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PrayerStatistics>> getStatistics({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final models =
          await _local.getRecordsBetween(from.dateKey, to.dateKey);
      final records = models.map((m) => m.toEntity()).toList();

      int early = 0, onTime = 0, late = 0, missed = 0;
      final missedByPrayer = <PrayerName, int>{};
      final lateByPrayer = <PrayerName, int>{};

      for (final r in records) {
        switch (r.status) {
          case PrayerStatus.early:
            early++;
          case PrayerStatus.onTime:
            onTime++;
          case PrayerStatus.late:
            late++;
            lateByPrayer[r.prayerName] =
                (lateByPrayer[r.prayerName] ?? 0) + 1;
          case PrayerStatus.missed:
            missed++;
            missedByPrayer[r.prayerName] =
                (missedByPrayer[r.prayerName] ?? 0) + 1;
          case PrayerStatus.menstruation:
            break;
        }
      }

      // Calcul des streaks : jours consécutifs où les 5 prières sont validées.
      // Les jours de menstruation sont ignorés (ni comptés ni pénalisés).
      final recordsByDate = <String, List<PrayerRecord>>{};
      for (final r in records) {
        final key = r.date.dateKey;
        recordsByDate.putIfAbsent(key, () => []).add(r);
      }

      bool isMensDay(List<PrayerRecord> recs) =>
          recs.any((r) => r.status == PrayerStatus.menstruation);

      int currentStreak = 0, longestStreak = 0, tempStreak = 0;
      final today = DateTime.now();

      // currentStreak : jours consécutifs entièrement validés (5 prières, aucune manquée).
      // Le jour courant ne compte que lorsqu'il est complet ; une prière manquée remet à 0.
      for (int i = 0; i <= 365; i++) {
        final day = today.subtract(Duration(days: i));
        final dayRecords = recordsByDate[day.dateKey] ?? [];
        if (isMensDay(dayRecords)) continue;
        final allPrayed = dayRecords.length >= 5 &&
            dayRecords.every((r) => r.status != PrayerStatus.missed);
        if (allPrayed) {
          currentStreak++;
        } else {
          break;
        }
      }

      // longestStreak : on parcourt toutes les dates triées en sautant les jours de mens
      final sortedKeys = recordsByDate.keys.toList()..sort();
      DateTime? prevDay;
      for (final key in sortedKeys) {
        final dayRecords = recordsByDate[key]!;
        if (isMensDay(dayRecords)) continue; // jour ignoré
        final day = DateTime.parse(key);
        final allPrayed = dayRecords.length >= 5 &&
            dayRecords.every((r) => r.status != PrayerStatus.missed);
        if (allPrayed) {
          // Consécutif si le jour précédent valide est le jour d'avant
          final isConsecutive =
              prevDay != null && day.difference(prevDay).inDays == 1;
          tempStreak = isConsecutive ? tempStreak + 1 : 1;
          if (tempStreak > longestStreak) longestStreak = tempStreak;
          prevDay = day;
        } else {
          tempStreak = 0;
          prevDay = null;
        }
      }

      return Right(PrayerStatistics(
        totalPrayed: early + onTime + late,
        totalMissed: missed,
        totalEarly: early,
        totalOnTime: onTime,
        totalLate: late,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        missedByPrayer: missedByPrayer,
        lateByPrayer: lateByPrayer,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Mosque>>> getNearbyMosques({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) return const Left(NetworkFailure());
      final result = await _remote.getNearbyMosques(
        latitude: latitude,
        longitude: longitude,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
