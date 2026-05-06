import 'package:hive/hive.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/extensions/datetime_extensions.dart';
import '../../domain/entities/sunnah_prayer.dart';

abstract class SunnahLocalDataSource {
  /// Retourne les prières surérogatoires accomplies aujourd'hui.
  Set<SunnahPrayer> getTodayRecords();

  /// Enregistre ou supprime une prière surérogatoire.
  Future<void> setRecord(String key, bool value);
  Future<void> deleteRecord(String key);

  /// Retourne les prières par jour entre [from] et [to] inclus.
  Map<String, Set<SunnahPrayer>> getRecordsBetween(DateTime from, DateTime to);
}

class SunnahLocalDataSourceImpl implements SunnahLocalDataSource {
  Box<bool> get _box => Hive.box<bool>(HiveBoxNames.sunnahRecords);

  @override
  Set<SunnahPrayer> getTodayRecords() {
    try {
      final prefix = DateTime.now().dateKey;
      return SunnahPrayer.values
          .where((p) => _box.get('$prefix:${p.index}') == true)
          .toSet();
    } catch (e) {
      throw CacheException(message: 'Erreur lecture sunnah : $e');
    }
  }

  @override
  Future<void> setRecord(String key, bool value) async {
    try {
      await _box.put(key, value);
    } catch (e) {
      throw CacheException(message: 'Erreur écriture sunnah : $e');
    }
  }

  @override
  Future<void> deleteRecord(String key) async {
    try {
      await _box.delete(key);
    } catch (e) {
      throw CacheException(message: 'Erreur suppression sunnah : $e');
    }
  }

  @override
  Map<String, Set<SunnahPrayer>> getRecordsBetween(DateTime from, DateTime to) {
    try {
      final result = <String, Set<SunnahPrayer>>{};
      final today = DateTime.now();
      var cursor = DateTime(from.year, from.month, from.day);
      final endDay = DateTime(to.year, to.month, to.day);

      while (!cursor.isAfter(endDay) && !cursor.isAfter(today)) {
        final prefix = cursor.dateKey;
        final done = SunnahPrayer.values
            .where((p) => _box.get('$prefix:${p.index}') == true)
            .toSet();
        if (done.isNotEmpty) result[prefix] = done;
        cursor = cursor.add(const Duration(days: 1));
      }
      return result;
    } catch (e) {
      throw CacheException(message: 'Erreur lecture stats sunnah : $e');
    }
  }
}
