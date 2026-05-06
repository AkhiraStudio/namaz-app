import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/datasources/prayer_local_datasource.dart';
import '../../data/datasources/prayer_remote_datasource.dart';
import '../../data/repositories_impl/prayer_repository_impl.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/usecases/get_prayer_times_usecase.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/firestore_provider.dart';
import '../../../../features/settings/presentation/providers/settings_provider.dart';
import '../../../../features/onboarding/presentation/providers/profile_provider.dart';

// ── Infrastructure providers ──────────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(connectivity: Connectivity());
});

final prayerRemoteDataSourceProvider = Provider<PrayerRemoteDataSource>((ref) {
  return PrayerRemoteDataSourceImpl(dio: ref.read(apiClientProvider).dio);
});

final prayerLocalDataSourceProvider = Provider<PrayerLocalDataSource>((ref) {
  return PrayerLocalDataSourceImpl();
});

final prayerRepositoryProvider = Provider((ref) {
  return PrayerRepositoryImpl(
    remote: ref.read(prayerRemoteDataSourceProvider),
    local: ref.read(prayerLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    firestore: ref.read(firestoreServiceProvider),
  );
});

final getPrayerTimesUseCaseProvider = Provider((ref) {
  return GetPrayerTimesUseCase(ref.read(prayerRepositoryProvider));
});

// ── Location provider ─────────────────────────────────────────────────────────

final currentPositionProvider = FutureProvider<Position>((ref) {
  return ref.read(locationServiceProvider).getCurrentPosition();
});

// ── Prayer times notifier ─────────────────────────────────────────────────────

class PrayerTimesNotifier extends AsyncNotifier<PrayerTime> {
  @override
  Future<PrayerTime> build() async {
    final settings = ref.watch(settingsProvider);
    final profile = await ref.watch(profileProvider.future);
    final useCase = ref.read(getPrayerTimesUseCaseProvider);

    final double latitude;
    final double longitude;

    if (!settings.travelerMode &&
        profile?.mosqueLatitude != null &&
        profile?.mosqueLongitude != null) {
      // Coordonnées fixes de la mosquée choisie
      latitude = profile!.mosqueLatitude!;
      longitude = profile.mosqueLongitude!;
    } else {
      // GPS temps réel (mode voyageur ou pas de mosquée enregistrée)
      final position = await ref.watch(currentPositionProvider.future);
      latitude = position.latitude;
      longitude = position.longitude;
    }

    final result = await useCase(GetPrayerTimesParams(
      latitude: latitude,
      longitude: longitude,
      date: DateTime.now(),
      method: settings.calculationMethod,
    ));
    return result.fold(
      (failure) => throw Exception(failure.message),
      (times) => times.withOffsets(
        globalMinutes: settings.globalOffsetMinutes,
        fajrMinutes: settings.fajrOffsetMinutes,
        dhuhrMinutes: settings.dhuhrOffsetMinutes,
        asrMinutes: settings.asrOffsetMinutes,
        maghribMinutes: settings.maghribOffsetMinutes,
        ishaMinutes: settings.ishaOffsetMinutes,
      ),
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final prayerTimesProvider =
    AsyncNotifierProvider<PrayerTimesNotifier, PrayerTime>(
  PrayerTimesNotifier.new,
);
