import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/prayer_record.dart';
import '../../domain/entities/prayer_statistics.dart';
import '../../domain/repositories/sunnah_repository.dart';
import '../providers/prayer_statistics_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  bool _showMissed = true;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final period = ref.watch(statsPeriodProvider);
    final statsAsync = ref.watch(prayerStatisticsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.statisticsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: StatsPeriod.values.map((p) {
                final selected = p == period;
                final label = switch (p) {
                  StatsPeriod.week => '7j',
                  StatsPeriod.month => '30j',
                  StatsPeriod.threeMonths => '3m',
                  StatsPeriod.year => '1an',
                };
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(statsPeriodProvider.notifier).state = p,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? cs.primary : cs.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? cs.primary : cs.outlineVariant,
                        ),
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected ? cs.onPrimary : cs.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (stats) {
                final sunnahAsync = ref.watch(sunnahStatisticsProvider);
                final weeklyAsync = ref.watch(weeklyReportProvider);
                final showSunnah = ref.watch(settingsProvider.select((s) => s.showSunnahPrayers));
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  children: [
                    weeklyAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (report) => _WeeklyReportCard(report: report),
                    ),
                    const SizedBox(height: 12),
                    _AdherenceCard(rate: stats.adherenceRate),
                    const SizedBox(height: 12),
                    _GridStats(stats: stats),
                    const SizedBox(height: 20),

                    if (stats.totalMissed > 0 && _showMissed) ...[
                      Text(l.missedPrayersPerSalah,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      _MissedByPrayerChart(missedByPrayer: stats.missedByPrayer),
                      const SizedBox(height: 20),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: l.currentStreakLabel,
                            value: '${stats.currentStreak}j',
                            color: AppColors.gold,
                            icon: Icons.local_fire_department_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: l.longestStreakLabel,
                            value: '${stats.longestStreak}j',
                            color: AppColors.deepPurple,
                            icon: Icons.emoji_events_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (showSunnah) ...[
                      Text(l.sunnahPrayersTitle,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      sunnahAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (s) => _SunnahCard(stats: s),
                      ),
                      const SizedBox(height: 20),
                    ],

                    Text(l.spiritualPracticesTitle,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _SpiritualCard(period: period),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showMissed = !_showMissed),
                  icon: Icon(
                    _showMissed
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                  ),
                  label: Text(
                    _showMissed ? l.hideMissedPrayers : l.showMissedPrayers,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: cs.outlineVariant),
                    foregroundColor: cs.onSurfaceVariant,
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

class _AdherenceCard extends StatelessWidget {
  final double rate;
  const _AdherenceCard({required this.rate});

  Color get _color {
    if (rate >= 0.8) return AppColors.prayerEarly;
    if (rate >= 0.5) return AppColors.prayerOnTime;
    return AppColors.prayerLate;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepPurple, AppColors.lightPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: rate,
                  backgroundColor: Colors.white24,
                  color: _color,
                  strokeWidth: 7,
                ),
                Text(
                  '${(rate * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.adherenceRateLabel,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                rate >= 0.8
                    ? l.excellentAdherence
                    : rate >= 0.5
                        ? l.goodAdherence
                        : l.needsEffort,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GridStats extends StatelessWidget {
  final PrayerStatistics stats;
  const _GridStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _StatCard(
          label: l.completedPrayersLabel,
          value: '${stats.totalPrayed}',
          color: AppColors.prayerEarly,
          icon: Icons.check_circle_outline_rounded,
        ),
        _StatCard(
          label: l.missedPrayersLabel,
          value: '${stats.totalMissed}',
          color: AppColors.prayerLate,
          icon: Icons.cancel_outlined,
        ),
        _StatCard(
          label: l.earlyLabel,
          value: '${stats.totalEarly}',
          color: AppColors.prayerEarly,
          icon: Icons.alarm_rounded,
        ),
        _StatCard(
          label: l.lateLabel,
          value: '${stats.totalLate}',
          color: AppColors.prayerOnTime,
          icon: Icons.timelapse_rounded,
        ),
      ],
    );
  }
}

class _MissedByPrayerChart extends StatelessWidget {
  final Map<PrayerName, int> missedByPrayer;
  const _MissedByPrayerChart({required this.missedByPrayer});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: PrayerName.values.map((name) {
          final count = missedByPrayer[name] ?? 0;
          final label = name.name[0].toUpperCase() + name.name.substring(1);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: TextStyle(fontSize: 13, color: cs.onSurface)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: count == 0
                        ? AppColors.prayerEarly.withValues(alpha: 0.12)
                        : AppColors.prayerLate.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    count == 0
                        ? l.noneLabel
                        : '$count ${count > 1 ? l.missedPlural : l.missedSingular}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: count == 0 ? AppColors.prayerEarly : AppColors.prayerLate,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                Text(value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.bold,
                        )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SunnahCard extends StatelessWidget {
  final SunnahStats stats;
  const _SunnahCard({required this.stats});

  Color get _color {
    if (stats.rate >= 0.6) return AppColors.prayerEarly;
    if (stats.rate >= 0.3) return AppColors.prayerOnTime;
    return AppColors.gold;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: stats.rate,
                  backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                  color: _color,
                  strokeWidth: 5,
                ),
                Text(
                  '${(stats.rate * 100).round()}%',
                  style: TextStyle(
                    color: _color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.done} / ${stats.total} accomplies',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.selectedPeriodSuffix,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyReportCard extends StatelessWidget {
  final WeeklyReport report;
  const _WeeklyReportCard({required this.report});

  String _weeklyMessage(AppLocalizations l, WeeklyReport r) {
    if (r.delta >= 0.08) return l.weeklyMsgGreatProgress;
    if (r.delta >= 0.02) return l.weeklyMsgSlightImprovement;
    if (r.delta <= -0.08) return l.weeklyMsgHarderWeek;
    if (r.delta <= -0.02) return l.weeklyMsgSlightDecline;
    if (r.previousRate == 0.0) return l.weeklyMsgNotEnoughData;
    return l.weeklyMsgStable;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;

    final (Color bg, Color border, Color iconColor, IconData icon) =
        switch (report.trend) {
      WeekTrend.improved => (
          AppColors.prayerEarly.withValues(alpha: 0.08),
          AppColors.prayerEarly.withValues(alpha: 0.4),
          AppColors.prayerEarly,
          Icons.trending_up_rounded,
        ),
      WeekTrend.declined => (
          AppColors.prayerLate.withValues(alpha: 0.08),
          AppColors.prayerLate.withValues(alpha: 0.4),
          AppColors.prayerLate,
          Icons.trending_down_rounded,
        ),
      WeekTrend.stable => (
          cs.surfaceContainerHighest.withValues(alpha: 0.5),
          cs.outlineVariant,
          cs.onSurfaceVariant,
          Icons.trending_flat_rounded,
        ),
    };

    final deltaText = report.delta >= 0
        ? '+${(report.delta * 100).round()}%'
        : '${(report.delta * 100).round()}%';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l.weeklyReportTitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        deltaText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _weeklyMessage(l, report),
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _MiniRate(
                        label: l.previousWeekLabel,
                        rate: report.previousRate,
                        color: cs.onSurfaceVariant),
                    const SizedBox(width: 16),
                    _MiniRate(
                        label: l.thisWeekLabel,
                        rate: report.currentRate,
                        color: iconColor),
                  ],
                ),
                if (report.struggleByPrayer.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _StrugglePrayers(struggleByPrayer: report.struggleByPrayer),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniRate extends StatelessWidget {
  final String label;
  final double rate;
  final Color color;
  const _MiniRate({required this.label, required this.rate, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        Text(
          '${(rate * 100).round()}%',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class _StrugglePrayers extends StatelessWidget {
  final Map<PrayerName, int> struggleByPrayer;
  const _StrugglePrayers({required this.struggleByPrayer});

  static String _label(PrayerName n) => switch (n) {
        PrayerName.fajr => 'Fajr',
        PrayerName.dhuhr => 'Dhuhr',
        PrayerName.asr => 'Asr',
        PrayerName.maghrib => 'Maghrib',
        PrayerName.isha => 'Isha',
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sorted = struggleByPrayer.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(3).toList();
    final max = top.first.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prières difficiles cette semaine',
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        ...top.map((e) {
          final ratio = e.value / max;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  child: Text(
                    _label(e.key),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 6,
                      backgroundColor: cs.outlineVariant.withValues(alpha: 0.4),
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.prayerLate.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${e.value}×',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.prayerLate,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _SpiritualCard extends ConsumerWidget {
  final StatsPeriod period;
  const _SpiritualCard({required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(spiritualStatsProvider);
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          _SpiritualRow(
            icon: Icons.wb_sunny_rounded,
            label: l.morningAdhkarsTitle,
            done: s.morningAdhkarDays,
            total: s.periodDays,
            color: AppColors.prayerEarly,
          ),
          Divider(height: 1, color: cs.outlineVariant),
          _SpiritualRow(
            icon: Icons.nights_stay_rounded,
            label: l.eveningAdhkarsTitle,
            done: s.eveningAdhkarDays,
            total: s.periodDays,
            color: AppColors.gold,
          ),
          Divider(height: 1, color: cs.outlineVariant),
          _SpiritualRow(
            icon: Icons.bedtime_rounded,
            label: l.sleepAdhkarsTitle,
            done: s.sleepAdhkarDays,
            total: s.periodDays,
            color: AppColors.deepPurple,
          ),
          Divider(height: 1, color: cs.outlineVariant),
          _SpiritualRow(
            icon: Icons.auto_awesome_rounded,
            label: l.postPrayerTasbihTitle,
            done: s.tasbeehDays,
            total: s.periodDays,
            color: AppColors.lightPurple,
          ),
        ],
      ),
    );
  }
}

class _SpiritualRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int done;
  final int total;
  final Color color;

  const _SpiritualRow({
    required this.icon,
    required this.label,
    required this.done,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ratio = total > 0 ? done / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, color: cs.onSurface)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: color.withValues(alpha: 0.10),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$done/$total j',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
