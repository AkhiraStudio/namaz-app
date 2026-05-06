import 'package:equatable/equatable.dart';

/// Classe de base pour toutes les erreurs métier (couche domain).
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Échec lié à un appel API distant.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required super.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Échec lié au stockage local (Hive).
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Échec lié à la géolocalisation.
class LocationFailure extends Failure {
  const LocationFailure({required super.message});
}

/// Échec lié aux permissions refusées.
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}

/// Échec lié à l'absence de connexion réseau.
class NetworkFailure extends Failure {
  const NetworkFailure() : super(message: 'Pas de connexion internet');
}
