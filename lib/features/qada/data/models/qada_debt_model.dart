import 'package:hive/hive.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../domain/entities/qada_debt.dart';

part 'qada_debt_model.g.dart';

@HiveType(typeId: HiveTypeIds.qadaDebtModel)
class QadaDebtModel extends HiveObject {
  @HiveField(0) late int stopDateMs;
  @HiveField(1) late int resumeDateMs;
  @HiveField(2) late int mensDaysDeducted;
  @HiveField(3) late int totalDaysOwed;
  @HiveField(4) int? targetDateMs;

  QadaDebtModel({
    required this.stopDateMs,
    required this.resumeDateMs,
    required this.mensDaysDeducted,
    required this.totalDaysOwed,
    this.targetDateMs,
  });

  factory QadaDebtModel.fromEntity(QadaDebt e) => QadaDebtModel(
        stopDateMs: e.practiceStopDate.millisecondsSinceEpoch,
        resumeDateMs: e.practiceResumeDate.millisecondsSinceEpoch,
        mensDaysDeducted: e.mensDaysDeducted,
        totalDaysOwed: e.totalDaysOwed,
        targetDateMs: e.targetCompletionDate?.millisecondsSinceEpoch,
      );

  QadaDebt toEntity() => QadaDebt(
        practiceStopDate: DateTime.fromMillisecondsSinceEpoch(stopDateMs),
        practiceResumeDate: DateTime.fromMillisecondsSinceEpoch(resumeDateMs),
        mensDaysDeducted: mensDaysDeducted,
        totalDaysOwed: totalDaysOwed,
        targetCompletionDate: targetDateMs != null
            ? DateTime.fromMillisecondsSinceEpoch(targetDateMs!)
            : null,
      );
}
