import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/prayer_record.dart';
import '../providers/prayer_record_provider.dart';
import '../providers/current_prayer_provider.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/profile_provider.dart';

class PrayerTimeCardWidget extends ConsumerStatefulWidget {
  final String prayerName;
  final DateTime prayerTime;
  final DateTime nextPrayerTime;

  const PrayerTimeCardWidget({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.nextPrayerTime,
  });

  @override
  ConsumerState<PrayerTimeCardWidget> createState() =>
      _PrayerTimeCardWidgetState();
}

class _PrayerTimeCardWidgetState extends ConsumerState<PrayerTimeCardWidget> {
  bool _checklistExpanded = false;

  // Compteurs tasbih (état local, remis à zéro chaque jour naturellement)
  int _subhanAllah = 0;
  int _alhamdulillah = 0;
  int _allahuAkbar = 0;
  bool _ayatAlKursi = false;

  PrayerName? get _prayerEnum => switch (widget.prayerName) {
        'Fajr' => PrayerName.fajr,
        'Dhuhr' => PrayerName.dhuhr,
        'Asr' => PrayerName.asr,
        'Maghrib' => PrayerName.maghrib,
        'Isha' => PrayerName.isha,
        _ => null,
      };

  void _increment(int current, void Function(int) onChanged) {
    if (current < 33) {
      HapticFeedback.lightImpact();
      onChanged(current + 1);
    }
  }

