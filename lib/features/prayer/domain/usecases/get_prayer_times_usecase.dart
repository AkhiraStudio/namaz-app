import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/prayer_time.dart';
import '../repositories/prayer_repository.dart';

class GetPrayerTimesParams {
  final double latitude;
  final double longitude;
  final DateTime date;
  final int method;

  const GetPrayerTimesParams({
    required this.latitude,
    required this.longitude,
    required this.date,
    this.method = 12,
  });
}

class GetPrayerTimesUseCase {
  final PrayerRepository _repository;

  const GetPrayerTimesUseCase(this._repository);

  Future<Either<Failure, PrayerTime>> call(GetPrayerTimesParams params) {
    return _repository.getPrayerTimes(
      latitude: params.latitude,
      longitude: params.longitude,
      date: params.date,
      method: params.method,
    );
  }
}
