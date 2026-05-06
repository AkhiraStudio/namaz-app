import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class SaveProfileUseCase {
  final ProfileRepository _repository;

  const SaveProfileUseCase(this._repository);

  Future<Either<Failure, void>> call(UserProfile profile) {
    return _repository.saveProfile(profile);
  }
}
