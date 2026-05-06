import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<Either<Failure, AppUser>> signInWithGoogle();
  Future<Either<Failure, AppUser>> signInAnonymously();
  Future<Either<Failure, AppUser>> signInWithEmail({required String email, required String password});
  Future<Either<Failure, AppUser>> signUpWithEmail({required String email, required String password});
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, AppUser>> linkWithGoogle();
  Future<Either<Failure, void>> updateEmail(String newEmail);
  Future<Either<Failure, void>> updatePassword(String newPassword);
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, void>> signOut();
  AppUser? get currentUser;
}
