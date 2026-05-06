import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class UpdateLanguageUseCase {
  final SettingsRepository _repository;
  const UpdateLanguageUseCase(this._repository);

  Future<Either<Failure, void>> call(String languageCode) async {
    final result = await _repository.getSettings();
    return result.fold(Left.new, (settings) async {
      return _repository.saveSettings(
          settings.copyWith(languageCode: languageCode));
    });
  }
}
