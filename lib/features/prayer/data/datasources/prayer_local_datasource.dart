import 'package:hive/hive.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/prayer_time_model.dart';
import '../models/prayer_record_model.dart';

abstract class PrayerLocalDataSource {
  Future<PrayerTimeModel?> getCachedPrayerTimes(String dateKey);
  Future<void> cachePrayerTimes(PrayerTimeModel model);
  Future<void> savePrayerRecord(PrayerRecordModel model);
  Future<List<PrayerRecordModel>> getDayRecords(String dateKey);
  Future<List<PrayerRecordModel>> getRecordsBetween(String fromKey, String toKey);
  Future<bool> hasAnyRecord();
}

class PrayerLocalDataSourceImpl implements PrayerLocalDataSource {
  Box<PrayerTimeModel> get _timesBox =>
      Hive.box<PrayerTimeModel>(HiveBoxNames.prayerTimes);
  Box<PrayerRecordModel> get _recordsBox =>
      Hive.box<PrayerRecordModel>(HiveBoxNames.prayerRecords);

  @override
  Future<PrayerTimeModel?> getCachedPrayerTimes(String dateKey) async {
    try {
      return _timesBox.get(dateKey);
    } catch (e) {
      throw CacheException(message: 'Erreur lecture horaires : $e');
    }
  }

  @override
  Future<void> cachePrayerTimes(PrayerTimeModel model) async {
    try {
      await _timesBox.put(model.dateKey, model);
    } catch (e) {
      throw CacheException(message: 'Erreur cache horaires : $e');
    }
  }

  @override
  Future<void> savePrayerRecord(PrayerRecordModel model) async {
    try {
      await _recordsBox.put(model.id, model);
    } catch (e) {
      throw CacheException(message: 'Erreur sauvegarde prière : $e');
    }
  }

  @override
  Future<List<PrayerRecordModel>> getDayRecords(String dateKey) async {
    try {
      return _recordsBox.values.where((r) {
        final d = DateTime.fromMillisecondsSinceEpoch(r.dateMs);
        final key =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        return key == dateKey;
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Erreur lecture enregistrements : $e');
    }
  }

  @override
  Future<bool> hasAnyRecord() async => _recordsBox.isNotEmpty;

  @override
  Future<List<PrayerRecordModel>> getRecordsBetween(
      String fromKey, String toKey) async {
    try {
      return _recordsBox.values.where((r) {
        final d = DateTime.fromMillisecondsSinceEpoch(r.dateMs);
        final key =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        return key.compareTo(fromKey) >= 0 && key.compareTo(toKey) <= 0;
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Erreur lecture historique : $e');
    }
  }
}
