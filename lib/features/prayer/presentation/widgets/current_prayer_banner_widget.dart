import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/prayer_time_utils.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../providers/current_prayer_provider.dart';
import 'tricolor_progress_bar_widget.dart';

class CurrentPrayerBannerWidget extends ConsumerWidget {
  const CurrentPrayerBannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAsync = ref.watch(currentPrayerProvider);
    final next = ref.watch(nextPrayerProvider);
    final previous = ref.watch(previousPrayerProvider);

    return currentAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (current) {
        if (current == null) {
          return _NextPrayerCard(next: next, previous: previous);
        }
        return _CurrentPrayerCard(state: current);
      },
    );
  }
}

class _CurrentPrayerCard extends StatelessWidget {
  final CurrentPrayerState state;
  const _CurrentPrayerCard({required this.state});

  Color get _statusColor => switch (state.windowStatus) {
        PrayerWindowStatus.early => AppColors.prayerEarly,
        PrayerWindowStatus.onTime => AppColors.prayerOnTime,
        PrayerWindowStatus.late => AppColors.prayerLate,
        PrayerWindowStatus.missed => AppColors.prayerMissed,
      };

  String _formatRemaining(Duration d, BuildContext context) {
    if (d.isNegative) return context.l10n.prayerEndedLabel;
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}min';
    if (d.inMinutes > 0) return '${d.inMinutes} min';
    return '${d.inSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final remaining = state.end.difference(DateTime.now());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final accent = AppColors.prayerAccent(state.prayerName);
    final bgColor = isDark ? AppColors.darkCard : AppColors.creamBackground;
    final glowAlpha1 = isDark ? 0.65 : 0.50;
    final glowAlpha2 = isDark ? 0.35 : 0.25;
    final titleColor = isDark ? AppColors.textOnDark : AppColors.deepPurple;
    final subtitleColor = isDark ? cs.onSurfaceVariant : AppColors.mediumPurple;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: glowAlpha1),
            blurRadius: 14,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: accent.withValues(alpha: glowAlpha2),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.currentPrayerLabel,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: subtitleColor),
                  ),
                  Text(
                    state.prayerName,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _statusColor, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 13, color: _statusColor),
                    const SizedBox(width: 5),
                    Text(
                      _formatRemaining(remaining, context),
                      style: TextStyle(
                          color: _statusColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TricolorProgressBarWidget(
            prayerStart: state.start,
            prayerEnd: state.end,
            now: DateTime.now(),
          ),
        ],
      ),
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  final MapEntry<String, DateTime>? next;
  final MapEntry<String, DateTime>? previous;

  const _NextPrayerCard({this.next, this.previous});

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatCountdown(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}min';
    return '${d.inMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    if (next == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final countdown = next!.value.difference(now);

    // Progression entre la prière précédente et la suivante (0.0 → 1.0)
    double progress = 0.0;
    if (previous != null) {
      final total = next!.value.difference(previous!.value).inSeconds;
      final elapsed = now.difference(previous!.value).inSeconds;
      if (total > 0) progress = (elapsed / total).clamp(0.0, 1.0);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Labels prière précédente / suivante ───────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Prière passée
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    previous?.key ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  if (previous != null)
                    Text(
                      _fmt(previous!.value),
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
              // Temps restant centré
              Column(
                children: [
                  Text(
                    context.l10n.nextPrayerLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _formatCountdown(countdown),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepPurple,
                        ),
                  ),
                ],
              ),
              // Prière suivante
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    next!.key,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepPurple,
                        ),
                  ),
                  Text(
                    _fmt(next!.value),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.deepPurple.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── Timeline ─────────────────────────────────────────────────────
          LayoutBuilder(builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final dotX = (totalWidth * progress).clamp(6.0, totalWidth - 6.0);

            return SizedBox(
              height: 20,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  // Ligne de fond
                  Positioned(
                    top: 9,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: cs.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Portion écoulée
                  Positioned(
                    top: 9,
                    left: 0,
                    width: dotX,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.deepPurple.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Point de départ (prière passée)
                  Positioned(
                    left: 0,
                    top: 5,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.outlineVariant,
                      ),
                    ),
                  ),
                  // Curseur "vous êtes ici"
                  Positioned(
                    left: dotX - 8,
                    top: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.deepPurple,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepPurple.withValues(alpha: 0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Point d'arrivée (prochaine prière)
                  Positioned(
                    right: 0,
                    top: 5,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.deepPurple,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
