import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../providers/prayer_times_provider.dart';
import '../widgets/current_prayer_banner_widget.dart';
import '../widgets/prayer_time_card_widget.dart';
import '../widgets/night_third_calculator_widget.dart';
import '../../domain/entities/prayer_time.dart';
import '../widgets/mosque_nearby_list_widget.dart';
import '../widgets/sunnah_section_widget.dart';
import '../../../../shared/widgets/app_loading_widget.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../features/settings/presentation/providers/settings_provider.dart';
import '../../../../features/onboarding/presentation/providers/profile_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../prayer/domain/entities/prayer_record.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../premium/presentation/providers/premium_provider.dart';
import '../../../premium/presentation/widgets/premium_gate.dart';
import '../providers/prayer_statistics_provider.dart';
import '../../../../shared/widgets/weekly_dots_row_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    final showSunnah = ref.watch(settingsProvider.select((s) => s.showSunnahPrayers));

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: prayerTimesAsync.when(
              loading: () => const AppLoadingWidget(),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.read(prayerTimesProvider.notifier).refresh(),
              ),
              data: (times) => Stack(
                children: [
                  RefreshIndicator(
                onRefresh: () => ref.read(prayerTimesProvider.notifier).refresh(),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _DateHeader(),
                            const SizedBox(height: 28),
                            const CurrentPrayerBannerWidget(),
                            const SizedBox(height: 44),
                            Text(
                              context.l10n.todayPrayerTimesTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final ordered = times.orderedPrayers;
                          final prayer = ordered[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PrayerTimeCardWidget(
                                  prayerName: prayer.key,
                                  prayerTime: prayer.value,
                                  nextPrayerTime: prayer.key == 'Fajr'
                                      ? times.sunrise
                                      : i < ordered.length - 1
                                          ? ordered[i + 1].value
                                          : prayer.value.add(const Duration(hours: 3)),
                                ),
                                if (showSunnah)
                                  PremiumReplaceGate(
                                    featureLabel: context.l10n.sunnahSectionLabel,
                                    child: SunnahSectionWidget(
                                        prayerName: PrayerName.values[i]),
                                  ),
                              ],
                            ),
                          );
                        },
                        childCount: times.orderedPrayers.length,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                        child: ref.watch(weeklyPrayerDotsProvider).when(
                          loading: () => const SizedBox(height: 90),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (dots) => Container(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outlineVariant,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.weeklyProgressTitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.prayerEarly,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                WeeklyDotsRow(
                                  completion: dots,
                                  activeColor: AppColors.prayerEarly,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  ],
                ),
              ),
              _SideTab(times: times),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _DateHeader extends ConsumerWidget {
  const _DateHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final languageCode = ref.watch(settingsProvider.select((s) => s.languageCode));
    final dateStr = DateFormat('EEE d MMMM y', languageCode).format(now);
    final name = ref.watch(profileProvider).valueOrNull?.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateStr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'As-salamu alaykum',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (name != null && name.isNotEmpty)
          Text(
            name,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                  height: 1.1,
                ),
          ),
      ],
    );
  }
}

// ── Onglet latéral rétractable ────────────────────────────────────────────────

class _SideTab extends ConsumerStatefulWidget {
  final PrayerTime times;
  const _SideTab({required this.times});

  @override
  ConsumerState<_SideTab> createState() => _SideTabState();
}

class _SideTabState extends ConsumerState<_SideTab> {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  void _close() => setState(() => _open = false);

  void _openNightThird() {
    if (!ref.read(isPremiumProvider)) {
      _close();
      context.pushNamed(RouteNames.paywall);
      return;
    }
    _close();
    final title = context.l10n.nightThirdTitle;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetWrapper(
        title: title,
        child: NightThirdCalculatorWidget(times: widget.times),
      ),
    );
  }

  void _openMosques() {
    if (!ref.read(isPremiumProvider)) {
      _close();
      context.pushNamed(RouteNames.paywall);
      return;
    }
    _close();
    final title = context.l10n.nearbyMosquesTitle;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetWrapper(
        title: title,
        child: const MosqueNearbyListWidget(),
      ),
    );
  }

  void _openStats() {
    _close();
    context.goNamed(RouteNames.statistics);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCard : AppColors.deepPurple;

    return Positioned(
      right: 0,
      top: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Panneau clippé (largeur animée 0 → contenu) ──────────────
          ClipRect(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: _open ? 76.0 : 0.0,
              child: Container(
                width: 76,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TabIcon(
                      icon: Icons.nightlight_round,
                      label: context.l10n.nightTabLabel,
                      onTap: _openNightThird,
                    ),
                    _TabIcon(
                      icon: Icons.bar_chart_rounded,
                      label: context.l10n.statsTabLabel,
                      onTap: _openStats,
                    ),
                    _TabIcon(
                      icon: Icons.mosque_rounded,
                      label: context.l10n.mosquesTabLabel,
                      onTap: _openMosques,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ── Onglet handle (toujours visible) ─────────────────────────
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 26,
              height: 80,
              decoration: BoxDecoration(
                color: bg.withValues(alpha: 0.70),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Center(
                child: AnimatedRotation(
                  turns: _open ? 0.0 : 0.5,
                  duration: const Duration(milliseconds: 220),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 14,
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

// ── Icône dans le panneau ─────────────────────────────────────────────────────

class _TabIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TabIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Wrapper bottom sheet ──────────────────────────────────────────────────────

class _BottomSheetWrapper extends StatelessWidget {
  final String title;
  final Widget child;

  const _BottomSheetWrapper({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          child,
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
