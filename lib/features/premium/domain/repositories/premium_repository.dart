import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/premium_status.dart';

abstract class PremiumRepository {
  Stream<PremiumStatus> get statusStream;
  Future<Either<Failure, PremiumStatus>> getCurrentStatus();
  Future<Either<Failure, PremiumStatus>> purchaseProduct(String productId);
  Future<Either<Failure, PremiumStatus>> restorePurchases();
}
