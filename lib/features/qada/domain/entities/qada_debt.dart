import 'package:equatable/equatable.dart';

/// Stock initial de la dette de prières à rattraper.
class QadaDebt extends Equatable {
  final DateTime practiceStopDate;   // Date d'arrêt de la pratique
  final DateTime practiceResumeDate; // Date de reprise
  final int mensDaysDeducted;        // Jours de règles déduits
  final int totalDaysOwed;           // Jours calculés (après déduction)
  final DateTime? targetCompletionDate; // Date objectif de fin

  const QadaDebt({
    required this.practiceStopDate,
    required this.practiceResumeDate,
    required this.mensDaysDeducted,
    required this.totalDaysOwed,
    this.targetCompletionDate,
  });

  /// Nombre total de prières à rattraper (5 par jour).
  int get totalPrayersOwed => totalDaysOwed * 5;

  QadaDebt copyWith({DateTime? targetCompletionDate}) => QadaDebt(
        practiceStopDate: practiceStopDate,
        practiceResumeDate: practiceResumeDate,
        mensDaysDeducted: mensDaysDeducted,
        totalDaysOwed: totalDaysOwed,
        targetCompletionDate: targetCompletionDate ?? this.targetCompletionDate,
      );

  @override
  List<Object?> get props => [
        practiceStopDate, practiceResumeDate,
        mensDaysDeducted, totalDaysOwed, targetCompletionDate,
      ];
}
