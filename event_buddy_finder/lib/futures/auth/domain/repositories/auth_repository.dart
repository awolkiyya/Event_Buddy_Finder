// lib/domain/auth/auth_repository.dart

import 'package:event_buddy_finder/futures/auth/domain/entities/auth_result.dart';
import 'package:event_buddy_finder/futures/auth/domain/entities/user_profile.dart';

abstract class AuthRepository {
   /// Sign in with email/password
   Future<AuthResult?> signInWithEmailAndPassword(String email, String password);
   //  google signin
   Future<AuthResult?> signInWithGoogle();
   // SignOut
   Future<void> signOut();
   //  register with email/password
   Future<AuthResult?> signUpWithEmailAndPassword(String email, String password);
  //  / Save user profile data
  Future<AuthResult> saveUserProfile(UserProfileEntity profile);
}
