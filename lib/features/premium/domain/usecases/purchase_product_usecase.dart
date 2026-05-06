import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/premium_status.dart';
import '../repositories/premium_repository.dart';

class PurchaseProductUseCase {
  final PremiumRepository _repo;
  PurchaseProductUseCase(this._repo);

  Future<Either<Failure, PremiumStatus>> call(String productId) =>
      _repo.purchaseProduct(productId);
}
