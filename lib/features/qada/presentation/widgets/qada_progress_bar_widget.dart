import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/qada_progress.dart';
import '../../../prayer/domain/entities/prayer_record.dart';

/// Barre de progression générale + détail par prière (dépliable).
class QadaProgressBarWidget extends StatefulWidget {
  final QadaProgress progress;
  const QadaProgressBarWidget({super.key, required this.progress});

  @override
  State<QadaProgressBarWidget> createState() => _QadaProgressBarWidgetState();
}

class _QadaProgressBarWidgetState extends State<QadaProgressBarWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                      context.l10n.globalProgressLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${widget.progress.totalPrayersDone} / ${widget.progress.totalPrayersOwed} ${context.l10n.prayerPlural}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      widget.progress.progressPercent.toStringAsFixed(1) == '1.0'
                          ? '100%'
                          : '${(widget.progress.progressPercent * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: widget.progress.progressPercent,
                minHeight: 12,
              ),
            ),
            // Détail par prière (dépliable)
            if (_expanded) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ...PrayerName.values.map((name) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PrayerProgressRow(
                      prayerName: name,
                      done: widget.progress.prayersDoneByName[name] ?? 0,
                      owed: widget.progress.totalDaysOwed,
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrayerProgressRow extends StatelessWidget {
  final PrayerName prayerName;
  final int done;
  final int owed;
  const _PrayerProgressRow({
    required this.prayerName,
    required this.done,
    required this.owed,
  });

  String get _label => switch (prayerName) {
        PrayerName.fajr => 'Fajr',
        PrayerName.dhuhr => 'Dhuhr',
        PrayerName.asr => 'Asr',
        PrayerName.maghrib => 'Maghrib',
        PrayerName.isha => 'Isha',
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(_label,
              style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: owed == 0 ? 1.0 : (done / owed).clamp(0.0, 1.0),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          child: Text(
            '$done/$owed',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
          ),
        ),
      ],
    );
  }
}
