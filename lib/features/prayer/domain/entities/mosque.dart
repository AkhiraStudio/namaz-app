import 'package:equatable/equatable.dart';

/// Mosquée récupérée depuis OpenStreetMap (Overpass API).
class Mosque extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final double? distanceMeters;

  const Mosque({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.distanceMeters,
  });

  /// Construit depuis un élément brut de l'API Overpass.
  /// Les `node` ont lat/lon directement ; les `way` et `relation`
  /// retournent un objet `center` avec `out center`.
  factory Mosque.fromOverpass(Map<String, dynamic> element) {
    final tags = (element['tags'] as Map?)?.cast<String, dynamic>() ?? {};

    final double lat;
    final double lon;
    if (element['type'] == 'node') {
      lat = (element['lat'] as num?)?.toDouble() ?? 0.0;
      lon = (element['lon'] as num?)?.toDouble() ?? 0.0;
    } else {
      // way ou relation : coordonnées dans l'objet 'center'
      final center =
          (element['center'] as Map?)?.cast<String, dynamic>() ?? {};
      lat = (center['lat'] as num?)?.toDouble() ?? 0.0;
      lon = (center['lon'] as num?)?.toDouble() ?? 0.0;
    }

    final streetName = tags['addr:street'] as String?;
    final houseNumber = tags['addr:housenumber'] as String?;
    final city = tags['addr:city'] as String?;
    final address = [
      if (streetName != null) streetName,
      if (houseNumber != null) houseNumber,
      if (city != null) city,
    ].join(', ');

    return Mosque(
      id: element['id']?.toString() ?? '0',
      name: (tags['name'] as String?) ??
          (tags['name:fr'] as String?) ??
          'Mosquée',
      latitude: lat,
      longitude: lon,
      address: address.isNotEmpty ? address : null,
    );
  }

  /// Distance formatée (m ou km).
  String get formattedDistance {
    if (distanceMeters == null) return '';
    if (distanceMeters! < 1000) {
      return '${distanceMeters!.round()} m';
    }
    return '${(distanceMeters! / 1000).toStringAsFixed(1)} km';
  }

  Mosque copyWith({double? distanceMeters}) => Mosque(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        address: address,
        distanceMeters: distanceMeters ?? this.distanceMeters,
      );

  @override
  List<Object?> get props =>
      [id, name, latitude, longitude, address, distanceMeters];
}
