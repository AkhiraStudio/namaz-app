import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  const AuthRepositoryImpl({required AuthRemoteDataSource remote}) : _remote = remote;

  @override
  Stream<AppUser?> get authStateChanges => _remote.authStateChanges;

  @override
  AppUser? get currentUser => _remote.currentUser;

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final user = await _remote.signInWithGoogle();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInAnonymously() async {
    try {
      final user = await _remote.signInAnonymously();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithEmail({required String email, required String password}) async {
    try {
      final user = await _remote.signInWithEmail(email: email, password: password);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmail({required String email, required String password}) async {
    try {
      final user = await _remote.signUpWithEmail(email: email, password: password);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _remote.sendPasswordResetEmail(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AppUser>> linkWithGoogle() async {
    try {
      final user = await _remote.linkWithGoogle();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateEmail(String newEmail) async {
    try {
      await _remote.updateEmail(newEmail);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) async {
    try {
      await _remote.updatePassword(newPassword);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _remote.deleteAccount();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remote.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
