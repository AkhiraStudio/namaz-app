import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/qada_debt.dart';
import '../entities/qada_record.dart';
import '../entities/qada_progress.dart';
import '../entities/pending_missed_entry.dart';
import '../../../prayer/domain/entities/prayer_record.dart';

abstract class QadaRepository {
  Future<Either<Failure, QadaDebt?>> getQadaDebt();
  Future<Either<Failure, void>> saveQadaDebt(QadaDebt debt);
  Future<Either<Failure, void>> recordQadaPrayer(QadaRecord record);
  Future<Either<Failure, void>> removeLastTodayRecord(PrayerName name);
  Future<Either<Failure, QadaProgress>> getProgress();
  Future<Either<Failure, List<QadaRecord>>> getTodayRecords();
  Future<Either<Failure, List<PrayerName>>> getRecentMissedPrayers();

  // Flux récent : prières manquées en attente de rattrapage
  Future<Either<Failure, List<PendingMissedEntry>>> getPendingMissedPrayers();
  Future<Either<Failure, void>> addPendingMissedPrayer(
      String key, PrayerName name, DateTime missedAt);
  Future<Either<Failure, void>> removePendingMissedPrayerByKey(String key);
  Future<Either<Failure, void>> makeUpRecentMissed(String key, PrayerName name);
}
