import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../domain/usecases/calculate_qada_debt_usecase.dart';
import '../providers/qada_provider.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/profile_provider.dart';

class _Period {
  DateTime? stopDate;
  DateTime? resumeDate;
  bool isPregnancy = false;
  _Period();
}

class QadaDebtFormWidget extends ConsumerStatefulWidget {
  /// null = illimité (premium). 1 = une seule période autorisée (gratuit).
  final int? maxPeriods;

  const QadaDebtFormWidget({super.key, this.maxPeriods});

  @override
  ConsumerState<QadaDebtFormWidget> createState() =>
      _QadaDebtFormWidgetState();
}

class _QadaDebtFormWidgetState extends ConsumerState<QadaDebtFormWidget> {
  final List<_Period> _periods = [_Period()];
  bool _isLoading = false;

  bool get _canCalculate =>
      _periods.every((p) => p.stopDate != null && p.resumeDate != null);

  Future<void> _pickDate(_Period period, bool isStop) async {
    final l = context.l10n;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      helpText: isStop ? l.stopDateHelpText : l.resumeDateHelpText,
    );
    if (picked != null) {
      setState(() {
        if (isStop) {
          period.stopDate = picked;
        } else {
          period.resumeDate = picked;
        }
      });
    }
  }

  Future<void> _calculate(UserProfile? profile) async {
    if (!_canCalculate) return;
    setState(() => _isLoading = true);

    final isFemale = profile?.gender == UserGender.female;
    final cycleDays = profile?.mensCycleDays ?? 28;
    final durationDays = profile?.mensDurationDays ?? 7;

    int totalDays = 0;
    int totalMensDays = 0;
    for (final p in _periods) {
      final days = p.resumeDate!.difference(p.stopDate!).inDays.abs();
      int mensDays = 0;
      if (isFemale && cycleDays > 0 && !p.isPregnancy) {
        mensDays = (days / cycleDays * durationDays).round();
      }
      totalDays += days;
      totalMensDays += mensDays;
    }

    await ref.read(qadaProgressProvider.notifier).calculateDebt(
          CalculateQadaDebtParams(
            stopDate: _periods.first.stopDate!,
            resumeDate: _periods.first.resumeDate!,
            isFemale: isFemale,
            mensCycleDays: cycleDays,
            mensDurationDays: durationDays,
            overrideTotalDays: totalDays,
            overrideMensDays: totalMensDays,
          ),
        );

    setState(() => _isLoading = false);
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final profile = ref.watch(profileProvider).valueOrNull;
    final isFemale = profile?.gender == UserGender.female;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isFemale) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.deepPurple.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.cycleInfoLabel(
                      profile?.mensCycleDays ?? 28,
                      profile?.mensDurationDays ?? 7,
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.deepPurple,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        ...List.generate(_periods.length, (i) {
          final p = _periods[i];
          return _PeriodCard(
            index: i,
            period: p,
            canDelete: _periods.length > 1,
            showPregnancyToggle: isFemale,
            onPickStop: () => _pickDate(p, true),
            onPickResume: () => _pickDate(p, false),
            onDelete: () => setState(() => _periods.removeAt(i)),
            onPregnancyToggle: (val) =>
                setState(() => p.isPregnancy = val),
            fmt: _fmt,
          );
        }),

        const SizedBox(height: 8),
        Builder(builder: (ctx) {
          final atLimit = widget.maxPeriods != null &&
              _periods.length >= widget.maxPeriods!;
          final lCtx = ctx.l10n;
          if (atLimit) {
            return GestureDetector(
              onTap: () => ctx.pushNamed(RouteNames.paywall),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.deepPurple.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.deepPurple.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_rounded,
                        size: 14, color: AppColors.deepPurple),
                    const SizedBox(width: 6),
                    Text(
                      lCtx.addPeriodPremium,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.deepPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return OutlinedButton.icon(
            onPressed: () => setState(() => _periods.add(_Period())),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text(lCtx.addPeriodButton),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.deepPurple,
              side: const BorderSide(color: AppColors.deepPurple),
            ),
          );
        }),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canCalculate && !_isLoading
                ? () => _calculate(profile)
                : null,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(l.calculateButton),
          ),
        ),
      ],
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final int index;
  final _Period period;
  final bool canDelete;
  final bool showPregnancyToggle;
  final VoidCallback onPickStop;
  final VoidCallback onPickResume;
  final VoidCallback onDelete;
  final ValueChanged<bool> onPregnancyToggle;
  final String Function(DateTime) fmt;

  const _PeriodCard({
    required this.index,
    required this.period,
    required this.canDelete,
    required this.showPregnancyToggle,
    required this.onPickStop,
    required this.onPickResume,
    required this.onDelete,
    required this.onPregnancyToggle,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l.periodLabel(index + 1),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepPurple,
                  ),
                ),
              ),
              const Spacer(),
              if (canDelete)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateTile(
                  label: l.startStopLabel,
                  date: period.stopDate,
                  onTap: onPickStop,
                  fmt: fmt,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateTile(
                  label: l.endResumeLabel,
                  date: period.resumeDate,
                  onTap: onPickResume,
                  fmt: fmt,
                ),
              ),
            ],
          ),
          if (period.stopDate != null && period.resumeDate != null) ...[
            const SizedBox(height: 10),
            Text(
              l.daysCount(period.resumeDate!
                  .difference(period.stopDate!)
                  .inDays
                  .abs()),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (showPregnancyToggle) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => onPregnancyToggle(!period.isPregnancy),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: period.isPregnancy
                          ? AppColors.deepPurple
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: period.isPregnancy
                            ? AppColors.deepPurple
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: period.isPregnancy
                        ? const Icon(Icons.check_rounded,
                            size: 12, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.pregnancyPeriodLabel,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final String Function(DateTime) fmt;

  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: date != null
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 3),
            Text(
              date != null ? fmt(date!) : l.chooseDateLabel,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: date != null
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
