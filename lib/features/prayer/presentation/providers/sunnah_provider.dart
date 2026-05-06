import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/sunnah_local_datasource.dart';
import '../../data/repositories_impl/sunnah_repository_impl.dart';
import '../../domain/entities/sunnah_prayer.dart';
import '../../domain/repositories/sunnah_repository.dart';
import '../../domain/usecases/get_today_sunnah_usecase.dart';
import '../../domain/usecases/toggle_sunnah_usecase.dart';

// ── Dependencies ──────────────────────────────────────────────────────────────

final sunnahLocalDataSourceProvider = Provider<SunnahLocalDataSource>(
  (_) => SunnahLocalDataSourceImpl(),
);

final sunnahRepositoryProvider = Provider<SunnahRepository>((ref) =>
    SunnahRepositoryImpl(
      local: ref.read(sunnahLocalDataSourceProvider),
    ));

final getTodaySunnahUseCaseProvider = Provider(
  (ref) => GetTodaySunnahUseCase(ref.read(sunnahRepositoryProvider)),
);

final toggleSunnahUseCaseProvider = Provider(
  (ref) => ToggleSunnahUseCase(ref.read(sunnahRepositoryProvider)),
);

// ── Notifier ──────────────────────────────────────────────────────────────────

class SunnahNotifier extends Notifier<Set<SunnahPrayer>> {
  @override
  Set<SunnahPrayer> build() {
    final result = ref.read(getTodaySunnahUseCaseProvider).call();
    return result.fold((_) => {}, (prayers) => prayers);
  }

  Future<void> toggle(SunnahPrayer prayer) async {
    final isDone = !state.contains(prayer);
    // Mise à jour optimiste
    state = isDone
        ? {...state, prayer}
        : (Set.from(state)..remove(prayer));
    final result =
        await ref.read(toggleSunnahUseCaseProvider).call(prayer, isDone);
    // Rollback en cas d'erreur
    result.fold(
      (_) => state = isDone
          ? (Set.from(state)..remove(prayer))
          : {...state, prayer},
      (_) {},
    );
  }
}

final sunnahProvider =
    NotifierProvider<SunnahNotifier, Set<SunnahPrayer>>(SunnahNotifier.new);
