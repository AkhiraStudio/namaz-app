import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../premium/presentation/widgets/premium_gate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/prayer_record.dart';
import '../providers/prayer_record_provider.dart';
import '../widgets/post_prayer_checklist_widget.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/profile_provider.dart';

class PrayerDetailScreen extends ConsumerWidget {
  final String prayerId;
  const PrayerDetailScreen({super.key, required this.prayerId});

  PrayerName? get _prayerName => switch (prayerId) {
        'fajr' => PrayerName.fajr,
        'dhuhr' => PrayerName.dhuhr,
        'asr' => PrayerName.asr,
        'maghrib' => PrayerName.maghrib,
        'isha' => PrayerName.isha,
        _ => null,
      };

  String get _displayName => switch (prayerId) {
        'fajr' => 'Fajr',
        'dhuhr' => 'Dhuhr',
        'asr' => 'Asr',
        'maghrib' => 'Maghrib',
        'isha' => 'Isha',
        _ => prayerId,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final prayerName = _prayerName;
    final notifier = ref.watch(prayerRecordProvider.notifier);
    final profile = ref.watch(profileProvider).valueOrNull;
    final isFemale = profile?.gender == UserGender.female;
    final alreadyRecorded =
        prayerName != null ? notifier.isPrayed(prayerName) : false;
    final currentStatus =
        prayerName != null ? notifier.statusFor(prayerName) : null;

    return Scaffold(
      appBar: AppBar(title: Text(_displayName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (alreadyRecorded && currentStatus != null) ...[
              _AlreadyRecordedBanner(status: currentStatus),
              const SizedBox(height: 24),
              Text(l.editStatusTitle,
                  style: Theme.of(context).textTheme.titleMedium),
            ] else ...[
              Text(l.validatePrayerTitle,
                  style: Theme.of(context).textTheme.headlineMedium),
            ],
            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _StatusButton(
                  label: l.prayedEarlyButton,
                  color: AppColors.prayerEarly,
                  isSelected: currentStatus == PrayerStatus.early,
                  onTap: prayerName != null
                      ? () => _record(context, ref, prayerName, PrayerStatus.early)
                      : null,
                ),
                _StatusButton(
                  label: l.prayedOnTimeButton,
                  color: AppColors.prayerOnTime,
                  isSelected: currentStatus == PrayerStatus.onTime,
                  onTap: prayerName != null
                      ? () => _record(context, ref, prayerName, PrayerStatus.onTime)
                      : null,
                ),
                _StatusButton(
                  label: l.prayedLateButton,
                  color: AppColors.prayerLate,
                  isSelected: currentStatus == PrayerStatus.late,
                  onTap: prayerName != null
                      ? () => _record(context, ref, prayerName, PrayerStatus.late)
                      : null,
                ),
                _StatusButton(
                  label: l.missedButton,
                  color: AppColors.prayerMissed,
                  isSelected: currentStatus == PrayerStatus.missed,
                  onTap: prayerName != null
                      ? () => _record(context, ref, prayerName, PrayerStatus.missed)
                      : null,
                ),
                if (isFemale)
                  _StatusButton(
                    label: l.menstruationButton,
                    color: AppColors.prayerMenstruation,
                    isSelected: currentStatus == PrayerStatus.menstruation,
                    onTap: prayerName != null
                        ? () => _record(context, ref, prayerName, PrayerStatus.menstruation)
                        : null,
                  ),
              ],
            ),

            if (prayerName == PrayerName.fajr ||
                prayerName == PrayerName.asr) ...[
              const SizedBox(height: 28),
              PremiumReplaceGate(
                featureLabel: prayerName == PrayerName.fajr
                    ? l.morningAdhkarsTitle
                    : l.eveningAdhkarsTitle,
                child: _AdhkarBanner(
                  type: prayerName == PrayerName.fajr ? 'morning' : 'evening',
                  onTap: () => context.pushNamed(
                    RouteNames.adhkar,
                    pathParameters: {
                      'type': prayerName == PrayerName.fajr
                          ? 'morning'
                          : 'evening',
                    },
                  ),
                ),
              ),
            ],

            if (alreadyRecorded &&
                currentStatus != PrayerStatus.missed &&
                currentStatus != PrayerStatus.menstruation) ...[
              const SizedBox(height: 32),
              Text(l.afterPrayerTitle,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              PostPrayerChecklistWidget(prayerName: prayerId),
              if (prayerName == PrayerName.isha) ...[
                const SizedBox(height: 16),
                PremiumReplaceGate(
                  featureLabel: l.sleepAdhkarsTitle,
                  child: _AdhkarBanner(
                    type: 'sleep',
                    onTap: () => context.pushNamed(
                      RouteNames.adhkar,
                      pathParameters: {'type': 'sleep'},
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _record(BuildContext context, WidgetRef ref,
      PrayerName name, PrayerStatus status) async {
    await ref.read(prayerRecordProvider.notifier).recordPrayer(name, status);
    if (context.mounted && status == PrayerStatus.missed) {
      context.pop();
    }
  }
}

class _AlreadyRecordedBanner extends StatelessWidget {
  final PrayerStatus status;
  const _AlreadyRecordedBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final (color, label, icon) = switch (status) {
      PrayerStatus.early => (AppColors.prayerEarly, l.prayedEarlyButton, Icons.alarm_rounded),
      PrayerStatus.onTime => (AppColors.prayerOnTime, l.prayedOnTimeLabel, Icons.check_rounded),
      PrayerStatus.late => (AppColors.prayerLate, l.prayedLateLabel, Icons.timelapse_rounded),
      PrayerStatus.missed => (AppColors.prayerMissed, l.missedPrayerLabel, Icons.cancel_outlined),
      PrayerStatus.menstruation => (AppColors.prayerMenstruation, l.menstruationButton, Icons.water_drop_rounded),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          const Spacer(),
          Text(l.recordedLabel,
              style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12)),
        ],
      ),
    );
  }
}

class _AdhkarBanner extends StatelessWidget {
  final String type; // 'morning' | 'evening' | 'sleep'
  final VoidCallback onTap;

  const _AdhkarBanner({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final color = type == 'morning'
        ? AppColors.prayerEarly
        : type == 'sleep'
            ? AppColors.deepPurple
            : AppColors.gold;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(
                type == 'morning'
                    ? Icons.wb_sunny_rounded
                    : type == 'sleep'
                        ? Icons.bedtime_rounded
                        : Icons.nights_stay_rounded,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    switch (type) {
                      'morning' => l.morningAdhkarsTitle,
                      'sleep' => l.sleepAdhkarsTitle,
                      _ => l.eveningAdhkarsTitle,
                    },
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.adhkarProgressHint,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _StatusButton({
    required this.label,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
