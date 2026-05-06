import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Barre de progression tricolore : Vert / Orange / Rouge.
///
/// Les trois segments sont toujours visibles simultanément :
///   • Vert  : les 30 premières minutes après l'adhan
///   • Orange: la période centrale
///   • Rouge : les 30 dernières minutes avant la prochaine prière
///
/// Un curseur blanc indique la position courante.
class TricolorProgressBarWidget extends StatelessWidget {
  final DateTime prayerStart;
  final DateTime prayerEnd;
  final DateTime now;

  const TricolorProgressBarWidget({
    super.key,
    required this.prayerStart,
    required this.prayerEnd,
    required this.now,
  });

  static const double _barHeight = 10.0;
  static const double _thumbSize = 16.0;
  static const Duration _zoneDuration = Duration(minutes: 30);

  @override
  Widget build(BuildContext context) {
    final totalSecs = prayerEnd.difference(prayerStart).inSeconds;
    if (totalSecs <= 0) return const SizedBox.shrink();

    final totalDur = Duration(seconds: totalSecs);
    final elapsedSecs =
        now.difference(prayerStart).inSeconds.clamp(0, totalSecs);
    final progress = elapsedSecs / totalSecs;

    // ── Calcul des fractions des 3 segments ──────────────────────────────────
    // Si la fenêtre est < 60 min, vert et rouge se partagent 50/50, pas d'orange.
    final half = totalDur ~/ 2;
    final greenDur =
        totalDur <= const Duration(minutes: 60) ? half : _zoneDuration;
    final redDur =
        totalDur <= const Duration(minutes: 60) ? half : _zoneDuration;
    final orangeDur = totalDur - greenDur - redDur;

    final greenFraction = greenDur.inSeconds / totalSecs;
    final orangeFraction = orangeDur.inSeconds / totalSecs;
    // redFraction = 1 - greenFraction - orangeFraction (reste)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final greenW = totalWidth * greenFraction;
            final orangeW = totalWidth * orangeFraction;
            final redW =
                totalWidth - greenW - orangeW; // évite les erreurs d'arrondi
            final thumbX = (totalWidth * progress)
                .clamp(_thumbSize / 2, totalWidth - _thumbSize / 2);

            return SizedBox(
              height: _thumbSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Les 3 segments ──────────────────────────────────────────
                  Positioned(
                    top: (_thumbSize - _barHeight) / 2,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          _Segment(
                            width: greenW,
                            color: AppColors.prayerEarly,
                            isFirst: true,
                          ),
                          if (orangeW > 0)
                            _Segment(
                              width: orangeW,
                              color: AppColors.prayerOnTime,
                            ),
                          _Segment(
                            width: redW,
                            color: AppColors.prayerLate,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Curseur blanc ───────────────────────────────────────────
                  Positioned(
                    top: 0,
                    left: thumbX - _thumbSize / 2,
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _fmt(prayerStart),
              style: const TextStyle(fontSize: 10, color: AppColors.textLight),
            ),
            Text(
              _fmt(prayerEnd),
              style: const TextStyle(fontSize: 10, color: AppColors.textLight),
            ),
          ],
        ),
      ],
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _Segment extends StatelessWidget {
  final double width;
  final Color color;
  final bool isFirst;
  final bool isLast;

  const _Segment({
    required this.width,
    required this.color,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: TricolorProgressBarWidget._barHeight,
      color: color,
    );
  }
}
