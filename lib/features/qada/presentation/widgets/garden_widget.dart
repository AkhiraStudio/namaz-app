import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

// ── Mode Solaire ─────────────────────────────────────────────────────────────

class _SolarTheme {
  final Color skyTop;
  final Color skyMid;
  final Color horizonGlow;
  final bool isNight;
  final Color celestialColor;

  const _SolarTheme({
    required this.skyTop,
    required this.skyMid,
    required this.horizonGlow,
    required this.isNight,
    required this.celestialColor,
  });

  static _SolarTheme current() {
    final h = DateTime.now().hour;
    if (h >= 4 && h < 6) {
      return const _SolarTheme(
        skyTop: Color(0xFF1A237E), skyMid: Color(0xFFFF8A65),
        horizonGlow: Color(0xFFFFCC80), isNight: false,
        celestialColor: Color(0xFFFF8A65),
      );
    } else if (h >= 6 && h < 10) {
      return const _SolarTheme(
        skyTop: Color(0xFF64B5F6), skyMid: Color(0xFFB3E5FC),
        horizonGlow: Color(0xFFFFF9C4), isNight: false,
        celestialColor: Color(0xFFFFE082),
      );
    } else if (h >= 10 && h < 14) {
      return const _SolarTheme(
        skyTop: Color(0xFF1E88E5), skyMid: Color(0xFF64B5F6),
        horizonGlow: Color(0xFFE3F2FD), isNight: false,
        celestialColor: Color(0xFFFFF9C4),
      );
    } else if (h >= 14 && h < 17) {
      return const _SolarTheme(
        skyTop: Color(0xFF42A5F5), skyMid: Color(0xFFFFCC80),
        horizonGlow: Color(0xFFFFE0B2), isNight: false,
        celestialColor: Color(0xFFFFD54F),
      );
    } else if (h >= 17 && h < 20) {
      return const _SolarTheme(
        skyTop: Color(0xFF4A148C), skyMid: Color(0xFFFF6F00),
        horizonGlow: Color(0xFFFF8F00), isNight: false,
        celestialColor: Color(0xFFFF8F00),
      );
    } else {
      return const _SolarTheme(
        skyTop: Color(0xFF0D0221), skyMid: Color(0xFF1A237E),
        horizonGlow: Color(0xFF311B92), isNight: true,
        celestialColor: Color(0xFFF5F5F5),
      );
    }
  }
}

// ── GardenWidget (public) ─────────────────────────────────────────────────────

class GardenWidget extends StatefulWidget {
  final double progressPercent; // 0.0 à 1.0
  final int gardenStage;        // 0 à 10

  const GardenWidget({
    super.key,
    required this.progressPercent,
    required this.gardenStage,
  });

  @override
  State<GardenWidget> createState() => _GardenWidgetState();
}

class _GardenWidgetState extends State<GardenWidget> {
  bool _isPreviewing = false;
  Timer? _previewTimer;

