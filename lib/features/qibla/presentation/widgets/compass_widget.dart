import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CompassWidget extends StatefulWidget {
  final double qiblaAngle;
  final bool isCalibrated;
  final bool isFacingQibla;

  const CompassWidget({
    super.key,
    required this.qiblaAngle,
    required this.isCalibrated,
    required this.isFacingQibla,
  });

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget>
    with SingleTickerProviderStateMixin {
  static const double _size = 280.0;
  static const double _outerRadius = 118.0;
  static const double _centerRadius = 60.0;

  late AnimationController _ctrl;
  late Animation<double> _anim;

  // On garde un angle "accumulé" pour gérer le passage 359°→0° sans sauts.
  double _accumulated = 0.0;

  @override
  void initState() {
    super.initState();
    _accumulated = widget.qiblaAngle;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _anim = Tween<double>(begin: _accumulated, end: _accumulated)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(CompassWidget old) {
    super.didUpdateWidget(old);
    if (old.qiblaAngle == widget.qiblaAngle) return;

    final current = _anim.value;

    // Chemin le plus court vers le nouvel angle (gère 359°→1° = +2° pas -358°)
    double diff = widget.qiblaAngle - (current % 360 + 360) % 360;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;

    _accumulated = current + diff;

    _anim = Tween<double>(begin: current, end: _accumulated).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final angle = (_anim.value % 360 + 360) % 360;
        final angleRad = angle * math.pi / 180;
        final kaabaX = _size / 2 + _outerRadius * math.sin(angleRad);
        final kaabaY = _size / 2 - _outerRadius * math.cos(angleRad);
        final isFacing = widget.isFacingQibla;
        final color =
            isFacing ? AppColors.prayerEarly : AppColors.gold;

        // Affiche le chemin le plus court en degrés (0–180)
        final int displayDeg = angle <= 180
            ? angle.round()
            : (360 - angle).round();

        return SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(_size, _size),
                painter: _RingPainter(
                  angle: angle,
                  color: color,
                  isFacing: isFacing,
                ),
              ),

              // Cercle central
              Positioned(
                left: _size / 2 - _centerRadius,
                top: _size / 2 - _centerRadius,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: _centerRadius * 2,
                  height: _centerRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.55),
                        blurRadius: 48,
                        spreadRadius: 12,
                      ),
                      BoxShadow(
                        color: color.withValues(alpha: 0.25),
                        blurRadius: 80,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$displayDeg°',
                      style: TextStyle(
                        color: isFacing
                            ? Colors.white
                            : AppColors.darkBackground,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),

              // Icône Kaaba
              Positioned(
                left: kaabaX - 18,
                top: kaabaY - 18,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFacing ? color : Colors.white,
                    boxShadow: isFacing
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.6),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.mosque_rounded,
                    color: isFacing ? Colors.white : AppColors.deepPurple,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double angle;
  final Color color;
  final bool isFacing;

  const _RingPainter({
    required this.angle,
    required this.color,
    required this.isFacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const r = 118.0;

    if (isFacing) {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = color.withValues(alpha: 0.8)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );
    } else {
      final dotPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.20)
        ..style = PaintingStyle.fill;
      for (int i = 0; i < 36; i++) {
        final a = i * 10 * math.pi / 180;
        canvas.drawCircle(
          Offset(center.dx + r * math.sin(a), center.dy - r * math.cos(a)),
          3.0,
          dotPaint,
        );
      }

      final clockwise = angle <= 180;
      final sweepAngle = clockwise
          ? angle * math.pi / 180
          : -(360 - angle) * math.pi / 180;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -math.pi / 2,
        sweepAngle,
        false,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      _drawArrow(canvas, center, r, -math.pi / 2 + sweepAngle, clockwise);
    }
  }

  void _drawArrow(
      Canvas canvas, Offset center, double r, double endRad, bool clockwise) {
    const s = 9.0;
    final px = center.dx + r * math.cos(endRad);
    final py = center.dy + r * math.sin(endRad);
    final t = clockwise ? endRad + math.pi / 2 : endRad - math.pi / 2;

    canvas.drawPath(
      Path()
        ..moveTo(px, py)
        ..lineTo(px + s * math.cos(t + 2.6), py + s * math.sin(t + 2.6))
        ..lineTo(px + s * math.cos(t - 2.6), py + s * math.sin(t - 2.6))
        ..close(),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.angle != angle || old.isFacing != isFacing || old.color != color;
}
