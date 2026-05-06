import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sunnah_prayer.dart';
import '../repositories/sunnah_repository.dart';

class GetTodaySunnahUseCase {
  final SunnahRepository _repository;
  const GetTodaySunnahUseCase(this._repository);

  Either<Failure, Set<SunnahPrayer>> call() => _repository.getTodayRecords();
}