  void _startPreview() {
    HapticFeedback.mediumImpact();
    _previewTimer?.cancel();
    setState(() => _isPreviewing = true);
    _previewTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isPreviewing = false);
    });
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = _isPreviewing ? 1.0 : widget.progressPercent;
    final sub = (pct * 100).floor().clamp(0, 100);

    return Stack(
      children: [
        _GardenCanvas(subStage: sub),
        // Bouton aperçu (maintenir appuyé)
        Positioned(
          bottom: 10,
          right: 10,
          child: GestureDetector(
            onLongPressStart: (_) => _startPreview(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _isPreviewing
                    ? AppColors.gold.withValues(alpha: 0.90)
                    : Colors.black.withValues(alpha: 0.38),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.65)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isPreviewing ? Icons.auto_awesome : Icons.landscape_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isPreviewing ? 'Aperçu…' : 'Aperçu',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Canvas principal ──────────────────────────────────────────────────────────

class _GardenCanvas extends StatelessWidget {
  final int subStage; // 0-100

  const _GardenCanvas({required this.subStage});

  bool _at(int n) => subStage >= n;
  int get _major => (subStage ~/ 10).clamp(0, 10);

  Color get _groundColor {
    if (_at(70)) return const Color(0xFF1B5E20);
    if (_at(20)) return const Color(0xFF2E7D32);
    if (_at(10)) return const Color(0xFF3E2723);
    return const Color(0xFF8D6E63);
  }

  @override
  Widget build(BuildContext context) {
    final solar = _SolarTheme.current();

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [solar.skyTop, solar.skyMid, _groundColor],
          stops: const [0.0, 0.62, 1.0],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // ── Horizon glow ──
            Positioned(
              bottom: 55,
              left: 0,
              right: 0,
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    solar.horizonGlow.withValues(alpha: 0.25),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),

            // ══ LAYER 0: Sol de base ════════════════════════════════════════
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: _groundColor,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
              ),
            ),

            // ══ LAYER 1: Sol fertile (10%) ══════════════════════════════════
            if (_at(10)) ...[
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF4E342E), Color(0xFF3E2723)],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                ),
              ),
              // 11-19%: Petits éléments au sol
              if (_at(11)) _pebble(left: 30, bottom: 46, size: 8),
              if (_at(12)) _pebble(right: 48, bottom: 42, size: 6),
              if (_at(13)) _pebble(left: 95, bottom: 48, size: 10),
              if (_at(14)) _leaf(left: 58, bottom: 52, color: Colors.orange.shade700),
              if (_at(15)) _leaf(right: 72, bottom: 50, color: Colors.brown.shade400),
              if (_at(16)) _leaf(left: 135, bottom: 54, color: Colors.red.shade700),
              if (_at(17)) _pebble(right: 110, bottom: 44, size: 7),
              if (_at(18)) _leaf(left: 72, bottom: 56, color: Colors.yellow.shade800),
              if (_at(19)) _pebble(left: 165, bottom: 46, size: 9),
            ],

            // ══ LAYER 2: Herbe (20%) ════════════════════════════════════════
            if (_at(20)) ...[
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Container(
                  height: 16,
                  color: const Color(0xFF388E3C).withValues(alpha: 0.85),
                ),
              ),
              if (_at(21)) _grassTuft(left: 18, bottom: 60),
              if (_at(22)) _grassTuft(right: 22, bottom: 60),
              if (_at(23)) _grassTuft(left: 82, bottom: 62),
              if (_at(24)) _mushroom(left: 115, bottom: 58),
              if (_at(25)) _mushroom(right: 82, bottom: 58),
              if (_at(26)) _grassTuft(right: 144, bottom: 62),
              if (_at(27)) _grassTuft(left: 162, bottom: 60),
              if (_at(28)) _grassTuft(left: 48, bottom: 64),
              if (_at(29)) _mushroom(right: 38, bottom: 62),
            ],

            // ══ LAYER 3: Ruisseau (30%) ═════════════════════════════════════
            if (_at(30)) ...[
              Positioned(
                bottom: 60,
                left: 72,
                right: 72,
                child: Container(
                  height: 13,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.lightBlue.shade200,
                      Colors.blue.shade300,
                      Colors.lightBlue.shade200,
                    ]),
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              if (_at(31)) _waterPebble(left: 82, bottom: 64),
              if (_at(32)) _waterPebble(right: 88, bottom: 64),
              if (_at(33)) _lilyPad(left: 98, bottom: 62),
              if (_at(34)) _lilyPad(right: 100, bottom: 62),
              if (_at(35)) _smallFish(left: 112, bottom: 63),
              if (_at(36)) _reed(left: 76, bottom: 68),
              if (_at(37)) _reed(right: 82, bottom: 68),
              if (_at(38)) _dragonfly(left: 104, bottom: 76),
              if (_at(39)) _waterRipple(left: 124, bottom: 62),
            ],

            // ══ LAYER 4: Fleurs (40%) ═══════════════════════════════════════
            if (_at(40)) ...[
              _flower(left: 38, bottom: 62, color: const Color(0xFFE91E63), size: 18),
              if (_at(41)) _flower(left: 62, bottom: 64, color: const Color(0xFFFFEB3B), size: 16),
              if (_at(42)) _flower(right: 48, bottom: 64, color: Colors.white, size: 16),
              if (_at(43)) _flower(left: 152, bottom: 66, color: const Color(0xFF9C27B0), size: 17),
              if (_at(44)) _flower(right: 88, bottom: 62, color: const Color(0xFFF44336), size: 16),
              if (_at(45)) _flower(left: 28, bottom: 68, color: const Color(0xFF2196F3), size: 15),
              if (_at(46)) _flower(right: 38, bottom: 68, color: const Color(0xFFFF9800), size: 17),
              if (_at(47)) _flower(left: 108, bottom: 62, color: const Color(0xFFE91E63), size: 18),
              if (_at(48)) _flower(right: 122, bottom: 66, color: Colors.white, size: 15),
              if (_at(49)) _flower(left: 182, bottom: 64, color: const Color(0xFF9C27B0), size: 17),
            ],

            // ══ LAYER 5: Papillons (jour) / Lucioles (nuit) — 50% ══════════
            if (_at(50)) ...[
              if (!solar.isNight) ...[
                _butterfly(left: 48, top: 110, color: Colors.orange),
                if (_at(51)) _butterfly(right: 58, top: 100, color: Colors.yellow),
                if (_at(52)) _butterfly(left: 118, top: 118, color: const Color(0xFF9C27B0)),
                if (_at(53)) _butterfly(left: 44, top: 92, color: const Color(0xFF2196F3)),
                if (_at(54)) _butterfly(right: 98, top: 112, color: Colors.pink),
                if (_at(55)) _butterfly(left: 78, top: 82, color: Colors.orange),
                if (_at(56)) _butterfly(right: 38, top: 128, color: const Color(0xFF2196F3)),
                if (_at(57)) _butterfly(left: 148, top: 102, color: Colors.yellow),
                if (_at(58)) _butterfly(right: 68, top: 88, color: Colors.green),
                if (_at(59)) _butterfly(left: 28, top: 122, color: Colors.red),
              ] else ...[
                _firefly(left: 48, top: 110),
                if (_at(51)) _firefly(right: 58, top: 100),
                if (_at(52)) _firefly(left: 118, top: 118),
                if (_at(53)) _firefly(left: 44, top: 92),
                if (_at(54)) _firefly(right: 98, top: 112),
                if (_at(55)) _firefly(left: 78, top: 82),
                if (_at(56)) _firefly(right: 38, top: 128),
                if (_at(57)) _firefly(left: 148, top: 102),
                if (_at(58)) _firefly(right: 68, top: 88),
                if (_at(59)) _firefly(left: 28, top: 122),
              ],
            ],

            // ══ LAYER 6: Pont (60%) ═════════════════════════════════════════
            if (_at(60)) _GardenBridge(subStage: subStage),

            // ══ LAYER 7: Forêt (70%) ════════════════════════════════════════
            if (_at(70)) _GardenForest(subStage: subStage),

            // ══ LAYER 8: Chemin (80%) ═══════════════════════════════════════
            if (_at(80)) _GardenPath(subStage: subStage),

            // ══ LAYER 9: Éclairage (90%) ════════════════════════════════════
            if (_at(90)) _GardenLighting(subStage: subStage, isNight: solar.isNight),

            // ── Astres ──────────────────────────────────────────────────────
            Positioned(
              top: 18,
              right: 26,
              child: AnimatedOpacity(
                opacity: _at(30) ? 1.0 : 0.28,
                duration: const Duration(milliseconds: 700),
                child: _CelestialBody(color: solar.celestialColor, isNight: solar.isNight),
              ),
            ),

            // ── Nuages (90%+) ────────────────────────────────────────────────
            if (_at(90)) _cloud(left: 28, top: 10, w: 55),
            if (_at(93)) _cloud(right: 48, top: 7, w: 40),

            // ── Étoiles nocturnes (95%+) ─────────────────────────────────────
            if (solar.isNight && _at(95)) ...[
              _star(left: 28, top: 14),
              _star(right: 58, top: 9),
              _star(left: 78, top: 7),
              _star(right: 28, top: 20),
              _star(left: 158, top: 13),
              if (_at(97)) _star(left: 42, top: 28),
              if (_at(99)) _star(right: 90, top: 16),
            ],

            // ── Label palier ─────────────────────────────────────────────────
            Positioned(
              top: 12,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.36),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  subStage >= 100
                      ? 'Jardin Complet ✦'
                      : 'Palier $_major/10 · $subStage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),

            // ── 100%: Shimmer doré ───────────────────────────────────────────
            if (_at(100))
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        AppColors.gold.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(duration: 2200.ms, color: AppColors.gold.withValues(alpha: 0.18)),
              ),
          ],
        ),
      ),
    );
  }

  // ── Helpers inline ────────────────────────────────────────────────────────

  Widget _pebble({double? left, double? right, required double bottom, required double size}) =>
      Positioned(
        left: left,
        right: right,
        bottom: bottom,
        child: Container(
          width: size,
          height: size * 0.7,
          decoration: BoxDecoration(
            color: const Color(0xFF757575),
            borderRadius: BorderRadius.circular(size),
          ),
        ),
      );

  Widget _leaf({double? left, double? right, required double bottom, required Color color}) =>
      Positioned(
        left: left,
        right: right,
        bottom: bottom,
        child: Transform.rotate(
          angle: 0.5,
          child: Icon(Icons.eco_rounded, size: 12, color: color),
        ),
      );

  Widget _grassTuft({double? left, double? right, required double bottom}) =>
      Positioned(
        left: left,
        right: right,
        bottom: bottom,
        child: const Icon(Icons.grass, size: 16, color: Color(0xFF4CAF50)),
      );

  Widget _mushroom({double? left, double? right, required double bottom}) =>
      Positioned(
        left: left,
        right: right,
        bottom: bottom,
        child: const Icon(Icons.spa_rounded, size: 14, color: Color(0xFFEF9A9A)),
      );

  Widget _waterPebble({double? left, double? right, required double bottom}) =>
      Positioned(
        left: left,
        right: right,
        bottom: bottom,
        child: Container(
          width: 6,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );

  Widget _lilyPad({double? left, double? right, required double bottom}) =>
      Positioned(
        left: left,
        right: right,
        bottom: bottom,
        child: const Icon(Icons.circle, size: 10, color: Color(0xFF66BB6A)),
      );

  Widget _smallFish({double? left, double? right, required double bottom}) =>
      Positioned(
        left: left,
        right: right,
        bottom: bottom,
        child: const Icon(Icons.set_meal_rounded, size: 11, color: Color(0xFFFFB74D)),
      );

  Widget _reed({double? left, double? right, required double bottom}) =>
      Positioned(
        left: left,
        right: right,
        bottom: bottom,
        child: Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF8D6E63),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _dragonfly({double? left, double? right, required double bottom}) =>
      Positioned(
        left: left,
        right: right,
        bottom: bottom,
        child: const Icon(Icons.air, size: 12, color: Color(0xFF80CBC4)),
      );

  Widget _waterRipple({double? left, double? right, required double bottom}) =>
      Positioned(
        left: left,
        right: right,
        bottom: bottom,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
          ),
        ),
      );

  Widget _flower({double? left, double? right, required double bottom, required Color color, required double size}) =>
      Positioned(
        left: left,
        right: right,
        bottom: bottom,
        child: Icon(Icons.local_florist_rounded, size: size, color: color),
      );

  Widget _butterfly({double? left, double? right, required double top, required Color color}) =>
      Positioned(
        left: left,
        right: right,
        top: top,
        child: Icon(Icons.flutter_dash, size: 14, color: color)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -4, duration: 1400.ms, curve: Curves.easeInOut),
      );

  Widget _firefly({double? left, double? right, required double top}) =>
      Positioned(
        left: left,
        right: right,
        top: top,
        child: Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFF176),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFF176).withValues(alpha: 0.8),
                blurRadius: 8,
              ),
            ],
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 900.ms)
            .then()
            .fadeOut(duration: 900.ms),
      );

  Widget _cloud({double? left, double? right, required double top, required double w}) =>
      Positioned(
        left: left,
        right: right,
        top: top,
        child: Container(
          width: w,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(9),
          ),
        ),
      );

  Widget _star({double? left, double? right, required double top}) =>
      Positioned(
        left: left,
        right: right,
        top: top,
        child: Container(
          width: 3,
          height: 3,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 1200.ms)
            .then()
            .fadeOut(duration: 1200.ms),
      );
}

