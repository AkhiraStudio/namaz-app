import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/qada_debt.dart';
import '../repositories/qada_repository.dart';

class CalculateQadaDebtParams {
  final DateTime stopDate;
  final DateTime resumeDate;
  final int mensCycleDays;
  final int mensDurationDays;
  final bool isFemale;
  // Quand plusieurs périodes sont cumulées, on passe le total déjà calculé.
  final int? overrideTotalDays;
  final int? overrideMensDays;

  const CalculateQadaDebtParams({
    required this.stopDate,
    required this.resumeDate,
    required this.isFemale,
    this.mensCycleDays = 28,
    this.mensDurationDays = 7,
    this.overrideTotalDays,
    this.overrideMensDays,
  });
}

class CalculateQadaDebtUseCase {
  final QadaRepository _repository;
  const CalculateQadaDebtUseCase(this._repository);

  Future<Either<Failure, QadaDebt>> call(CalculateQadaDebtParams params) async {
    final int totalDays;
    final int mensDaysDeducted;

    if (params.overrideTotalDays != null) {
      // Plusieurs périodes déjà cumulées par le formulaire
      totalDays = params.overrideTotalDays!;
      mensDaysDeducted = params.overrideMensDays ?? 0;
    } else {
      totalDays = params.resumeDate.difference(params.stopDate).inDays.abs();
      if (params.isFemale && params.mensCycleDays > 0) {
        final cycles = totalDays / params.mensCycleDays;
        mensDaysDeducted = (cycles * params.mensDurationDays).round();
      } else {
        mensDaysDeducted = 0;
      }
    }

    final effectiveDays = (totalDays - mensDaysDeducted).clamp(0, totalDays);

    final debt = QadaDebt(
      practiceStopDate: params.stopDate,
      practiceResumeDate: params.resumeDate,
      mensDaysDeducted: mensDaysDeducted,
      totalDaysOwed: effectiveDays,
    );

    final result = await _repository.saveQadaDebt(debt);
    return result.fold(Left.new, (_) => Right(debt));
  }
}
