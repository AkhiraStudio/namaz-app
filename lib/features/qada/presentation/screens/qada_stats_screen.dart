import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../prayer/domain/entities/prayer_record.dart';
import '../providers/qada_provider.dart';

class QadaStatsScreen extends ConsumerStatefulWidget {
  const QadaStatsScreen({super.key});

  @override
  ConsumerState<QadaStatsScreen> createState() => _QadaStatsScreenState();
}

class _QadaStatsScreenState extends ConsumerState<QadaStatsScreen> {
  int _periodIndex = 0;

  static const _prayerLabels = {
    PrayerName.fajr: 'Fajr',
    PrayerName.dhuhr: 'Dhuhr',
    PrayerName.asr: 'Asr',
    PrayerName.maghrib: 'Maghrib',
    PrayerName.isha: 'Isha',
  };

  int _countForPeriod(QadaStats s) => switch (_periodIndex) {
        0 => s.last7days,
        1 => s.last30days,
        2 => s.last90days,
        _ => s.last365days,
      };

  String _periodFull(AppLocalizations l) => switch (_periodIndex) {
        0 => l.last7DaysLabel,
        1 => l.last30DaysLabel,
        2 => l.last3MonthsLabel,
        _ => l.lastYearLabel,
      };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final statsAsync = ref.watch(qadaStatsProvider);
    final cs = Theme.of(context).colorScheme;
    final periodLabels = [
      l.period7Days,
      l.period30Days,
      l.period3Months,
      l.period1Year,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.qadaStatisticsTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: List.generate(periodLabels.length, (i) {
                final selected = i == _periodIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _periodIndex = i),
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
                        periodLabels[i],
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
              }),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: statsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.deepPurple),
              ),
              error: (e, _) => Center(
                child: Text(l.errorLabel(e.toString()),
                    style: TextStyle(color: cs.error)),
              ),
              data: (stats) {
                final count = _countForPeriod(stats);
                final weeklyAsync = ref.watch(qadaWeeklyReportProvider);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    weeklyAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (report) => _QadaWeeklyReportCard(report: report),
                    ),
                    const SizedBox(height: 16),

                    Container(
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
                                  value: stats.totalDone > 0
                                      ? (count / stats.totalDone).clamp(0.0, 1.0)
                                      : 0.0,
                                  backgroundColor: Colors.white24,
                                  color: Colors.white,
                                  strokeWidth: 7,
                                ),
                                Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
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
                                l.makeupPrayersLabel,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _periodFull(l),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _SectionTitle(
                        icon: Icons.local_fire_department_rounded,
                        label: l.streaksSection),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: l.currentStreakQadaLabel,
                            value: l.streakDays(stats.currentStreak),
                            icon: Icons.local_fire_department_rounded,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: l.longestStreakQadaLabel,
                            value: l.streakDays(stats.longestStreak),
                            icon: Icons.emoji_events_rounded,
                            color: AppColors.prayerEarly,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _SectionTitle(
                        icon: Icons.grid_view_rounded,
                        label: l.distributionByPrayer),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        children: PrayerName.values.asMap().entries.map((entry) {
                          final i = entry.key;
                          final name = entry.value;
                          final pCount = stats.perPrayer[name] ?? 0;
                          final maxCount =
                              stats.totalDone > 0 ? stats.totalDone : 1;
                          final ratio = pCount / maxCount;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        _prayerLabels[name]!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: ratio,
                                          minHeight: 8,
                                          backgroundColor:
                                              AppColors.deepPurple.withValues(
                                                  alpha: 0.08),
                                          valueColor:
                                              const AlwaysStoppedAnimation(
                                                  AppColors.deepPurple),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 32,
                                      child: Text(
                                        '$pCount',
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.deepPurple,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (i < PrayerName.values.length - 1)
                                Divider(height: 1, color: cs.outlineVariant),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _StatCard(
                      label: l.totalMakeupAllTime,
                      value:
                          '${stats.totalDone} ${stats.totalDone > 1 ? l.prayerPlural : l.prayerSingular}',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.deepPurple,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.deepPurple),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _QadaWeeklyReportCard extends StatelessWidget {
  final QadaWeeklyReport report;
  const _QadaWeeklyReportCard({required this.report});

  String _message(AppLocalizations l, QadaWeeklyReport r) {
    final d = r.delta;
    if (d >= 5) return l.qadaWeeklyMsgExcellent(d);
    if (d > 0) return l.qadaWeeklyMsgGood(d);
    if (d == 0 && r.previousWeek == 0) return l.weeklyMsgNotEnoughData;
    if (d == 0) return l.qadaWeeklyMsgStable;
    if (d >= -4) return l.qadaWeeklyMsgSlightDecline;
    return l.qadaWeeklyMsgBigDecline;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;

    final (Color bg, Color border, Color iconColor, IconData icon) =
        switch (report.trend) {
      QadaWeekTrend.improved => (
          AppColors.prayerEarly.withValues(alpha: 0.08),
          AppColors.prayerEarly.withValues(alpha: 0.4),
          AppColors.prayerEarly,
          Icons.trending_up_rounded,
        ),
      QadaWeekTrend.declined => (
          AppColors.prayerLate.withValues(alpha: 0.08),
          AppColors.prayerLate.withValues(alpha: 0.4),
          AppColors.prayerLate,
          Icons.trending_down_rounded,
        ),
      QadaWeekTrend.stable => (
          AppColors.deepPurple.withValues(alpha: 0.07),
          AppColors.deepPurple.withValues(alpha: 0.25),
          AppColors.deepPurple,
          Icons.trending_flat_rounded,
        ),
    };

    final deltaText = report.delta > 0
        ? '+${report.delta}'
        : '${report.delta}';

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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$deltaText ${report.delta.abs() > 1 ? l.prayerPlural : l.prayerSingular}',
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
                  _message(l, report),
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _MiniCount(
                      label: l.previousWeekLabel,
                      count: report.previousWeek,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 20),
                    _MiniCount(
                      label: l.thisWeekLabel,
                      count: report.currentWeek,
                      color: iconColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCount extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _MiniCount(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
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
          '$count ${count > 1 ? l.prayerPlural : l.prayerSingular}',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
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
                    style: TextStyle(
                        fontSize: 11, color: cs.onSurfaceVariant)),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
