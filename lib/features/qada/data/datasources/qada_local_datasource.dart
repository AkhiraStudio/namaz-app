import 'package:hive/hive.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/qada_debt_model.dart';
import '../models/qada_record_model.dart';

abstract class QadaLocalDataSource {
  Future<QadaDebtModel?> getQadaDebt();
  Future<void> saveQadaDebt(QadaDebtModel model);
  Future<void> saveQadaRecord(QadaRecordModel model);
  Future<void> deleteLastTodayRecord(int prayerNameIndex);
  Future<List<QadaRecordModel>> getAllRecords();
  Future<List<QadaRecordModel>> getTodayRecords();

  // Pending recent missed prayers (flux récent)
  Map<String, String> getAllPendingMissed();
  Future<void> addPendingMissed(String key, String value);
  Future<void> removePendingMissed(String key);
}

class QadaLocalDataSourceImpl implements QadaLocalDataSource {
  Box<QadaDebtModel> get _debtBox =>
      Hive.box<QadaDebtModel>(HiveBoxNames.qadaDebt);
  Box<QadaRecordModel> get _recordsBox =>
      Hive.box<QadaRecordModel>(HiveBoxNames.qadaRecords);
  Box<String> get _pendingBox =>
      Hive.box<String>(HiveBoxNames.pendingRecentMissed);

  @override
  Future<QadaDebtModel?> getQadaDebt() async {
    try {
      return _debtBox.get('debt');
    } catch (e) {
      throw CacheException(message: 'Erreur lecture dette : $e');
    }
  }

  @override
  Future<void> saveQadaDebt(QadaDebtModel model) async {
    try {
      await _debtBox.put('debt', model);
    } catch (e) {
      throw CacheException(message: 'Erreur sauvegarde dette : $e');
    }
  }

  @override
  Future<void> saveQadaRecord(QadaRecordModel model) async {
    try {
      await _recordsBox.put(model.id, model);
    } catch (e) {
      throw CacheException(message: 'Erreur sauvegarde rattrapage : $e');
    }
  }

  @override
  Future<void> deleteLastTodayRecord(int prayerNameIndex) async {
    try {
      final today = DateTime.now();
      final todayRecords = _recordsBox.values.where((r) {
        final d = DateTime.fromMillisecondsSinceEpoch(r.performedAtMs);
        return d.year == today.year &&
            d.month == today.month &&
            d.day == today.day &&
            r.prayerNameIndex == prayerNameIndex;
      }).toList();
      if (todayRecords.isEmpty) return;
      // Supprime le plus récent
      todayRecords.sort((a, b) => b.performedAtMs.compareTo(a.performedAtMs));
      await _recordsBox.delete(todayRecords.first.id);
    } catch (e) {
      throw CacheException(message: 'Erreur suppression rattrapage : $e');
    }
  }

  @override
  Future<List<QadaRecordModel>> getAllRecords() async {
    try {
      return _recordsBox.values.toList();
    } catch (e) {
      throw CacheException(message: 'Erreur lecture rattrapages : $e');
    }
  }

  @override
  Future<List<QadaRecordModel>> getTodayRecords() async {
    try {
      final today = DateTime.now();
      return _recordsBox.values.where((r) {
        final d = DateTime.fromMillisecondsSinceEpoch(r.performedAtMs);
        return d.year == today.year &&
            d.month == today.month &&
            d.day == today.day;
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Erreur lecture rattrapages du jour : $e');
    }
  }

  @override
  Map<String, String> getAllPendingMissed() {
    try {
      return {
        for (final k in _pendingBox.keys.cast<String>())
          k: _pendingBox.get(k)!,
      };
    } catch (e) {
      throw CacheException(message: 'Erreur lecture prières manquées : $e');
    }
  }

  @override
  Future<void> addPendingMissed(String key, String value) async {
    try {
      await _pendingBox.put(key, value);
    } catch (e) {
      throw CacheException(message: 'Erreur ajout prière manquée : $e');
    }
  }

  @override
  Future<void> removePendingMissed(String key) async {
    try {
      await _pendingBox.delete(key);
    } catch (e) {
      throw CacheException(message: 'Erreur suppression prière manquée : $e');
    }
  }
}
