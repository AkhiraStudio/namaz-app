import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/prayer_record.dart';
import '../repositories/prayer_repository.dart';

class RecordPrayerStatusUseCase {
  final PrayerRepository _repository;

  const RecordPrayerStatusUseCase(this._repository);

  Future<Either<Failure, void>> call(PrayerRecord record) {
    return _repository.recordPrayer(record);
  }
}
