import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class ResetPrayerDataUseCase {
  final SettingsRepository _repository;
  const ResetPrayerDataUseCase(this._repository);

  Future<Either<Failure, void>> call() => _repository.resetPrayerData();
}
