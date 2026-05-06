import 'package:hive/hive.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../domain/entities/qada_record.dart';
import '../../../prayer/domain/entities/prayer_record.dart';

part 'qada_record_model.g.dart';

@HiveType(typeId: HiveTypeIds.qadaRecordModel)
class QadaRecordModel extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late int prayerNameIndex;
  @HiveField(2) late int performedAtMs;
  @HiveField(3) late bool isFromRecentMissed;

  QadaRecordModel({
    required this.id,
    required this.prayerNameIndex,
    required this.performedAtMs,
    required this.isFromRecentMissed,
  });

  factory QadaRecordModel.fromEntity(QadaRecord e) => QadaRecordModel(
        id: e.id,
        prayerNameIndex: e.prayerName.index,
        performedAtMs: e.performedAt.millisecondsSinceEpoch,
        isFromRecentMissed: e.isFromRecentMissed,
      );

  static T _safeEnum<T>(List<T> values, int index, T fallback) =>
      (index >= 0 && index < values.length) ? values[index] : fallback;

  QadaRecord toEntity() => QadaRecord(
        id: id,
        prayerName: _safeEnum(PrayerName.values, prayerNameIndex, PrayerName.fajr),
        performedAt: DateTime.fromMillisecondsSinceEpoch(performedAtMs),
        isFromRecentMissed: isFromRecentMissed,
      );
}
