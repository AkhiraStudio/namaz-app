import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import '../../../../core/constants/prayer_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/location_service.dart';

abstract class QiblaDataSource {
  Stream<({double qiblaAngle, double compassHeading, bool isCalibrated})>
      getQiblaStream();
}

class QiblaDataSourceImpl implements QiblaDataSource {
  final LocationService _locationService;

  const QiblaDataSourceImpl({required LocationService locationService})
      : _locationService = locationService;

  /// Calcule l'angle vers la Kaaba depuis [lat, lng] en degrés (0–360).
  static double _calculateQiblaAngle(double lat, double lng) {
    final latRad = lat * math.pi / 180;
    final lngDiff = (PrayerConstants.kaabatLng - lng) * math.pi / 180;
    const kaabatLatRad = PrayerConstants.kaabatLat * math.pi / 180;

    final y = math.sin(lngDiff) * math.cos(kaabatLatRad);
    final x = math.cos(latRad) * math.sin(kaabatLatRad) -
        math.sin(latRad) * math.cos(kaabatLatRad) * math.cos(lngDiff);

    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  @override
  Stream<({double qiblaAngle, double compassHeading, bool isCalibrated})>
      getQiblaStream() async* {
    // Position unique au démarrage
    final position = await _locationService.getCurrentPosition();
    final qiblaAngle = _calculateQiblaAngle(
      position.latitude,
      position.longitude,
    );

    // Boussole en continu
    final compassStream = FlutterCompass.events;
    if (compassStream == null) {
      throw const LocationException(
          message: 'Boussole non disponible sur cet appareil.');
    }

    double smoothed = 0.0;
    bool first = true;
    const double alpha = 0.25;

    await for (final event in compassStream) {
      final raw = event.heading ?? 0.0;
      final accuracy = event.accuracy ?? 0.0;

      if (first) {
        smoothed = raw;
        first = false;
      } else {
        // Filtre passe-bas circulaire (gère le passage 359°→0°)
        double diff = raw - smoothed;
        if (diff > 180) diff -= 360;
        if (diff < -180) diff += 360;
        smoothed = (smoothed + alpha * diff + 360) % 360;
      }

      yield (
        qiblaAngle: qiblaAngle,
        compassHeading: smoothed,
        isCalibrated: accuracy < 15.0,
      );
    }
  }
}
