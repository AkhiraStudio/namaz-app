import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_loading_widget.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../providers/qibla_provider.dart';
import '../widgets/compass_widget.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyStatusBar(context);
  }

  void _applyStatusBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.creamBackground;
    final textMuted = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : AppColors.textSecondary;
    final qiblaAsync = ref.watch(qiblaDirectionProvider);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: qiblaAsync.when(
          loading: () => AppLoadingWidget(message: context.l10n.qiblaDetectionMessage),
          error: (e, _) => AppErrorWidget(
            message: e.toString(),
            onRetry: () => ref.invalidate(qiblaDirectionProvider),
          ),
          data: (direction) {
            final isFacing = direction.isFacingQibla;
            final angle = direction.displayAngle;
            final activeColor = isFacing ? AppColors.prayerEarly : AppColors.gold;

            final l = context.l10n;
            final String line1;
            final String line2;
            if (isFacing) {
              line1 = l.facingQiblaLine1;
              line2 = l.facingQiblaLine2;
            } else if (angle <= 180) {
              line1 = l.turnToLabel;
              line2 = l.rightDirection;
            } else {
              line1 = l.turnToLabel;
              line2 = l.leftDirection;
            }

            return Column(
              children: [
                // Bandeau calibration
                if (!direction.isCalibrated)
                  _CalibrationBanner(),

                // Corps principal
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CompassWidget(
                          qiblaAngle: angle,
                          isCalibrated: direction.isCalibrated,
                          isFacingQibla: isFacing,
                        ),
                        const SizedBox(height: 40),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              line1,
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              line2,
                              style: TextStyle(
                                color: activeColor,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: activeColor.withValues(alpha: 0.5),
                                    blurRadius: 24,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Indicateur calibration bas de page
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _CalibrationChip(isCalibrated: direction.isCalibrated),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Bandeau calibration ───────────────────────────────────────────────────────

class _CalibrationBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.prayerOnTime.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.prayerOnTime.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.prayerOnTime, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.calibrateCompassMessage,
              style: const TextStyle(
                  color: AppColors.prayerOnTime, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chip statut boussole ──────────────────────────────────────────────────────

class _CalibrationChip extends StatelessWidget {
  final bool isCalibrated;
  const _CalibrationChip({required this.isCalibrated});

  @override
  Widget build(BuildContext context) {
    final color = isCalibrated ? AppColors.prayerEarly : AppColors.prayerOnTime;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCalibrated
                ? Icons.gps_fixed_rounded
                : Icons.gps_not_fixed_rounded,
            color: color,
            size: 13,
          ),
          const SizedBox(width: 6),
          Text(
            isCalibrated ? context.l10n.compassCalibratedLabel : context.l10n.calibrationRecommendedLabel,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
