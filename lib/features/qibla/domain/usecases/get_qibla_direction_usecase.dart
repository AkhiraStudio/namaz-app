import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/qibla_direction.dart';
import '../repositories/qibla_repository.dart';

class GetQiblaDirectionUseCase {
  final QiblaRepository _repository;
  const GetQiblaDirectionUseCase(this._repository);

  Stream<Either<Failure, QiblaDirection>> call() {
    return _repository.getQiblaDirectionStream();
  }
}
