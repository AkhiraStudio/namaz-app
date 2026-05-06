import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/premium_status.dart';
import '../repositories/premium_repository.dart';

class RestorePurchasesUseCase {
  final PremiumRepository _repo;
  RestorePurchasesUseCase(this._repo);

  Future<Either<Failure, PremiumStatus>> call() => _repo.restorePurchases();
}
