import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class UpdateMensesCycleUseCase {
  final SettingsRepository _repository;
  const UpdateMensesCycleUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required int cycleDays,
    required int durationDays,
  }) async {
    final result = await _repository.getSettings();
    return result.fold(Left.new, (settings) =>
        _repository.saveSettings(settings.copyWith(
          mensCycleDays: cycleDays,
          mensDurationDays: durationDays,
        )));
  }
}
