import 'package:connectivity_plus/connectivity_plus.dart';

/// Vérifie la disponibilité de la connexion réseau.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  const NetworkInfoImpl({required this.connectivity});

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
