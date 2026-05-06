import 'package:geolocator/geolocator.dart';
import '../errors/exceptions.dart';

/// Abstraction du service de localisation GPS.
abstract class LocationService {
  /// Vérifie les permissions et retourne la position courante.
  Future<Position> getCurrentPosition();

  /// Stream de positions pour le mode voyageur (mise à jour continue).
  Stream<Position> getPositionStream();
}

class LocationServiceImpl implements LocationService {
  static const _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.medium,
    distanceFilter: 100, // mise à jour tous les 100 m
  );

  @override
  Future<Position> getCurrentPosition() async {
    await _ensurePermissions();
    return Geolocator.getCurrentPosition(
      locationSettings: _locationSettings,
    );
  }

  @override
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    );
  }

  /// Vérifie que le service et les permissions sont disponibles.
  /// Lève [LocationException] ou [PermissionException] sinon.
  static Future<void> _ensurePermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
          message: 'Service de localisation désactivé. '
              'Activez le GPS dans les paramètres du téléphone.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const PermissionException(
            message: 'Permission de localisation refusée.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const PermissionException(
          message: 'Permission de localisation refusée définitivement. '
              'Autorisez la localisation dans les paramètres de l\'application.');
    }
  }
}
