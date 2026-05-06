import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/mosque.dart';
import '../repositories/prayer_repository.dart';

class GetNearbyMosquesUseCase {
  final PrayerRepository _repository;

  const GetNearbyMosquesUseCase(this._repository);

  Future<Either<Failure, List<Mosque>>> call({
    required double latitude,
    required double longitude,
  }) {
    return _repository.getNearbyMosques(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
