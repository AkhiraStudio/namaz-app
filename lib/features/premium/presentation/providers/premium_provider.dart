import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/premium_status.dart';
import '../../domain/repositories/premium_repository.dart';
import '../../domain/usecases/get_premium_status_usecase.dart';
import '../../domain/usecases/purchase_product_usecase.dart';
import '../../domain/usecases/restore_purchases_usecase.dart';
import '../../data/datasources/premium_remote_datasource.dart';
import '../../data/repositories_impl/premium_repository_impl.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final premiumRemoteDataSourceProvider =
    Provider<PremiumRemoteDataSource>((ref) {
  return PremiumRemoteDataSourceImpl();
});

final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  return PremiumRepositoryImpl(ref.read(premiumRemoteDataSourceProvider));
});

// ── Use cases ─────────────────────────────────────────────────────────────────

final getPremiumStatusUseCaseProvider = Provider<GetPremiumStatusUseCase>(
    (ref) => GetPremiumStatusUseCase(ref.read(premiumRepositoryProvider)));

final purchaseProductUseCaseProvider = Provider<PurchaseProductUseCase>(
    (ref) => PurchaseProductUseCase(ref.read(premiumRepositoryProvider)));

final restorePurchasesUseCaseProvider = Provider<RestorePurchasesUseCase>(
    (ref) => RestorePurchasesUseCase(ref.read(premiumRepositoryProvider)));

// ── Source de vérité RevenueCat ───────────────────────────────────────────────

final premiumStatusProvider = StreamProvider<PremiumStatus>((ref) {
  return ref.read(getPremiumStatusUseCaseProvider)();
});

// ── Accès gratuit via Firestore (owner + invités) ─────────────────────────────
//
// Pour donner l'accès complet à quelqu'un sans abonnement :
//   Firebase Console → Firestore → Collection "premium_access"
//   → Ajouter un document dont l'ID = UID Firebase de la personne
//   → Ajouter un champ "note" (string) pour te souvenir de qui c'est (optionnel)
//
// Pour révoquer : supprimer le document correspondant.

final _premiumOverrideProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return false;
  try {
    final doc = await FirebaseFirestore.instance
        .collection('premium_access')
        .doc(user.uid)
        .get();
    return doc.exists;
  } catch (e) {
    debugPrint('premium_override error: $e');
    return false;
  }
});

/// Booléen dérivé — true si l'utilisateur a un abonnement RevenueCat actif
/// OU s'il figure dans la liste d'accès gratuit Firestore.
/// Vaut false pendant le chargement (dégradation gracieuse).
final isPremiumProvider = Provider<bool>((ref) {
  final byRevenueCat =
      ref.watch(premiumStatusProvider).valueOrNull?.isActive ?? false;
  final byOverride =
      ref.watch(_premiumOverrideProvider).valueOrNull ?? false;
  return byRevenueCat || byOverride;
});

// ── Notifier pour les actions (achat / restauration) ─────────────────────────

class PremiumNotifier extends AsyncNotifier<PremiumStatus> {
  @override
  Future<PremiumStatus> build() async {
    return ref.watch(premiumStatusProvider).valueOrNull ?? PremiumStatus.free;
  }

  /// Retourne null en cas de succès, le message d'erreur sinon.
  Future<String?> purchase(String productId) async {
    state = const AsyncValue.loading();
    final result =
        await ref.read(purchaseProductUseCaseProvider)(productId);
    return result.fold(
      (failure) {
        state = AsyncData(
            ref.read(premiumStatusProvider).valueOrNull ?? PremiumStatus.free);
        return failure.message;
      },
      (status) {
        state = AsyncData(status);
        return null;
      },
    );
  }

  /// Retourne null en cas de succès, le message d'erreur sinon.
  Future<String?> restore() async {
    state = const AsyncValue.loading();
    final result = await ref.read(restorePurchasesUseCaseProvider)();
    return result.fold(
      (failure) {
        state = const AsyncData(PremiumStatus.free);
        return failure.message;
      },
      (status) {
        state = AsyncData(status);
        return null;
      },
    );
  }
}

final premiumNotifierProvider =
    AsyncNotifierProvider<PremiumNotifier, PremiumStatus>(PremiumNotifier.new);
