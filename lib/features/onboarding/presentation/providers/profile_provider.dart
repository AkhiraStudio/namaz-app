import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/save_profile_usecase.dart';
import '../../domain/usecases/check_onboarding_complete_usecase.dart';
import '../../data/datasources/profile_local_datasource.dart';
import '../../data/repositories_impl/profile_repository_impl.dart';
import '../../../../core/providers/firestore_provider.dart';

// ── Dependency providers ──────────────────────────────────────────────────────

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  return ProfileLocalDataSourceImpl();
});

final profileRepositoryProvider = Provider((ref) {
  return ProfileRepositoryImpl(
    localDataSource: ref.read(profileLocalDataSourceProvider),
    firestore: ref.read(firestoreServiceProvider),
  );
});

final getProfileUseCaseProvider = Provider((ref) {
  return GetProfileUseCase(ref.read(profileRepositoryProvider));
});

final saveProfileUseCaseProvider = Provider((ref) {
  return SaveProfileUseCase(ref.read(profileRepositoryProvider));
});

final checkOnboardingUseCaseProvider = Provider((ref) {
  return CheckOnboardingCompleteUseCase(ref.read(profileRepositoryProvider));
});

// ── State Notifier ────────────────────────────────────────────────────────────

class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final useCase = ref.read(getProfileUseCaseProvider);
    final result = await useCase();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (profile) => profile,
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    state = const AsyncLoading();
    final useCase = ref.read(saveProfileUseCaseProvider);
    final result = await useCase(profile);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) => state = AsyncData(profile),
    );
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile?>(
  ProfileNotifier.new,
);

/// Provider booléen indiquant si l'onboarding est terminé.
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final useCase = ref.read(checkOnboardingUseCaseProvider);
  final result = await useCase();
  return result.fold((_) => false, (complete) => complete);
});
