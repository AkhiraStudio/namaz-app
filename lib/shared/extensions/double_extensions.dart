import 'dart:math' as math;

extension DoubleExtensions on double {
  /// Convertit des degrés en radians.
  double get toRadians => this * math.pi / 180;

  /// Convertit des radians en degrés.
  double get toDegrees => this * 180 / math.pi;

  /// Normalise un angle en degrés dans [0, 360[.
  double get normalizedAngle => ((this % 360) + 360) % 360;

  /// Formate un pourcentage (0.0–1.0) en chaîne "xx%".
  String get toPercent => '${(this * 100).round()}%';
}
