import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/prayer_time.dart';
import '../../../../core/utils/prayer_time_utils.dart';
import 'prayer_times_provider.dart';

/// Représente la prière courante et son état de fenêtre.
class CurrentPrayerState {
  final String prayerName;
  final DateTime start;
  final DateTime end;
  final PrayerWindowStatus windowStatus;
  final double progress; // 0.0 → 1.0

  const CurrentPrayerState({
    required this.prayerName,
    required this.start,
    required this.end,
    required this.windowStatus,
    required this.progress,
  });
}

/// Calcule la prière courante depuis les horaires du jour.
CurrentPrayerState? _computeCurrentPrayer(PrayerTime times, DateTime now) {
  final prayers = [
    MapEntry('Fajr', times.fajr),
    MapEntry('Dhuhr', times.dhuhr),
    MapEntry('Asr', times.asr),
    MapEntry('Maghrib', times.maghrib),
    MapEntry('Isha', times.isha),
  ];

  for (int i = 0; i < prayers.length; i++) {
    final start = prayers[i].value;
    final end = prayers[i].key == 'Fajr'
        ? times.sunrise
        : i < prayers.length - 1
            ? prayers[i + 1].value
            : times.isha.add(const Duration(hours: 3));

    if (now.isAfter(start) && now.isBefore(end)) {
      final status = PrayerTimeUtils.getWindowStatus(
        now: now,
        prayerStart: start,
        nextPrayerStart: end,
      );
      final progress = PrayerTimeUtils.getPrayerProgress(
        now: now,
        prayerStart: start,
        nextPrayerStart: end,
      );
      return CurrentPrayerState(
        prayerName: prayers[i].key,
        start: start,
        end: end,
        windowStatus: status,
        progress: progress,
      );
    }
  }
  return null;
}

/// Stream qui se met à jour toutes les secondes.
final currentPrayerProvider =
    StreamProvider.autoDispose<CurrentPrayerState?>((ref) async* {
  final timesAsync = ref.watch(prayerTimesProvider);

  await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
    final times = timesAsync.valueOrNull;
    if (times == null) {
      yield null;
    } else {
      yield _computeCurrentPrayer(times, DateTime.now());
    }
  }
});

/// Provider de la prochaine prière (nom + heure).
final nextPrayerProvider = Provider<MapEntry<String, DateTime>?>((ref) {
  final timesAsync = ref.watch(prayerTimesProvider);
  final times = timesAsync.valueOrNull;
  if (times == null) return null;

  final now = DateTime.now();
  final prayers = times.orderedPrayers;
  for (final entry in prayers) {
    if (entry.value.isAfter(now)) return entry;
  }
  return null;
});

/// Provider de la prière précédente (dernière passée, nom + heure).
final previousPrayerProvider = Provider<MapEntry<String, DateTime>?>((ref) {
  final timesAsync = ref.watch(prayerTimesProvider);
  final times = timesAsync.valueOrNull;
  if (times == null) return null;

  final now = DateTime.now();
  final prayers = times.orderedPrayers;
  MapEntry<String, DateTime>? previous;
  for (final entry in prayers) {
    if (entry.value.isBefore(now)) {
      previous = entry;
    }
  }
  return previous;
});
