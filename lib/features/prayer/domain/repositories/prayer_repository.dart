import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/mosque.dart';
import '../entities/prayer_time.dart';
import '../entities/prayer_record.dart';
import '../entities/prayer_statistics.dart';

abstract class PrayerRepository {
  /// Récupère les horaires du jour (cache local d'abord, API si expiré).
  Future<Either<Failure, PrayerTime>> getPrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    int method = 12,
  });

  /// Enregistre le statut d'une prière.
  Future<Either<Failure, void>> recordPrayer(PrayerRecord record);

  /// Récupère les enregistrements d'une journée.
  Future<Either<Failure, List<PrayerRecord>>> getDayRecords(DateTime date);

  /// Récupère les statistiques sur une période.
  Future<Either<Failure, PrayerStatistics>> getStatistics({
    required DateTime from,
    required DateTime to,
  });

  /// Récupère les mosquées proches d'une position.
  Future<Either<Failure, List<Mosque>>> getNearbyMosques({
    required double latitude,
    required double longitude,
  });
}
