import 'package:dio/dio.dart';
import 'package:event_buddy_finder/commens/errors/user_profile_incomplete_exception.dart';
import 'package:event_buddy_finder/commens/network/api_constants.dart';
import 'package:event_buddy_finder/commens/services/firebase_auth_service.dart';
import 'package:event_buddy_finder/futures/auth/data/models/auth_result_model.dart';
import 'package:event_buddy_finder/futures/auth/domain/entities/auth_result.dart';
import 'package:flutter/material.dart';
import '../../../../commens/network/dio_service.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_profile.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResultModel> loginWithEmail(String email, String password);
  Future<AuthResultModel> loginWithGoogle();
  Future<void> signOut();
  Future<AuthResultModel > signUpWithEmail(String email, String password);
  Future<AuthResultModel > saveUserProfile(UserProfileEntity profile);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuthService _firebaseAuthService;
  final DioService _dio;

  AuthRemoteDataSourceImpl(this._firebaseAuthService, this._dio);

  @override
  Future<AuthResultModel > loginWithEmail(String email, String password) async {
    final firebaseUser = await _firebaseAuthService.signInWithEmail(
      email: email,
      password: password,
    );
    if (firebaseUser == null) {
      throw Exception('Firebase login failed');
    }

    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'uid': firebaseUser.uid,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        debugPrint("User info: ${response.data}");
        return AuthResultModel.fromJson(response.data);
      } else {
        throw Exception('Server login failed with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during login: $e');
    }
  }
  
  @override
  Future<AuthResultModel> loginWithGoogle() async {
    final firebaseUser = await _firebaseAuthService.signInWithGoogle();

    if (firebaseUser == null) {
      throw Exception('Google sign-in cancelled by user');
    }
    final idToken = await firebaseUser.getIdToken();

    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'uid': firebaseUser.uid,
          'email': firebaseUser.email ?? '',
          'name': firebaseUser.displayName ?? '',
          'profilePhoto': firebaseUser.photoURL ?? '',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        return AuthResultModel.fromJson(response.data);
      } else if (response.statusCode == 202) {
        final uid = response.data['uid'] as String? ?? '';
        if (uid.isEmpty) {
          throw Exception('UID missing in server response for incomplete profile');
        }
        throw UserProfileIncompleteException(uid: uid);
      } else {
        throw Exception('Server login failed: ${response.statusCode}');
      }
    } catch (e) {
      // optionally add logging here
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuthService.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
  
  @override
  Future<AuthResultModel> signUpWithEmail(String email, String password) async {
    try {
      final firebaseUser = await _firebaseAuthService.registerWithEmail(
        email: email,
        password: password,
      );

      if (firebaseUser == null) {
        throw Exception('Firebase registration failed');
      }

      final idToken = await firebaseUser.getIdToken();

      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'uid': firebaseUser.uid,
          'email': firebaseUser.email,
          'name': firebaseUser.displayName ?? '',
          'profilePhoto': firebaseUser.photoURL ?? '',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
          },
        ),
      );

      final userData = response.data['data']; // adjust to your API response
      return AuthResultModel.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResultModel> saveUserProfile(UserProfileEntity profile) async {
    try {
      final idToken = await _firebaseAuthService.getCurrentUserToken();

      final response = await _dio.post(
        ApiConstants.saveUserProfile, // Make sure this is your endpoint
        data: {
          'uid': profile.uid,
          'email': profile.email,
          'fullName': profile.fullName,
          'bio': profile.bio,
          'interests': profile.interests,
          'location': profile.location,
          'geo': profile.geo?.toJson(), // assuming GeoPoint has toJson()
          'profileImageUrl': profile.profileImageUrl,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        return AuthResultModel.fromJson(response.data);
      } else {
        throw Exception('Failed to save profile with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving profile: $e');
    }
  }
}
