import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailUseCase {
  final AuthRepository _repository;
  const SignUpWithEmailUseCase(this._repository);

  Future<Either<Failure, AppUser>> call({
    required String email,
    required String password,
  }) =>
      _repository.signUpWithEmail(email: email, password: password);
}
