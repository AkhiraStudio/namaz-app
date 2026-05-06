import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/prayer_statistics.dart';
import '../repositories/prayer_repository.dart';

class GetPrayerStatisticsUseCase {
  final PrayerRepository _repository;

  const GetPrayerStatisticsUseCase(this._repository);

  Future<Either<Failure, PrayerStatistics>> call({
    required DateTime from,
    required DateTime to,
  }) {
    return _repository.getStatistics(from: from, to: to);
  }
}
