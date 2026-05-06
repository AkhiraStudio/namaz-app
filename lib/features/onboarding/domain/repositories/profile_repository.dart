import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';

/// Interface du repository profil (couche domain).
abstract class ProfileRepository {
  Future<Either<Failure, UserProfile?>> getProfile();
  Future<Either<Failure, void>> saveProfile(UserProfile profile);
  Future<Either<Failure, bool>> isOnboardingComplete();
  Future<Either<Failure, void>> deleteProfile();
}
