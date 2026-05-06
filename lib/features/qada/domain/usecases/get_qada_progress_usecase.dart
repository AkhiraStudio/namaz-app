import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/qada_progress.dart';
import '../repositories/qada_repository.dart';

class GetQadaProgressUseCase {
  final QadaRepository _repository;
  const GetQadaProgressUseCase(this._repository);

  Future<Either<Failure, QadaProgress>> call() {
    return _repository.getProgress();
  }
}
