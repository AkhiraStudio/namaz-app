import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../premium/presentation/widgets/premium_gate.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_loading_widget.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../providers/qada_provider.dart';
import '../widgets/qada_progress_bar_widget.dart';
import '../widgets/streak_flame_widget.dart';
import '../widgets/daily_qada_list_widget.dart';
import '../../../prayer/domain/entities/prayer_record.dart';
import '../../domain/entities/pending_missed_entry.dart';
import '../../domain/entities/qada_progress.dart';
import '../../../../shared/widgets/weekly_dots_row_widget.dart';

class QadaScreen extends ConsumerStatefulWidget {
  const QadaScreen({super.key});

  @override
  ConsumerState<QadaScreen> createState() => _QadaScreenState();
}

class _QadaScreenState extends ConsumerState<QadaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.qadaScreenTitle),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(text: context.l10n.scheduleTab),
            Tab(text: context.l10n.missedTab),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: const [
              _ProgrammeTab(),
              _ManqueesTab(),
            ],
          ),
          const Positioned(
            right: 0,
            top: 0,
            child: _QadaSideTab(),
          ),
        ],
      ),
    );
  }
}

// ── Onglet Programme ──────────────────────────────────────────────────────────

class _ProgrammeTab extends ConsumerWidget {
  const _ProgrammeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(qadaProgressProvider);

