import 'package:hive/hive.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../domain/entities/prayer_time.dart';

part 'prayer_time_model.g.dart';

@HiveType(typeId: HiveTypeIds.prayerTimeModel)
class PrayerTimeModel extends HiveObject {
  @HiveField(0) late String dateKey; // 'yyyy-MM-dd'
  @HiveField(1) late int fajrMs;
  @HiveField(2) late int sunriseMs;
  @HiveField(3) late int dhuhrMs;
  @HiveField(4) late int asrMs;
  @HiveField(5) late int maghribMs;
  @HiveField(6) late int ishaMs;

  PrayerTimeModel({
    required this.dateKey,
    required this.fajrMs,
    required this.sunriseMs,
    required this.dhuhrMs,
    required this.asrMs,
    required this.maghribMs,
    required this.ishaMs,
  });

  /// Construit depuis la réponse JSON Aladhan.
  factory PrayerTimeModel.fromAladhan(
      Map<String, dynamic> timings, DateTime date) {
    DateTime parseTime(String t) {
      final parts = t.split(':');
      return DateTime(
        date.year, date.month, date.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );
    }

    return PrayerTimeModel(
      dateKey:
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      fajrMs: parseTime(timings['Fajr'] as String).millisecondsSinceEpoch,
      sunriseMs: parseTime(timings['Sunrise'] as String).millisecondsSinceEpoch,
      dhuhrMs: parseTime(timings['Dhuhr'] as String).millisecondsSinceEpoch,
      asrMs: parseTime(timings['Asr'] as String).millisecondsSinceEpoch,
      maghribMs: parseTime(timings['Maghrib'] as String).millisecondsSinceEpoch,
      ishaMs: parseTime(timings['Isha'] as String).millisecondsSinceEpoch,
    );
  }

  PrayerTime toEntity() {
    final date = DateTime.fromMillisecondsSinceEpoch(fajrMs);
    return PrayerTime(
      date: DateTime(date.year, date.month, date.day),
      fajr: DateTime.fromMillisecondsSinceEpoch(fajrMs),
      sunrise: DateTime.fromMillisecondsSinceEpoch(sunriseMs),
      dhuhr: DateTime.fromMillisecondsSinceEpoch(dhuhrMs),
      asr: DateTime.fromMillisecondsSinceEpoch(asrMs),
      maghrib: DateTime.fromMillisecondsSinceEpoch(maghribMs),
      isha: DateTime.fromMillisecondsSinceEpoch(ishaMs),
    );
  }
}