// ── Astre (Soleil / Lune) ─────────────────────────────────────────────────────

class _CelestialBody extends StatelessWidget {
  final Color color;
  final bool isNight;

  const _CelestialBody({required this.color, required this.isNight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: isNight ? 0.92 : 0.88),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 18,
            spreadRadius: 3,
          ),
        ],
      ),
      child: isNight
          ? const Icon(Icons.nightlight_round, color: Colors.white70, size: 20)
          : null,
    );
  }
}

// ── Pont (60%) ────────────────────────────────────────────────────────────────

class _GardenBridge extends StatelessWidget {
  final int subStage;
  const _GardenBridge({required this.subStage});

  bool _at(int n) => subStage >= n;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 58,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: 70,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tablier du pont
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF8D6E63),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // Arche
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _pillar(_at(61)),
                  if (_at(66)) _lantern(),
                  if (_at(65)) _lantern(),
                  _pillar(_at(61)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pillar(bool withMoss) {
    return Container(
      width: 8,
      height: 18,
      decoration: BoxDecoration(
        color: withMoss ? const Color(0xFF6D4C41) : const Color(0xFF8D6E63),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
      ),
    );
  }

  Widget _lantern() {
    return Container(
      width: 5,
      height: 12,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD54F),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD54F).withValues(alpha: 0.6),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}

