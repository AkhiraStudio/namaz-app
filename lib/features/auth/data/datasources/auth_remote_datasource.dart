import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/app_user.dart';

abstract class AuthRemoteDataSource {
  Stream<AppUser?> get authStateChanges;
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInAnonymously();
  Future<AppUser> signInWithEmail({required String email, required String password});
  Future<AppUser> signUpWithEmail({required String email, required String password});
  Future<void> sendPasswordResetEmail(String email);
  Future<AppUser> linkWithGoogle();
  Future<void> updateEmail(String newEmail);
  Future<void> updatePassword(String newPassword);
  Future<void> deleteAccount();
  Future<void> signOut();
  AppUser? get currentUser;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  AppUser _toAppUser(User user) => AppUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        isAnonymous: user.isAnonymous,
      );

  @override
  Stream<AppUser?> get authStateChanges =>
      _auth.authStateChanges().map((u) => u == null ? null : _toAppUser(u));

  @override
  AppUser? get currentUser {
    final u = _auth.currentUser;
    return u == null ? null : _toAppUser(u);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const ServerException(message: 'Connexion annulée');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      return _toAppUser(result.user!);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? 'Erreur Firebase Auth');
    }
  }

  @override
  Future<AppUser> signInWithEmail({required String email, required String password}) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _toAppUser(result.user!);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: _authErrorMessage(e.code));
    }
  }

  @override
  Future<AppUser> signUpWithEmail({required String email, required String password}) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return _toAppUser(result.user!);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: _authErrorMessage(e.code));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: _authErrorMessage(e.code));
    }
  }

  String _authErrorMessage(String code) => switch (code) {
        'user-not-found'       => 'Aucun compte avec cet email.',
        'wrong-password'       => 'Mot de passe incorrect.',
        'email-already-in-use' => 'Cet email est déjà utilisé.',
        'invalid-email'        => 'Email invalide.',
        'weak-password'        => 'Mot de passe trop faible (6 caractères min).',
        'too-many-requests'    => 'Trop de tentatives. Réessayez plus tard.',
        _                      => 'Erreur d\'authentification.',
      };

  @override
  Future<AppUser> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return _toAppUser(result.user!);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? 'Erreur connexion anonyme');
    }
  }

  @override
  Future<AppUser> linkWithGoogle() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw const ServerException(message: 'Aucun utilisateur connecté');
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const ServerException(message: 'Connexion annulée');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await currentUser.linkWithCredential(credential);
      return _toAppUser(result.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        // Compte Google déjà utilisé — on se connecte directement
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) throw const ServerException(message: 'Connexion annulée');
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final result = await _auth.signInWithCredential(credential);
        return _toAppUser(result.user!);
      }
      throw ServerException(message: e.message ?? 'Erreur liaison compte');
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: _authErrorMessage(e.code));
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: _authErrorMessage(e.code));
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: _authErrorMessage(e.code));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? 'Erreur déconnexion');
    }
  }
}
