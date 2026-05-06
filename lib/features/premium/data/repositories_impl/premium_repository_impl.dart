import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/premium_status.dart';
import '../../domain/repositories/premium_repository.dart';
import '../datasources/premium_remote_datasource.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  final PremiumRemoteDataSource _remote;
  PremiumRepositoryImpl(this._remote);

  /// Émet le statut courant immédiatement (warm-up), puis les mises à jour live.
  /// Dégradation gracieuse : si offline au démarrage, émet PremiumStatus.free.
  @override
  Stream<PremiumStatus> get statusStream async* {
    try {
      yield await _remote.getCurrentStatus();
    } catch (_) {
      yield PremiumStatus.free;
    }
    yield* _remote.statusStream;
  }

  @override
  Future<Either<Failure, PremiumStatus>> getCurrentStatus() async {
    try {
      return Right(await _remote.getCurrentStatus());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PremiumStatus>> purchaseProduct(
      String productId) async {
    try {
      return Right(await _remote.purchaseProduct(productId));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PremiumStatus>> restorePurchases() async {
    try {
      return Right(await _remote.restorePurchases());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
