/// Exception levée lors d'un échec de requête serveur.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

/// Exception levée lors d'un échec de lecture/écriture du cache local.
class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

/// Exception levée lors d'un problème de géolocalisation.
class LocationException implements Exception {
  final String message;

  const LocationException({required this.message});

  @override
  String toString() => 'LocationException: $message';
}

/// Exception levée lorsque les permissions sont refusées.
class PermissionException implements Exception {
  final String message;

  const PermissionException({required this.message});

  @override
  String toString() => 'PermissionException: $message';
}

/// Exception levée en l'absence de connexion réseau.
class NetworkException implements Exception {
  const NetworkException();

  @override
  String toString() => 'NetworkException: Pas de connexion internet';
}