// ── Forêt (70%) ───────────────────────────────────────────────────────────────

class _GardenForest extends StatelessWidget {
  final int subStage;
  const _GardenForest({required this.subStage});

  bool _at(int n) => subStage >= n;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      bottom: 55,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _tree(60),
          const SizedBox(width: 2),
          _tree(75),
          const SizedBox(width: 2),
          _tree(55),
          if (_at(71)) ...[
            const SizedBox(width: 2),
            _tree(65),
          ],
          if (_at(73)) ...[
            const SizedBox(width: 2),
            _tree(50),
          ],
          if (_at(75)) ...[
            const SizedBox(width: 2),
            _tree(70),
          ],
        ],
      ),
    );
  }

  Widget _tree(double size) {
    return Icon(
      Icons.park_rounded,
      size: size,
      color: const Color(0xFF1B5E20).withValues(alpha: 0.85),
    );
  }
}

// ── Chemin (80%) ──────────────────────────────────────────────────────────────

class _GardenPath extends StatelessWidget {
  final int subStage;
  const _GardenPath({required this.subStage});

  bool _at(int n) => subStage >= n;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 55,
      right: 40,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stones row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stone(), _stone(), _stone(),
              if (_at(81)) _stone(),
              if (_at(82)) _stone(),
              if (_at(83)) _stone(),
            ],
          ),
          const SizedBox(height: 3),
          // Second row offset
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stone(),
                if (_at(84)) _stone(),
                if (_at(85)) _stone(),
                if (_at(86)) _stone(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stone() => Container(
        width: 14,
        height: 9,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: const Color(0xFFBCAAA4),
          borderRadius: BorderRadius.circular(4),
        ),
      );
}

