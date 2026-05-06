import 'package:hive_flutter/hive_flutter.dart';
import '../constants/hive_keys.dart';

// Adapters générés par build_runner
import '../../features/onboarding/data/models/user_profile_model.dart';
import '../../features/prayer/data/models/prayer_time_model.dart';
import '../../features/prayer/data/models/prayer_record_model.dart';
import '../../features/qada/data/models/qada_debt_model.dart';
import '../../features/qada/data/models/qada_record_model.dart';
import '../../features/settings/data/models/settings_model.dart';

/// Initialise Hive, enregistre les TypeAdapters et ouvre toutes les boîtes.
class HiveService {
  HiveService._();

  /// À appeler avant runApp(), après WidgetsFlutterBinding.ensureInitialized().
  static Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();
    await _openBoxes();
  }

  /// Enregistre les 6 TypeAdapters générés par build_runner.
  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTypeIds.userProfileModel)) {
      Hive.registerAdapter(UserProfileModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.prayerTimeModel)) {
      Hive.registerAdapter(PrayerTimeModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.prayerRecordModel)) {
      Hive.registerAdapter(PrayerRecordModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.qadaDebtModel)) {
      Hive.registerAdapter(QadaDebtModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.qadaRecordModel)) {
      Hive.registerAdapter(QadaRecordModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.settingsModel)) {
      Hive.registerAdapter(SettingsModelAdapter());
    }
  }

  static Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox<UserProfileModel>(HiveBoxNames.userProfile),
      Hive.openBox<PrayerTimeModel>(HiveBoxNames.prayerTimes),
      Hive.openBox<PrayerRecordModel>(HiveBoxNames.prayerRecords),
      Hive.openBox<QadaDebtModel>(HiveBoxNames.qadaDebt),
      Hive.openBox<QadaRecordModel>(HiveBoxNames.qadaRecords),
      Hive.openBox<SettingsModel>(HiveBoxNames.settings),
      Hive.openBox<String>(HiveBoxNames.pendingRecentMissed),
      Hive.openBox<bool>(HiveBoxNames.sunnahRecords),
      Hive.openBox<int>(HiveBoxNames.adhkarProgress),
      Hive.openBox<bool>(HiveBoxNames.adhkarCompletions),
      Hive.openBox<bool>(HiveBoxNames.tasbeehCompletions),
    ]);
  }

  /// Ferme toutes les boîtes proprement.
  static Future<void> close() async {
    await Hive.close();
  }

  /// Efface les données utilisateur (prières + qada) sans toucher au profil.
  static Future<void> clearUserData() async {
    await Future.wait([
      Hive.box<PrayerRecordModel>(HiveBoxNames.prayerRecords).clear(),
      Hive.box<QadaDebtModel>(HiveBoxNames.qadaDebt).clear(),
      Hive.box<QadaRecordModel>(HiveBoxNames.qadaRecords).clear(),
      Hive.box<bool>(HiveBoxNames.sunnahRecords).clear(),
    ]);
  }
}
