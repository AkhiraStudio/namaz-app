import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.isAnonymous,
  });

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, isAnonymous];
}
