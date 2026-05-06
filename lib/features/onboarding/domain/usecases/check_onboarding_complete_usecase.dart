import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

class CheckOnboardingCompleteUseCase {
  final ProfileRepository _repository;

  const CheckOnboardingCompleteUseCase(this._repository);

  Future<Either<Failure, bool>> call() {
    return _repository.isOnboardingComplete();
  }
}
