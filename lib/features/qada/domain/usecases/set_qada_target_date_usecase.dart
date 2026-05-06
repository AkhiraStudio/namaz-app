import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/qada_repository.dart';

class SetQadaTargetDateUseCase {
  final QadaRepository _repository;
  const SetQadaTargetDateUseCase(this._repository);

  Future<Either<Failure, int>> call(DateTime targetDate) async {
    final debtResult = await _repository.getQadaDebt();
    return debtResult.fold(Left.new, (debt) async {
      if (debt == null) {
        return const Left(CacheFailure(message: 'Aucune dette définie'));
      }
      final updatedDebt = debt.copyWith(targetCompletionDate: targetDate);
      final saveResult = await _repository.saveQadaDebt(updatedDebt);
      return saveResult.fold(Left.new, (_) {
        final daysRemaining =
            targetDate.difference(DateTime.now()).inDays.clamp(1, 99999);
        final dailyTarget =
            (updatedDebt.totalPrayersOwed / daysRemaining).ceil();
        return Right(dailyTarget);
      });
    });
  }
}
