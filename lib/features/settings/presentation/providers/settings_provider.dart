import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories_impl/settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/update_language_usecase.dart';
import '../../domain/usecases/toggle_traveler_mode_usecase.dart';
import '../../domain/usecases/update_menses_cycle_usecase.dart';
import '../../domain/usecases/reset_prayer_data_usecase.dart';
import '../../../prayer/presentation/providers/prayer_times_provider.dart';

// ── Dependencies ──────────────────────────────────────────────────────────────

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>(
  (_) => SettingsLocalDataSourceImpl(),
);

final settingsRepositoryProvider = Provider((ref) => SettingsRepositoryImpl(
      local: ref.read(settingsLocalDataSourceProvider),
    ));

// ── Notifier ──────────────────────────────────────────────────────────────────

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();

  Future<void> load() async {
    final useCase = GetSettingsUseCase(ref.read(settingsRepositoryProvider));
    final result = await useCase();
    result.fold((_) {}, (settings) => state = settings);
    ref.read(settingsLoadedProvider.notifier).state = true;
  }

  Future<void> updateLanguage(String code) async {
    final useCase =
        UpdateLanguageUseCase(ref.read(settingsRepositoryProvider));
    final result = await useCase(code);
    result.fold((_) {}, (_) => state = state.copyWith(languageCode: code));
  }

  Future<void> toggleTravelerMode(bool enabled) async {
    final useCase =
        ToggleTravelerModeUseCase(ref.read(settingsRepositoryProvider));
    final result = await useCase(enabled);
    result.fold((_) {}, (_) => state = state.copyWith(travelerMode: enabled));
  }

  Future<void> updateMensesCycle(
      {required int cycleDays, required int durationDays}) async {
    final useCase =
        UpdateMensesCycleUseCase(ref.read(settingsRepositoryProvider));
    final result = await useCase(
        cycleDays: cycleDays, durationDays: durationDays);
    result.fold(
      (_) {},
      (_) => state = state.copyWith(
          mensCycleDays: cycleDays, mensDurationDays: durationDays),
    );
  }

  Future<void> updateTimeFormat(TimeFormat format) async {
    final updated = state.copyWith(timeFormat: format);
    state = updated;
    await ref.read(settingsRepositoryProvider).saveSettings(updated);
  }

  Future<void> toggleDarkMode(bool enabled) async {
    final updated = state.copyWith(darkMode: enabled);
    state = updated;
    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveSettings(updated);
  }

  Future<void> toggleSunnahPrayers(bool enabled) async {
    final updated = state.copyWith(showSunnahPrayers: enabled);
    state = updated;
    await ref.read(settingsRepositoryProvider).saveSettings(updated);
  }

  Future<void> toggleShowStreak(bool enabled) async {
    final updated = state.copyWith(showStreak: enabled);
    state = updated;
    await ref.read(settingsRepositoryProvider).saveSettings(updated);
  }

  Future<void> updatePrayerAlertType(PrayerAlertType type) async {
    final updated = state.copyWith(prayerAlertType: type);
    state = updated;
    await ref.read(settingsRepositoryProvider).saveSettings(updated);
  }

  Future<void> togglePrayerNotif(bool enabled) async {
    final updated = state.copyWith(prayerNotifEnabled: enabled);
    state = updated;
    await ref.read(settingsRepositoryProvider).saveSettings(updated);
  }

  Future<void> toggleQadaNotif(bool enabled) async {
    final updated = state.copyWith(qadaNotifEnabled: enabled);
    state = updated;
    await ref.read(settingsRepositoryProvider).saveSettings(updated);
  }

  Future<void> updateQadaNotifHours({
    required int morningHour,
    required int eveningHour,
  }) async {
    final updated = state.copyWith(
      qadaMorningHour: morningHour,
      qadaEveningHour: eveningHour,
    );
    state = updated;
    await ref.read(settingsRepositoryProvider).saveSettings(updated);
  }

  Future<void> updateCalculationMethod(int methodIndex) async {
    final updated = state.copyWith(calculationMethod: methodIndex);
    state = updated;
    await ref.read(settingsRepositoryProvider).saveSettings(updated);
    ref.invalidate(prayerTimesProvider);
  }

  Future<void> updateGlobalOffset(int minutes) async {
    final updated = state.copyWith(globalOffsetMinutes: minutes);
    state = updated;
    await ref.read(settingsRepositoryProvider).saveSettings(updated);
  }

  Future<void> updatePrayerOffset({
    int? fajr,
    int? dhuhr,
    int? asr,
    int? maghrib,
    int? isha,
  }) async {
    final updated = state.copyWith(
      fajrOffsetMinutes: fajr,
      dhuhrOffsetMinutes: dhuhr,
      asrOffsetMinutes: asr,
      maghribOffsetMinutes: maghrib,
      ishaOffsetMinutes: isha,
    );
    state = updated;
    await ref.read(settingsRepositoryProvider).saveSettings(updated);
  }

  Future<void> resetPrayerData() async {
    final useCase =
        ResetPrayerDataUseCase(ref.read(settingsRepositoryProvider));
    await useCase();
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

/// Vrai une fois que load() a terminé de lire Hive.
final settingsLoadedProvider = StateProvider<bool>((_) => false);
