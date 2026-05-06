import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/qada_record.dart';
import '../repositories/qada_repository.dart';

class RecordQadaPrayerUseCase {
  final QadaRepository _repository;
  const RecordQadaPrayerUseCase(this._repository);

  Future<Either<Failure, void>> call(QadaRecord record) {
    return _repository.recordQadaPrayer(record);
  }
}
