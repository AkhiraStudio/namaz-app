import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../providers/premium_provider.dart';

// ── Style A : Blur ─────────────────────────────────────────────────────────────
/// Affiche le widget enfant flou avec une icône cadenas si non premium.
/// Usage : GardenWidget, StreakFlameWidget, StreakBannerWidget.

class PremiumBlurGate extends ConsumerWidget {
  final Widget child;
  final String featureLabel;

  const PremiumBlurGate({
    super.key,
    required this.child,
    required this.featureLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(isPremiumProvider)) return child;

    return GestureDetector(
      onTap: () => context.pushNamed(RouteNames.paywall),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          IgnorePointer(child: child),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.20),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_rounded,
                            color: Colors.white, size: 28),
                        const SizedBox(height: 6),
                        Text(
                          featureLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Image.asset(
                          'assets/images/pro_badge.jpeg',
                          height: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Style B : Replace ──────────────────────────────────────────────────────────
/// Remplace le contenu par un placeholder si non premium.
/// Usage : SunnahSectionWidget, _AdhkarBanner.

class PremiumReplaceGate extends ConsumerWidget {
  final Widget child;
  final String featureLabel;
  final Widget? lockedPlaceholder;

  const PremiumReplaceGate({
    super.key,
    required this.child,
    required this.featureLabel,
    this.lockedPlaceholder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(isPremiumProvider)) return child;
    return lockedPlaceholder ??
        _DefaultLockedPlaceholder(label: featureLabel);
  }
}

class _DefaultLockedPlaceholder extends StatelessWidget {
  final String label;
  const _DefaultLockedPlaceholder({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.pushNamed(RouteNames.paywall),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_rounded, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style:
                    TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Image.asset(
                'assets/images/pro_badge.jpeg',
                height: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Style C : Action intercept ─────────────────────────────────────────────────
/// Exécute le callback uniquement si premium, sinon ouvre le paywall.
/// Usage : boutons side-tab, tiles settings.

class PremiumActionGate extends ConsumerWidget {
  final Widget child;
  final VoidCallback onPremiumAction;

  const PremiumActionGate({
    super.key,
    required this.child,
    required this.onPremiumAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isPremium
          ? onPremiumAction
          : () => context.pushNamed(RouteNames.paywall),
      child: child,
    );
  }
}
