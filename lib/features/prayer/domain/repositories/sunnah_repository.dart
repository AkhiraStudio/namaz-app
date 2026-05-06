import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sunnah_prayer.dart';

typedef SunnahStats = ({int done, int total, double rate});

abstract class SunnahRepository {
  /// Prières surérogatoires accomplies aujourd'hui (synchrone — Hive ouvert).
  Either<Failure, Set<SunnahPrayer>> getTodayRecords();

  /// Active ou désactive une prière surérogatoire pour aujourd'hui.
  Future<Either<Failure, void>> toggle(SunnahPrayer prayer, bool isDone);

  /// Statistiques (accompli / total) sur une période.
  Future<Either<Failure, SunnahStats>> getStatistics({
    required DateTime from,
    required DateTime to,
  });
}
