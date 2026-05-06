import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_in_anonymously_usecase.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/link_with_google_usecase.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(remote: ref.read(authRemoteDataSourceProvider));
});

// ── Use case providers ────────────────────────────────────────────────────────

final signInWithGoogleUseCaseProvider = Provider((ref) =>
    SignInWithGoogleUseCase(ref.read(authRepositoryProvider)));

final signInAnonymouslyUseCaseProvider = Provider((ref) =>
    SignInAnonymouslyUseCase(ref.read(authRepositoryProvider)));

final signInWithEmailUseCaseProvider = Provider((ref) =>
    SignInWithEmailUseCase(ref.read(authRepositoryProvider)));

final signUpWithEmailUseCaseProvider = Provider((ref) =>
    SignUpWithEmailUseCase(ref.read(authRepositoryProvider)));

final resetPasswordUseCaseProvider = Provider((ref) =>
    ResetPasswordUseCase(ref.read(authRepositoryProvider)));

final signOutUseCaseProvider = Provider((ref) =>
    SignOutUseCase(ref.read(authRepositoryProvider)));

final linkWithGoogleUseCaseProvider = Provider((ref) =>
    LinkWithGoogleUseCase(ref.read(authRepositoryProvider)));

// ── Auth state stream ─────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges;
});

// ── Auth notifier ─────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AsyncValue<AppUser?>> {
  @override
  AsyncValue<AppUser?> build() {
    ref.listen(authStateProvider, (_, next) => state = next);
    return ref.read(authStateProvider);
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await ref.read(signInWithGoogleUseCaseProvider)();
    state = result.fold(
      (f) => AsyncError(f.message, StackTrace.current),
      AsyncData.new,
    );
  }

  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    final result = await ref.read(signInAnonymouslyUseCaseProvider)();
    state = result.fold(
      (f) => AsyncError(f.message, StackTrace.current),
      AsyncData.new,
    );
  }

  Future<void> signInWithEmail({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref.read(signInWithEmailUseCaseProvider)(
      email: email, password: password,
    );
    state = result.fold(
      (f) => AsyncError(f.message, StackTrace.current),
      AsyncData.new,
    );
  }

  Future<void> signUpWithEmail({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref.read(signUpWithEmailUseCaseProvider)(
      email: email, password: password,
    );
    state = result.fold(
      (f) => AsyncError(f.message, StackTrace.current),
      AsyncData.new,
    );
  }

  Future<String?> sendPasswordReset(String email) async {
    final result = await ref.read(resetPasswordUseCaseProvider)(email);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<void> linkWithGoogle() async {
    final result = await ref.read(linkWithGoogleUseCaseProvider)();
    result.fold(
      (f) => state = AsyncError(f.message, StackTrace.current),
      (user) => state = AsyncData(user),
    );
  }

  Future<String?> updateEmail(String newEmail) async {
    final result = await ref.read(authRepositoryProvider).updateEmail(newEmail);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> updatePassword(String newPassword) async {
    final result = await ref.read(authRepositoryProvider).updatePassword(newPassword);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> deleteAccount() async {
    final result = await ref.read(authRepositoryProvider).deleteAccount();
    return result.fold((f) => f.message, (_) => null);
  }

  Future<void> signOut() async {
    await ref.read(signOutUseCaseProvider)();
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AsyncValue<AppUser?>>(AuthNotifier.new);
