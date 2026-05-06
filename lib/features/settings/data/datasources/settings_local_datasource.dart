import 'package:hive/hive.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/settings_model.dart';
import '../../domain/entities/app_settings.dart';

abstract class SettingsLocalDataSource {
  Future<SettingsModel> getSettings();
  Future<void> saveSettings(SettingsModel model);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  Box<SettingsModel> get _box =>
      Hive.box<SettingsModel>(HiveBoxNames.settings);

  @override
  Future<SettingsModel> getSettings() async {
    try {
      return _box.get('settings') ?? SettingsModel.fromEntity(const AppSettings());
    } catch (e) {
      throw CacheException(message: 'Erreur lecture paramètres : $e');
    }
  }

  @override
  Future<void> saveSettings(SettingsModel model) async {
    try {
      await _box.put('settings', model);
    } catch (e) {
      throw CacheException(message: 'Erreur sauvegarde paramètres : $e');
    }
  }
}
