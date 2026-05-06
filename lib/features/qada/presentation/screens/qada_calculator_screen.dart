import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/qada_provider.dart';
import '../widgets/qada_debt_form_widget.dart';
import '../../../premium/presentation/providers/premium_provider.dart';

class QadaCalculatorScreen extends ConsumerWidget {
  const QadaCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final progressAsync = ref.watch(qadaProgressProvider);
    final debtAsync = ref.watch(qadaDebtProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.calculateDebtTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.deepPurple.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l.qadaInstructions,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            QadaDebtFormWidget(maxPeriods: isPremium ? null : 1),
            const SizedBox(height: 32),

            progressAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (progress) {
                if (progress.totalPrayersOwed == 0) {
                  return const SizedBox.shrink();
                }
                final debt = debtAsync.valueOrNull;
                final totalDays = progress.totalDaysOwed +
                    (debt?.mensDaysDeducted ?? 0);
                final mensDays = debt?.mensDaysDeducted ?? 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(l.resultLabel,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),

                    _ResultRow(
                      label: l.totalDaysLabel,
                      value: l.daysCount(totalDays),
                    ),

                    if (mensDays > 0)
                      _ResultRow(
                        label: l.menstruationDeducted,
                        value: '− ${l.daysCount(mensDays)}',
                        color: AppColors.prayerLate,
                      ),

                    _ResultRow(
                      label: mensDays > 0
                          ? l.effectiveDaysLabel
                          : l.prayerDaysLabel,
                      value: l.daysCount(progress.totalDaysOwed),
                      highlight: mensDays > 0,
                    ),
                    const SizedBox(height: 4),
                    _ResultRow(
                      label: l.totalPrayersLabel,
                      value: '${progress.totalPrayersOwed}',
                      highlight: true,
                    ),
                    const SizedBox(height: 24),
                    Text(l.setEndGoalLabel,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _TargetDateButton(
                      currentTarget: progress.targetDate,
                      onTargetSet: (date) => ref
                          .read(qadaProgressProvider.notifier)
                          .setTargetDate(date),
                    ),
                    if (progress.targetDate != null) ...[
                      const SizedBox(height: 12),
                      _ResultRow(
                        label: l.dailyGoalLabel,
                        value: l.dailyGoalPrayers(progress.dailyTargetPrayers),
                        highlight: true,
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final Color? color;

  const _ResultRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color ??
                      (highlight ? AppColors.deepPurple : AppColors.textPrimary),
                  fontWeight:
                      highlight ? FontWeight.bold : FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _TargetDateButton extends StatelessWidget {
  final DateTime? currentTarget;
  final ValueChanged<DateTime> onTargetSet;

  const _TargetDateButton({
    required this.currentTarget,
    required this.onTargetSet,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 365)),
          firstDate: DateTime.now().add(const Duration(days: 1)),
          lastDate: DateTime(2050),
          helpText: l.desiredEndDateLabel,
        );
        if (picked != null) onTargetSet(picked);
      },
      icon: const Icon(Icons.calendar_today_rounded, size: 16),
      label: Text(
        currentTarget != null
            ? l.goalDateButton(
                currentTarget!.day,
                currentTarget!.month,
                currentTarget!.year,
              )
            : l.chooseDateButton,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.deepPurple,
        side: const BorderSide(color: AppColors.deepPurple),
      ),
    );
  }
}
