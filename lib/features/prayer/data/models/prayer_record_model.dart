import 'package:hive/hive.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../domain/entities/prayer_record.dart';

part 'prayer_record_model.g.dart';

@HiveType(typeId: HiveTypeIds.prayerRecordModel)
class PrayerRecordModel extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late int dateMs;
  @HiveField(2) late int prayerNameIndex;
  @HiveField(3) late int statusIndex;
  @HiveField(4) int? recordedAtMs;

  PrayerRecordModel({
    required this.id,
    required this.dateMs,
    required this.prayerNameIndex,
    required this.statusIndex,
    this.recordedAtMs,
  });

  factory PrayerRecordModel.fromEntity(PrayerRecord entity) =>
      PrayerRecordModel(
        id: entity.id,
        dateMs: entity.date.millisecondsSinceEpoch,
        prayerNameIndex: entity.prayerName.index,
        statusIndex: entity.status.index,
        recordedAtMs: entity.recordedAt?.millisecondsSinceEpoch,
      );

  static T _safeEnum<T>(List<T> values, int index, T fallback) =>
      (index >= 0 && index < values.length) ? values[index] : fallback;

  PrayerRecord toEntity() => PrayerRecord(
        id: id,
        date: DateTime.fromMillisecondsSinceEpoch(dateMs),
        prayerName: _safeEnum(PrayerName.values, prayerNameIndex, PrayerName.fajr),
        status: _safeEnum(PrayerStatus.values, statusIndex, PrayerStatus.missed),
        recordedAt: recordedAtMs != null
            ? DateTime.fromMillisecondsSinceEpoch(recordedAtMs!)
            : null,
      );
}
