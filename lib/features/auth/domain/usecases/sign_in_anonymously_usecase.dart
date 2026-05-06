import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInAnonymouslyUseCase {
  final AuthRepository _repository;
  const SignInAnonymouslyUseCase(this._repository);

  Future<Either<Failure, AppUser>> call() => _repository.signInAnonymously();
}
