import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class ToggleTravelerModeUseCase {
  final SettingsRepository _repository;
  const ToggleTravelerModeUseCase(this._repository);

  Future<Either<Failure, void>> call(bool enabled) async {
    final result = await _repository.getSettings();
    return result.fold(Left.new, (settings) =>
        _repository.saveSettings(settings.copyWith(travelerMode: enabled)));
  }
}