    return progressAsync.when(
      loading: () => AppLoadingWidget(message: context.l10n.loadingLabel),
      error: (e, _) => AppErrorWidget(
        message: e.toString(),
        onRetry: () => ref.invalidate(qadaProgressProvider),
      ),
      data: (progress) {
        if (progress.totalPrayersOwed == 0) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.outlineVariant),
                const SizedBox(height: 16),
                Text(
                  'Pas de programme de rattrapage\npour le moment',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Utilisez le calculateur pour démarrer',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
        onRefresh: () async => ref.invalidate(qadaProgressProvider),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Streak + prières restantes
            Row(
              children: [
                PremiumBlurGate(
                  featureLabel: context.l10n.streaksSection,
                  child: StreakFlameWidget(streakDays: progress.currentStreak),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Text(
                      context.l10n.remainingPrayers(progress.remaining),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Barre de progression globale
            QadaProgressBarWidget(progress: progress),
            const SizedBox(height: 16),

            // Objectif de fin
            if (progress.targetDate != null)
              _ObjectiveTile(progress: progress),
            const SizedBox(height: 16),

            // Liste dépliante du jour (groupée par prière)
            const DailyQadaListWidget(),
            const SizedBox(height: 24),

            // Progression semaine
            ref.watch(weeklyQadaDotsProvider).when(
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
                        color: AppColors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    WeeklyDotsRow(
                      completion: dots,
                      activeColor: AppColors.deepPurple,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      );
      },
    );
  }
}

// ── Tile objectif (avec toggle jours/prières) ────────────────────────────────

class _ObjectiveTile extends ConsumerWidget {
  final QadaProgress progress;
  const _ObjectiveTile({required this.progress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inDays = ref.watch(qadaObjectiveInDaysProvider);
    final daysToMakeUp = (progress.dailyTargetPrayers / 5).ceil().clamp(1, 10);
    final l = context.l10n;
    final label = inDays
        ? l.dailyGoalDays(daysToMakeUp)
        : l.dailyGoalPrayers(progress.dailyTargetPrayers);

    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag_rounded, color: AppColors.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l.dailyObjectiveTitle(label),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          GestureDetector(
            onTap: () => ref
                .read(qadaObjectiveInDaysProvider.notifier)
                .state = !inDays,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                inDays ? l.switchToPrayersLabel : l.switchToDaysLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Onglet Manquées ───────────────────────────────────────────────────────────

class _ManqueesTab extends ConsumerWidget {
  const _ManqueesTab();

  static const _prayerOrder = PrayerName.values;

  static String _label(PrayerName name) => switch (name) {
        PrayerName.fajr => 'Fajr',
        PrayerName.dhuhr => 'Dhuhr',
        PrayerName.asr => 'Asr',
        PrayerName.maghrib => 'Maghrib',
        PrayerName.isha => 'Isha',
      };

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingRecentMissedProvider);

    return pendingAsync.when(
      loading: () =>
          AppLoadingWidget(message: context.l10n.loadingLabel),
      error: (e, _) => AppErrorWidget(
        message: e.toString(),
        onRetry: () => ref.invalidate(pendingRecentMissedProvider),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    size: 48, color: AppColors.prayerEarly),
                const SizedBox(height: 12),
                Text(
                  context.l10n.noMissedPrayerTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.allPrayersUpToDate,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13),
                ),
              ],
            ),
          );
        }

        // Grouper par PrayerName, dans l'ordre canonique
        final grouped = <PrayerName, List<PendingMissedEntry>>{};
        for (final e in entries) {
          grouped.putIfAbsent(e.prayerName, () => []).add(e);
        }
        // Trier chaque groupe par date décroissante
        for (final list in grouped.values) {
          list.sort((a, b) => b.missedAt.compareTo(a.missedAt));
        }

        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(pendingRecentMissedProvider),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Compteur total
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.prayerLate.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.prayerLate.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.prayerLate, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${entries.length} ${entries.length > 1 ? context.l10n.prayerPlural : context.l10n.prayerSingular} ${context.l10n.toMakeUpLabel}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.prayerLate,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Un groupe par prière
              for (final name in _prayerOrder)
                if (grouped.containsKey(name)) ...[
                  _PrayerGroup(
                    label: _label(name),
                    entries: grouped[name]!,
                    formatDate: _formatDate,
                    onMakeUp: (key) => ref
                        .read(qadaProgressProvider.notifier)
                        .makeUpRecentMissed(key, name),
                  ),
                  const SizedBox(height: 12),
                ],
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _PrayerGroup extends StatelessWidget {
  final String label;
  final List<PendingMissedEntry> entries;
  final String Function(DateTime) formatDate;
  final void Function(String key) onMakeUp;

  const _PrayerGroup({
    required this.label,
    required this.entries,
    required this.formatDate,
    required this.onMakeUp,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du groupe
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '× ${entries.length}',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Items
          ...entries.asMap().entries.map((e) {
            final index = e.key;
            final entry = e.value;
            return Column(
              children: [
                ListTile(
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    context.l10n.missedOnDate(formatDate(entry.missedAt)),
                    style: TextStyle(fontSize: 13, color: cs.onSurface),
                  ),
                  trailing: TextButton(
                    onPressed: () => onMakeUp(entry.key),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      backgroundColor: cs.primary.withValues(alpha: 0.10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      context.l10n.makeUpButton,
                      style: TextStyle(fontSize: 12, color: cs.primary),
                    ),
                  ),
                ),
                if (index < entries.length - 1)
                  const Divider(height: 1, indent: 14),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Onglet latéral rétractable ────────────────────────────────────────────────

class _QadaSideTab extends StatefulWidget {
  const _QadaSideTab();

  @override
  State<_QadaSideTab> createState() => _QadaSideTabState();
}

class _QadaSideTabState extends State<_QadaSideTab> {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);
  void _close() => setState(() => _open = false);

  void _openCalculator() {
    _close();
    context.goNamed(RouteNames.qadaCalculator);
  }

  void _openStats() {
    _close();
    context.pushNamed(RouteNames.qadaStats);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCard : AppColors.deepPurple;

    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRect(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: _open ? 76.0 : 0.0,
              child: Container(
                width: 90,
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
                      icon: Icons.calculate_outlined,
                      label: context.l10n.calculateTabLabel,
                      onTap: _openCalculator,
                    ),
                    _TabIcon(
                      icon: Icons.bar_chart_rounded,
                      label: context.l10n.statsTabLabel,
                      onTap: _openStats,
                    ),
                  ],
                ),
              ),
            ),
          ),
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
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
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

