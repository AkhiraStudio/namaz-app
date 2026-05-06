import 'package:equatable/equatable.dart';

class QiblaDirection extends Equatable {
  final double angle;          // Angle vers la Kaaba en degrés
  final double compassHeading; // Cap de la boussole en degrés
  final bool isCalibrated;

  const QiblaDirection({
    required this.angle,
    required this.compassHeading,
    required this.isCalibrated,
  });

  /// Angle à afficher sur la boussole = qibla - compass heading.
  double get displayAngle => (angle - compassHeading + 360) % 360;

  /// Vrai si l'utilisateur fait face à la Kaaba (±8°).
  bool get isFacingQibla => displayAngle <= 8 || displayAngle >= 352;

  @override
  List<Object?> get props => [angle, compassHeading, isCalibrated];
}
