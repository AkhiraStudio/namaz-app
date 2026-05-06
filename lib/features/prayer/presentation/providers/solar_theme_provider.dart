import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/solar_theme.dart';
import 'prayer_times_provider.dart';

/// Tick toutes les minutes pour forcer la réévaluation de la phase solaire.
final _minuteTickProvider = StreamProvider.autoDispose<DateTime>((ref) {
  return Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now());
});

/// Phase solaire courante — se recalcule à chaque changement des horaires
/// ET toutes les minutes (pour les transitions Fajr → aube → midi etc.).
final solarPhaseProvider = Provider<SolarPhase>((ref) {
  ref.watch(_minuteTickProvider); // force re-évaluation toutes les minutes
  final timesAsync = ref.watch(prayerTimesProvider);
  final times = timesAsync.valueOrNull;
  if (times == null) return SolarPhase.morning;

  return computeSolarPhase(
    now: DateTime.now(),
    fajr: times.fajr,
    dhuhr: times.dhuhr,
    asr: times.asr,
    maghrib: times.maghrib,
    isha: times.isha,
  );
});

/// Données visuelles (couleurs, texte) de la phase solaire courante.
final solarThemeDataProvider = Provider<SolarThemeData>((ref) {
  final phase = ref.watch(solarPhaseProvider);
  return solarThemeMap[phase]!;
});
