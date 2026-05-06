import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sunnah_prayer.dart';
import '../repositories/sunnah_repository.dart';

class ToggleSunnahUseCase {
  final SunnahRepository _repository;
  const ToggleSunnahUseCase(this._repository);

  Future<Either<Failure, void>> call(SunnahPrayer prayer, bool isDone) =>
      _repository.toggle(prayer, isDone);
}
