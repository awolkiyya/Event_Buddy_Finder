import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Sign in with email and password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 15));
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Email sign-in error: ${e.code}');
      rethrow;
    } catch (e) {
      print('Unexpected sign-in error: $e');
      rethrow;
    }
  }

  /// Register a user with email and password
  Future<User?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 15));
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Email registration error: ${e.code}');
      rethrow;
    } catch (e) {
      print('Unexpected registration error: $e');
      rethrow;
    }
  }

  /// Google sign-in
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled the sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth
          .signInWithCredential(credential)
          .timeout(const Duration(seconds: 15));
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Google sign-in Firebase error: ${e.code}');
      rethrow;
    } catch (e) {
      print('Google sign-in unexpected error: $e');
      rethrow;
    }
  }

  /// Sign out from both Firebase and Google
  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
    } catch (e) {
      print('Sign-out error: $e');
      rethrow;
    }
  }

  /// Get the currently authenticated user
  User? get currentUser => _auth.currentUser;

  /// Reload the currently authenticated user
  Future<User?> reloadCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        return _auth.currentUser;
      }
      return null;
    } catch (e) {
      print('Error reloading user: $e');
      rethrow;
    }
  }
  Future<String?> getCurrentUserToken() async {
  try {
    final user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  } catch (e) {
    print('Error getting user token: $e');
    rethrow;
  }
}


  /// Check if user is already logged in
  bool get isLoggedIn => _auth.currentUser != null;
}
