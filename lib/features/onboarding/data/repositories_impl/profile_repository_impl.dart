import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource _localDataSource;
  final FirestoreService? _firestore;

  const ProfileRepositoryImpl({
    required ProfileLocalDataSource localDataSource,
    FirestoreService? firestore,
  })  : _localDataSource = localDataSource,
        _firestore = firestore;

  @override
  Future<Either<Failure, UserProfile?>> getProfile() async {
    try {
      final model = await _localDataSource.getProfile();
      return Right(model?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveProfile(UserProfile profile) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      await _localDataSource.saveProfile(model);
      // Fire-and-forget Firestore sync
      _firestore?.saveProfile(_profileToMap(profile));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> isOnboardingComplete() async {
    try {
      final result = await _localDataSource.isOnboardingComplete();
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfile() async {
    try {
      await _localDataSource.deleteProfile();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  /// Restaure le profil depuis Firestore si Hive est vide (nouvel appareil).
  Future<void> restoreFromCloud() async {
    try {
      final local = await _localDataSource.getProfile();
      if (local != null) return; // Hive déjà rempli — pas de restauration
      final remote = await _firestore?.getProfile();
      if (remote == null) return;
      final profile = _profileFromMap(remote);
      await _localDataSource.saveProfile(UserProfileModel.fromEntity(profile));
    } catch (_) {}
  }

  static Map<String, dynamic> _profileToMap(UserProfile p) => {
        'id': p.id,
        'name': p.name,
        'genderIndex': p.gender.index,
        'languageCode': p.languageCode,
        'mosqueName': p.mosqueName,
        'mosqueLatitude': p.mosqueLatitude,
        'mosqueLongitude': p.mosqueLongitude,
        'travelerMode': p.travelerMode,
        'mensCycleDays': p.mensCycleDays,
        'mensDurationDays': p.mensDurationDays,
        'onboardingComplete': p.onboardingComplete,
      };

  static UserProfile _profileFromMap(Map<String, dynamic> m) => UserProfile(
        id: m['id'] as String? ?? '',
        name: m['name'] as String? ?? '',
        gender: UserGender.values[(m['genderIndex'] as int?) ?? 0],
        languageCode: m['languageCode'] as String? ?? 'fr',
        mosqueName: m['mosqueName'] as String?,
        mosqueLatitude: (m['mosqueLatitude'] as num?)?.toDouble(),
        mosqueLongitude: (m['mosqueLongitude'] as num?)?.toDouble(),
        travelerMode: m['travelerMode'] as bool? ?? false,
        mensCycleDays: m['mensCycleDays'] as int?,
        mensDurationDays: m['mensDurationDays'] as int?,
        onboardingComplete: m['onboardingComplete'] as bool? ?? false,
      );
}
