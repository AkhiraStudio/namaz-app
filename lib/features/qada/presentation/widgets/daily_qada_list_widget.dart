import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../prayer/domain/entities/prayer_record.dart';
import '../providers/qada_provider.dart';

/// Liste dépliante des prières à rattraper aujourd'hui, groupées par nom.
class DailyQadaListWidget extends ConsumerStatefulWidget {
  const DailyQadaListWidget({super.key});

  @override
  ConsumerState<DailyQadaListWidget> createState() =>
      _DailyQadaListWidgetState();
}

class _DailyQadaListWidgetState extends ConsumerState<DailyQadaListWidget> {
  bool _expanded = true;

  static String _label(PrayerName name) => switch (name) {
        PrayerName.fajr => 'Fajr',
        PrayerName.dhuhr => 'Dhuhr',
        PrayerName.asr => 'Asr',
        PrayerName.maghrib => 'Maghrib',
        PrayerName.isha => 'Isha',
      };

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(qadaProgressProvider);
    final countsAsync = ref.watch(todayQadaCountsProvider);
    final inDays = ref.watch(qadaObjectiveInDaysProvider);
    final dailyTarget = progressAsync.valueOrNull?.dailyTargetPrayers ?? 5;
    final daysToMakeUp = (dailyTarget / 5).ceil().clamp(1, 10);
    final l = context.l10n;

    final objectiveLabel = inDays
        ? l.makeupDaysCount(daysToMakeUp)
        : '$dailyTarget ${dailyTarget > 1 ? l.prayerPlural : l.prayerSingular}';

    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          // En-tête dépliable
          ListTile(
            onTap: () => setState(() => _expanded = !_expanded),
            leading: Icon(Icons.today_rounded, color: cs.primary, size: 20),
            title: Text(
              l.dailyObjectiveTitle(objectiveLabel),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: inDays ? l.showInPrayersLabel : l.showInDaysLabel,
                  child: GestureDetector(
                    onTap: () => ref
                        .read(qadaObjectiveInDaysProvider.notifier)
                        .state = !inDays,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.deepPurple.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        inDays ? l.daysUnit : l.prayerPlural,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            countsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: AppColors.deepPurple),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (counts) {
                final remaining =
                    progressAsync.valueOrNull?.remaining ?? 0;
                if (remaining == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.prayerEarly, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.dailyGoalReachedMessage,
                          style: const TextStyle(
                              color: AppColors.prayerEarly,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: PrayerName.values.map((name) {
                      final done = counts[name] ?? 0;
                      return _PrayerRow(
                        prayerName: name,
                        label: _label(name),
                        done: done,
                        target: daysToMakeUp,
                        onRecord: () => ref
                            .read(qadaProgressProvider.notifier)
                            .recordPrayer(name),
                        onRemove: () => ref
                            .read(qadaProgressProvider.notifier)
                            .removePrayer(name),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final PrayerName prayerName;
  final String label;
  final int done;
  final int target;
  final VoidCallback onRecord;
  final VoidCallback onRemove;

  const _PrayerRow({
    required this.prayerName,
    required this.label,
    required this.done,
    required this.target,
    required this.onRecord,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final allDone = done >= target;
    // Afficher au moins `target` boxes ; si l'utilisateur en a fait plus, les montrer toutes
    final displayCount = done > target ? done : target;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                done > 0 ? '$label ($done)' : label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: allDone
                      ? AppColors.prayerEarly
                      : cs.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              if (allDone)
                const Icon(Icons.check_circle_rounded,
                    size: 14, color: AppColors.prayerEarly),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // Boxes normales (cochées ou vides selon progression)
              ...List.generate(displayCount, (i) {
                final isDone = i < done;
                return GestureDetector(
                  onTap: isDone ? onRemove : onRecord,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDone
                          ? cs.primary
                          : cs.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDone ? cs.primary : cs.outlineVariant,
                      ),
                    ),
                    child: Center(
                      child: isDone
                          ? Icon(Icons.check_rounded,
                              size: 16, color: cs.onPrimary)
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                );
              }),

              // Box "+" apparaît uniquement quand l'objectif est atteint
              if (allDone)
                GestureDetector(
                  onTap: onRecord,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.deepPurple.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.deepPurple.withValues(alpha: 0.30),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: AppColors.deepPurple,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
