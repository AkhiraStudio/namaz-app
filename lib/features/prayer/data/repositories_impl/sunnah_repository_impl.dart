import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/extensions/datetime_extensions.dart';
import '../../domain/entities/sunnah_prayer.dart';
import '../../domain/repositories/sunnah_repository.dart';
import '../datasources/sunnah_local_datasource.dart';

class SunnahRepositoryImpl implements SunnahRepository {
  final SunnahLocalDataSource _local;

  const SunnahRepositoryImpl({required SunnahLocalDataSource local})
      : _local = local;

  @override
  Either<Failure, Set<SunnahPrayer>> getTodayRecords() {
    try {
      return Right(_local.getTodayRecords());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> toggle(
      SunnahPrayer prayer, bool isDone) async {
    try {
      final key = '${DateTime.now().dateKey}:${prayer.index}';
      if (isDone) {
        await _local.setRecord(key, true);
      } else {
        await _local.deleteRecord(key);
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, SunnahStats>> getStatistics({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final recordsByDay = _local.getRecordsBetween(from, to);
      final today = DateTime.now();
      var cursor = DateTime(from.year, from.month, from.day);
      final endDay = DateTime(to.year, to.month, to.day);
      int days = 0;
      while (!cursor.isAfter(endDay) && !cursor.isAfter(today)) {
        days++;
        cursor = cursor.add(const Duration(days: 1));
      }
      final done = recordsByDay.values.fold(0, (sum, s) => sum + s.length);
      final total = days * SunnahPrayer.values.length;
      final rate = total == 0 ? 0.0 : done / total;
      return Right((done: done, total: total, rate: rate));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
