import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';
import '../services/location_service.dart';

/// Provider global du service audio (adhan + adhkars).
/// Disposé automatiquement quand plus aucun widget ne l'écoute.
final audioServiceProvider = Provider.autoDispose<AudioService>((ref) {
  final service = AudioServiceImpl();
  ref.onDispose(service.dispose);
  return service;
});

/// Provider global du service de localisation.
final locationServiceProvider = Provider<LocationService>(
  (_) => LocationServiceImpl(),
);
