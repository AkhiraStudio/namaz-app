import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/sunnah_repository.dart';

class GetSunnahStatisticsUseCase {
  final SunnahRepository _repository;
  const GetSunnahStatisticsUseCase(this._repository);

  Future<Either<Failure, SunnahStats>> call({
    required DateTime from,
    required DateTime to,
  }) =>
      _repository.getStatistics(from: from, to: to);
}
