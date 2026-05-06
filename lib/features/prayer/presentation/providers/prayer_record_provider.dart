import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/prayer_record.dart';
import '../../domain/usecases/record_prayer_status_usecase.dart';
import 'prayer_times_provider.dart';
import 'prayer_statistics_provider.dart';
import '../../../qada/presentation/providers/qada_provider.dart';

final recordPrayerUseCaseProvider = Provider((ref) {
  return RecordPrayerStatusUseCase(ref.read(prayerRepositoryProvider));
});

/// State : map PrayerName → PrayerRecord pour le jour courant.
/// AsyncNotifier pour charger les enregistrements Hive au démarrage.
class PrayerRecordNotifier
    extends AsyncNotifier<Map<PrayerName, PrayerRecord>> {
  @override
  Future<Map<PrayerName, PrayerRecord>> build() async {
    // Hydrate depuis Hive : on récupère les prières déjà enregistrées aujourd'hui.
    final repo = ref.read(prayerRepositoryProvider);
    final result = await repo.getDayRecords(DateTime.now());
    return result.fold(
      (_) => {},
      (records) => {for (final r in records) r.prayerName: r},
    );
  }

  Future<void> recordPrayer(PrayerName name, PrayerStatus status) async {
    const uuid = Uuid();
    final now = DateTime.now();
    final record = PrayerRecord(
      id: uuid.v4(),
      date: now,
      prayerName: name,
      status: status,
      recordedAt: now,
    );

    final useCase = ref.read(recordPrayerUseCaseProvider);
    final result = await useCase(record);

    result.fold(
      (failure) => state =
          AsyncError(Exception(failure.message), StackTrace.current),
      (_) {
        final current = state.valueOrNull ?? {};
        state = AsyncData({...current, name: record});

        // Sync pending missed flux
        final dateKey =
            '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
        final pendingKey = 'missed_${name.index}_$dateKey';
        final qadaRepo = ref.read(qadaRepositoryProvider);
        if (status == PrayerStatus.missed) {
          qadaRepo.addPendingMissedPrayer(pendingKey, name, now);
        } else {
          // Menstruation and other non-missed statuses remove from pending
          qadaRepo.removePendingMissedPrayerByKey(pendingKey);
        }
        ref.invalidate(pendingRecentMissedProvider);
        ref.invalidate(prayerStatisticsProvider);
        ref.invalidate(homeStreakProvider);
        ref.invalidate(weeklyPrayerDotsProvider);
      },
    );
  }

  /// Retourne true si la prière a été enregistrée aujourd'hui.
  bool isPrayed(PrayerName name) =>
      state.valueOrNull?.containsKey(name) ?? false;

  /// Statut enregistré pour une prière (null si non enregistrée).
  PrayerStatus? statusFor(PrayerName name) =>
      state.valueOrNull?[name]?.status;
}

final prayerRecordProvider =
    AsyncNotifierProvider<PrayerRecordNotifier, Map<PrayerName, PrayerRecord>>(
  PrayerRecordNotifier.new,
);
