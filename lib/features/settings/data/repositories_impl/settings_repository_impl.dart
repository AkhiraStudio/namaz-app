import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/hive_service.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _local;
  const SettingsRepositoryImpl({required SettingsLocalDataSource local})
      : _local = local;

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final model = await _local.getSettings();
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(AppSettings settings) async {
    try {
      await _local.saveSettings(SettingsModel.fromEntity(settings));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resetPrayerData() async {
    try {
      await HiveService.clearUserData();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Erreur réinitialisation : $e'));
    }
  }
}
