import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../data/adhkar_data.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class AdhkarProgressState {
  final List<int> counts; // counts[i] = number of taps for invocation i
  final int total;
  final List<AdhkarItem> adhkar;

  const AdhkarProgressState({
    required this.counts,
    required this.total,
    required this.adhkar,
  });

  int get currentIndex {
    for (int i = 0; i < adhkar.length; i++) {
      if (counts[i] < adhkar[i].repetitions) return i;
    }
    return adhkar.length; // all done
  }

  bool get isComplete => currentIndex >= total;

  double get progress => total == 0 ? 0 : currentIndex / total;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AdhkarProgressNotifier extends StateNotifier<AdhkarProgressState> {
  final String type; // 'morning' | 'evening' | 'sleep'

  AdhkarProgressNotifier(this.type)
      : super(_loadInitialState(type));

  static List<AdhkarItem> _adhkarFor(String type) => switch (type) {
        'morning' => morningAdhkar,
        'sleep' => sleepAdhkar,
        _ => eveningAdhkar,
      };

  static int _todayEpochDay() =>
      DateTime.now().millisecondsSinceEpoch ~/ 86400000;

  static AdhkarProgressState _loadInitialState(String type) {
    final adhkar = _adhkarFor(type);
    final box = Hive.box<int>(HiveBoxNames.adhkarProgress);
    final today = _todayEpochDay();
    final storedDay = box.get('${type}_date', defaultValue: -1)!;

    // Reset automatique au changement de jour
    if (storedDay != today) {
      for (int i = 0; i < adhkar.length; i++) {
        box.delete('${type}_$i');
      }
      box.put('${type}_date', today);
    }

    final counts = List<int>.generate(
      adhkar.length,
      (i) => box.get('${type}_$i', defaultValue: 0)!,
    );
    return AdhkarProgressState(counts: counts, total: adhkar.length, adhkar: adhkar);
  }

  void increment() {
    final adhkar = _adhkarFor(type);
    final idx = state.currentIndex;
    if (idx >= adhkar.length) return;

    final current = state.counts[idx];
    final max = adhkar[idx].repetitions;
    if (current >= max) return;

    final newCount = current + 1;
    final newCounts = List<int>.from(state.counts)..[idx] = newCount;

    Hive.box<int>(HiveBoxNames.adhkarProgress).put('${type}_$idx', newCount);
    final newState = AdhkarProgressState(counts: newCounts, total: state.total, adhkar: adhkar);
    state = newState;

    // Marque la completion du jour quand tous les adhkar sont faits
    if (newState.isComplete) {
      final today = _todayKey();
      Hive.box<bool>(HiveBoxNames.adhkarCompletions).put('${type}_$today', true);
    }
  }

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  void completeAt(int idx) {
    final adhkar = _adhkarFor(type);
    if (idx >= adhkar.length) return;
    final max = adhkar[idx].repetitions;
    final newCounts = List<int>.from(state.counts)..[idx] = max;
    Hive.box<int>(HiveBoxNames.adhkarProgress).put('${type}_$idx', max);
    final newState = AdhkarProgressState(counts: newCounts, total: state.total, adhkar: adhkar);
    state = newState;
    if (newState.isComplete) {
      final today = _todayKey();
      Hive.box<bool>(HiveBoxNames.adhkarCompletions).put('${type}_$today', true);
    }
  }

  void reset() {
    final adhkar = _adhkarFor(type);
    final box = Hive.box<int>(HiveBoxNames.adhkarProgress);
    for (int i = 0; i < adhkar.length; i++) {
      box.delete('${type}_$i');
    }
    state = AdhkarProgressState(
      counts: List.filled(adhkar.length, 0),
      total: adhkar.length,
      adhkar: adhkar,
    );
  }
}

// ── Provider (family by type) ─────────────────────────────────────────────────

final adhkarProgressProvider = StateNotifierProvider.family<
    AdhkarProgressNotifier, AdhkarProgressState, String>(
  (ref, type) => AdhkarProgressNotifier(type),
);