  void _showStatusPicker(BuildContext context, PrayerName prayerEnum,
      PrayerStatus? current, bool isFemale) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatusPickerSheet(
        prayerName: widget.prayerName,
        currentStatus: current,
        isFemale: isFemale,
        onSelect: (status) async {
          Navigator.pop(context);
          await ref
              .read(prayerRecordProvider.notifier)
              .recordPrayer(prayerEnum, status);
          // Ouvre la checklist automatiquement si prière effectuée (hors manquée/menstrues)
          if (status != PrayerStatus.missed &&
              status != PrayerStatus.menstruation &&
              mounted) {
            setState(() => _checklistExpanded = true);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(prayerRecordProvider).valueOrNull ?? {};
    final currentPrayer = ref.watch(currentPrayerProvider).valueOrNull;
    final profile = ref.watch(profileProvider).valueOrNull;
    final isFemale = profile?.gender == UserGender.female;
    final prayerEnum = _prayerEnum;
    final record = prayerEnum != null ? records[prayerEnum] : null;
    final isRecorded = record != null;
    final isCurrent = currentPrayer?.prayerName == widget.prayerName;
    final showChecklist = isRecorded &&
        record.status != PrayerStatus.missed &&
        record.status != PrayerStatus.menstruation;

    final cs = Theme.of(context).colorScheme;
    final baseAlpha = isCurrent ? 0.50 : 0.20;
    final gradient = _prayerGradient(widget.prayerName, baseAlpha);
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? AppColors.prayerAccent(widget.prayerName)
              : cs.outlineVariant,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // ── Ligne principale ─────────────────────────────────────────────
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: _PrayerIcon(
                prayerName: widget.prayerName, record: record),
            title: Text(
              widget.prayerName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight:
                        isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.prayerTime.hour.toString().padLeft(2, '0')}:'
                  '${widget.prayerTime.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: cs.primary),
                ),
                if (widget.prayerName == 'Fajr')
                  Text(
                    '${context.l10n.sunriseLabel} · '
                    '${widget.nextPrayerTime.hour.toString().padLeft(2, '0')}:'
                    '${widget.nextPrayerTime.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge statut (tappable pour modifier) ou bouton +
                GestureDetector(
                  onTap: prayerEnum != null
                      ? () => _showStatusPicker(
                          context, prayerEnum, record?.status, isFemale)
                      : null,
                  child: isRecorded
                      ? _StatusBadge(status: record.status)
                      : _AddBadge(),
                ),
                // Chevron checklist (visible uniquement si prière faite)
                if (showChecklist)
                  GestureDetector(
                    onTap: () => setState(
                        () => _checklistExpanded = !_checklistExpanded),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        _checklistExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: cs.onSurfaceVariant,
                        size: 22,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Checklist déroulable ─────────────────────────────────────────
          if (showChecklist && _checklistExpanded) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.postPrayerDhikrLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                  ),
                  const SizedBox(height: 10),
                  _TasbihRow(
                    arabic: 'سُبْحَانَ اللهِ',
                    label: 'SubhanAllah',
                    count: _subhanAllah,
                    onTap: () => setState(
                        () => _increment(_subhanAllah, (v) => _subhanAllah = v)),
                  ),
                  const SizedBox(height: 8),
                  _TasbihRow(
                    arabic: 'الْحَمْدُ لِلَّهِ',
                    label: 'Al-Hamdulillah',
                    count: _alhamdulillah,
                    onTap: () => setState(() =>
                        _increment(_alhamdulillah, (v) => _alhamdulillah = v)),
                  ),
                  const SizedBox(height: 8),
                  _TasbihRow(
                    arabic: 'اللهُ أَكْبَر',
                    label: 'Allahu Akbar',
                    count: _allahuAkbar,
                    onTap: () => setState(() =>
                        _increment(_allahuAkbar, (v) => _allahuAkbar = v)),
                  ),
                  const SizedBox(height: 8),
                  // Ayat al Kursi — 1x (checkbox)
                  _AyatAlKursiRow(
                    checked: _ayatAlKursi,
                    onToggle: () {
                      HapticFeedback.lightImpact();
                      setState(() => _ayatAlKursi = !_ayatAlKursi);
                    },
                  ),

                  // Bouton adhkars du matin (Fajr) / du soir (Asr) / du coucher (Isha)
                  if (widget.prayerName == 'Fajr' ||
                      widget.prayerName == 'Asr' ||
                      widget.prayerName == 'Isha') ...[
                    const SizedBox(height: 12),
                    _AdhkarButton(
                      type: widget.prayerName == 'Fajr'
                          ? 'morning'
                          : widget.prayerName == 'Isha'
                              ? 'sleep'
                              : 'evening',
                      onTap: () => context.pushNamed(
                        RouteNames.adhkar,
                        pathParameters: {
                          'type': widget.prayerName == 'Fajr'
                              ? 'morning'
                              : widget.prayerName == 'Isha'
                                  ? 'sleep'
                                  : 'evening',
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Dégradé de fond par prière ────────────────────────────────────────────────

const _prayerColorPairs = {
  'Fajr'    : (Color(0xFF2E3F7A), Color(0xFF1A2550)),
  'Dhuhr'   : (Color(0xFFB89A5E), Color(0xFF8C7040)),
  'Asr'     : (Color(0xFFB87050), Color(0xFF8C5038)),
  'Maghrib' : (Color(0xFF7A3F6A), Color(0xFF502848)),
  'Isha'    : (Color(0xFF2E1F50), Color(0xFF1A1030)),
};

LinearGradient _prayerGradient(String prayerName, double alpha) {
  final (c1, c2) = _prayerColorPairs[prayerName] ??
      (const Color(0xFF5A5A7A), const Color(0xFF3A3A5A));
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      c1.withValues(alpha: alpha),
      c2.withValues(alpha: alpha * 0.5),
    ],
  );
}

// ── Icône de prière avec animation de validation ──────────────────────────────

class _PrayerIcon extends StatelessWidget {
  final String prayerName;
  final PrayerRecord? record;
  const _PrayerIcon({required this.prayerName, this.record});

  static IconData _icon(String name) => switch (name) {
        'Fajr' => Icons.brightness_4_outlined,
        'Dhuhr' => Icons.wb_sunny_outlined,
        'Asr' => Icons.wb_cloudy_outlined,
        'Maghrib' => Icons.wb_twilight,
        'Isha' => Icons.nightlight_outlined,
        _ => Icons.access_time_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isRecorded = record != null;

    final statusColor = switch (record?.status) {
      PrayerStatus.early => AppColors.prayerEarly,
      PrayerStatus.onTime => AppColors.prayerOnTime,
      PrayerStatus.late => AppColors.prayerLate,
      PrayerStatus.missed => AppColors.prayerMissed,
      PrayerStatus.menstruation => AppColors.prayerMenstruation,
      null => cs.onSurfaceVariant,
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.elasticOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: Tween<double>(begin: 0.4, end: 1.0).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Container(
        key: ValueKey(record?.status),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: isRecorded ? 0.15 : 0.07),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isRecorded ? Icons.check_rounded : _icon(prayerName),
          color: statusColor,
          size: 20,
        ),
      ),
    );
  }
}

// ── Badge statut enregistré ───────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final PrayerStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final (color, label) = switch (status) {
      PrayerStatus.early => (AppColors.prayerEarly, l.earlyLabel),
      PrayerStatus.onTime => (AppColors.prayerOnTime, l.prayedOnTimeButton),
      PrayerStatus.late => (AppColors.prayerLate, l.lateLabel),
      PrayerStatus.missed => (AppColors.prayerMissed, l.missedButton),
      PrayerStatus.menstruation => (AppColors.prayerMenstruation, l.menstruationButton),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Icon(Icons.edit_rounded, size: 11, color: color.withValues(alpha: 0.7)),
        ],
      ),
    );
  }
}

