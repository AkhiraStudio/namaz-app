import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../shared/extensions/datetime_extensions.dart';
import '../../domain/entities/prayer_time.dart';

class NightThirdCalculatorWidget extends StatefulWidget {
  final PrayerTime times;
  const NightThirdCalculatorWidget({super.key, required this.times});

  @override
  State<NightThirdCalculatorWidget> createState() =>
      _NightThirdCalculatorWidgetState();
}

class _NightThirdCalculatorWidgetState
    extends State<NightThirdCalculatorWidget> {
  bool _alarmSet = false;
  bool _loading = false;

  late final DateTime _fajrTomorrow;
  late final DateTime _firstThirdStart;  // = Isha
  late final DateTime _secondThirdStart;
  late final DateTime _thirdThirdStart;
  late final DateTime _thirdThirdEnd;    // = Fajr demain

  @override
  void initState() {
    super.initState();
    final f = widget.times.fajr;
    _fajrTomorrow = DateTime(f.year, f.month, f.day + 1, f.hour, f.minute);
    _firstThirdStart = widget.times.isha;
    _secondThirdStart = widget.times.secondThirdOfNight(_fajrTomorrow);
    _thirdThirdStart = widget.times.lastThirdOfNight(_fajrTomorrow);
    _thirdThirdEnd = _fajrTomorrow;
    _checkAlarmStatus();
  }

  Future<void> _checkAlarmStatus() async {
    final scheduled = await NotificationService.isNightThirdScheduled();
    if (mounted) setState(() => _alarmSet = scheduled);
  }

  Future<void> _toggleAlarm() async {
    if (_loading) return;
    setState(() => _loading = true);
    if (_alarmSet) {
      await NotificationService.cancelNightThirdAlarm();
      setState(() => _alarmSet = false);
    } else {
      await NotificationService.scheduleNightThirdAlarm(_thirdThirdStart);
      setState(() => _alarmSet = true);
    }
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_alarmSet
              ? context.l10n.alarmScheduledAt(_thirdThirdStart.timeHHmm)
              : context.l10n.alarmCancelledLabel),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Détermine dans quel tiers on se trouve actuellement.
  int get _currentThird {
    final now = DateTime.now();
    if (now.isAfter(_thirdThirdStart) && now.isBefore(_thirdThirdEnd)) return 3;
    if (now.isAfter(_secondThirdStart) && now.isBefore(_thirdThirdStart)) {
      return 2;
    }
    if (now.isAfter(_firstThirdStart) && now.isBefore(_secondThirdStart)) {
      return 1;
    }
    return 0; // pas encore la nuit
  }

  @override
  Widget build(BuildContext context) {
    final active = _currentThird;

    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Les 3 tiers ────────────────────────────────────────────────────
          _ThirdRow(
            index: 1,
            label: context.l10n.firstThirdLabel,
            start: _firstThirdStart,
            end: _secondThirdStart,
            isActive: active == 1,
          ),
          const SizedBox(height: 6),
          _ThirdRow(
            index: 2,
            label: context.l10n.secondThirdLabel,
            start: _secondThirdStart,
            end: _thirdThirdStart,
            isActive: active == 2,
          ),
          const SizedBox(height: 6),

          // 3ème tiers avec bouton alarme
          Builder(builder: (context) {
            final cs3 = Theme.of(context).colorScheme;
            return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: active == 3
                  ? AppColors.gold.withValues(alpha: 0.12)
                  : _alarmSet
                      ? cs3.primary.withValues(alpha: 0.08)
                      : cs3.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active == 3
                    ? AppColors.gold
                    : _alarmSet
                        ? cs3.primary
                        : cs3.outlineVariant,
                width: active == 3 ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Icône
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star_rounded,
                      color: AppColors.gold, size: 16),
                ),
                const SizedBox(width: 10),
                // Texte
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            context.l10n.thirdThirdLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: active == 3
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: active == 3
                                  ? AppColors.gold
                                  : cs3.onSurface,
                            ),
                          ),
                          if (active == 3) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(context.l10n.nowLabel,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '${_thirdThirdStart.timeHHmm} → ${_thirdThirdEnd.timeHHmm}',
                        style: TextStyle(
                            fontSize: 12, color: cs3.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                // Bouton alarme
                GestureDetector(
                  onTap: _loading ? null : _toggleAlarm,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _alarmSet
                          ? cs3.primary
                          : cs3.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: _loading
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(
                            _alarmSet
                                ? Icons.alarm_on_rounded
                                : Icons.alarm_add_rounded,
                            color: _alarmSet
                                ? cs3.onPrimary
                                : cs3.primary,
                            size: 18,
                          ),
                  ),
                ),
              ],
            ),
          );
          }),
        ],
      ),
    );
  }

}

// ── Ligne d'un tiers (1er et 2ème) ───────────────────────────────────────────

class _ThirdRow extends StatelessWidget {
  final int index;
  final String label;
  final DateTime start;
  final DateTime end;
  final bool isActive;

  const _ThirdRow({
    required this.index,
    required this.label,
    required this.start,
    required this.end,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isActive
            ? cs.primary.withValues(alpha: 0.10)
            : cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? cs.primary : cs.outlineVariant,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: cs.primary),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive ? cs.primary : cs.onSurface,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(context.l10n.nowLabel,
                            style: TextStyle(
                                color: cs.onPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${start.timeHHmm} → ${end.timeHHmm}',
                  style: TextStyle(
                      fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