// ── Éclairage (90%) ──────────────────────────────────────────────────────────

class _GardenLighting extends StatelessWidget {
  final int subStage;
  final bool isNight;
  const _GardenLighting({required this.subStage, required this.isNight});

  bool _at(int n) => subStage >= n;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _lamp(left: 58, bottom: 62),
        if (_at(91)) _lamp(left: 88, bottom: 62),
        if (_at(92)) _lamp(left: 118, bottom: 62),
        if (_at(93)) _lamp(left: 148, bottom: 62),
        if (_at(94)) _lamp(left: 178, bottom: 62),
      ],
    );
  }

  Widget _lamp({double? left, required double bottom}) {
    final glowColor = isNight
        ? const Color(0xFFFFE082).withValues(alpha: 0.9)
        : const Color(0xFFFFD54F).withValues(alpha: 0.5);

    return Positioned(
      left: left,
      bottom: bottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tête de lampe
          Container(
            width: 8,
            height: 6,
            decoration: BoxDecoration(
              color: glowColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: isNight
                  ? [BoxShadow(color: const Color(0xFFFFE082).withValues(alpha: 0.7), blurRadius: 12)]
                  : null,
            ),
          ),
          // Poteau
          Container(
            width: 2,
            height: 14,
            color: const Color(0xFF9E9E9E),
          ),
        ],
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 2000.ms, color: glowColor),
    );
  }
}