// ── Bouton + (non enregistré) ─────────────────────────────────────────────────

class _AddBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_rounded, size: 14, color: cs.primary),
          const SizedBox(width: 4),
          Text(context.l10n.validateButton,
              style: TextStyle(
                  fontSize: 12,
                  color: cs.primary,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Bottom sheet sélecteur de statut ─────────────────────────────────────────

class _StatusPickerSheet extends StatelessWidget {
  final String prayerName;
  final PrayerStatus? currentStatus;
  final bool isFemale;
  final void Function(PrayerStatus) onSelect;

  const _StatusPickerSheet({
    required this.prayerName,
    required this.currentStatus,
    required this.isFemale,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poignée
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            prayerName,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.howDidYouPrayLabel,
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          ...PrayerStatus.values
              .where((s) =>
                  s != PrayerStatus.menstruation || isFemale)
              .map((status) {
            final l = context.l10n;
            final (color, label, icon) = switch (status) {
              PrayerStatus.early => (
                  AppColors.prayerEarly,
                  l.prayedEarlyDescription,
                  Icons.alarm_rounded
                ),
              PrayerStatus.onTime => (
                  AppColors.prayerOnTime,
                  l.prayedOnTimeDescription,
                  Icons.check_circle_outline_rounded
                ),
              PrayerStatus.late => (
                  AppColors.prayerLate,
                  l.prayedLateDescription,
                  Icons.timelapse_rounded
                ),
              PrayerStatus.missed => (
                  AppColors.prayerMissed,
                  l.missedButton,
                  Icons.cancel_outlined
                ),
              PrayerStatus.menstruation => (
                  AppColors.prayerMenstruation,
                  l.menstruationButton,
                  Icons.water_drop_rounded
                ),
            };
            final isSelected = currentStatus == status;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onSelect(status),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.12)
                        : Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? color : Theme.of(context).colorScheme.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: color, size: 22),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_rounded, color: color, size: 18),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
        ),
      ),
    );
  }
}

// ── Ligne tasbih (compteur 33x) ───────────────────────────────────────────────

class _TasbihRow extends StatelessWidget {
  final String arabic;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _TasbihRow({
    required this.arabic,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = count >= 33;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isComplete
              ? AppColors.prayerEarly.withValues(alpha: 0.07)
              : AppColors.creamBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isComplete ? AppColors.prayerEarly : AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(arabic,
                      style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 16,
                          color: AppColors.deepPurple)),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            // Compteur
            Text(
              '$count/33',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    isComplete ? AppColors.prayerEarly : AppColors.deepPurple,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isComplete
                  ? Icons.check_circle_rounded
                  : Icons.add_circle_outline_rounded,
              color:
                  isComplete ? AppColors.prayerEarly : AppColors.lightPurple,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ligne Ayat al Kursi (1x checkbox) ────────────────────────────────────────

// ── Bouton adhkars du matin / du soir ────────────────────────────────────────

class _AdhkarButton extends StatelessWidget {
  final String type; // 'morning' | 'evening' | 'sleep'
  final VoidCallback onTap;

  const _AdhkarButton({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(
              type == 'morning'
                  ? Icons.wb_sunny_rounded
                  : type == 'sleep'
                      ? Icons.bedtime_rounded
                      : Icons.nights_stay_rounded,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                switch (type) {
                  'morning' => context.l10n.morningAdhkarsTitle,
                  'sleep'   => context.l10n.sleepAdhkarsTitle,
                  _         => context.l10n.eveningAdhkarsTitle,
                },
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

class _AyatAlKursiRow extends StatelessWidget {
  final bool checked;
  final VoidCallback onToggle;

  const _AyatAlKursiRow({required this.checked, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: checked
              ? AppColors.prayerEarly.withValues(alpha: 0.07)
              : AppColors.creamBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: checked ? AppColors.prayerEarly : AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'آيَةُ الْكُرْسِيِّ',
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        color: AppColors.deepPurple),
                  ),
                  Text(
                    context.l10n.ayatAlKursiLabel,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              checked
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: checked ? AppColors.prayerEarly : AppColors.lightPurple,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
