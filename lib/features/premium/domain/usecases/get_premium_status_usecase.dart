import '../entities/premium_status.dart';
import '../repositories/premium_repository.dart';

class GetPremiumStatusUseCase {
  final PremiumRepository _repo;
  GetPremiumStatusUseCase(this._repo);

  Stream<PremiumStatus> call() => _repo.statusStream;
}
