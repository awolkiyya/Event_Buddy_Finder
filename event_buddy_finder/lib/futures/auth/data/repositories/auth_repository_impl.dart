import 'package:event_buddy_finder/commens/errors/user_profile_incomplete_exception.dart';
import 'package:event_buddy_finder/futures/auth/data/datasources/auth_remote_data_source.dart';
import 'package:event_buddy_finder/futures/auth/domain/entities/auth_result.dart';
import 'package:event_buddy_finder/futures/auth/domain/entities/user_entity.dart';
import 'package:event_buddy_finder/futures/auth/domain/entities/user_profile.dart';
import 'package:event_buddy_finder/futures/auth/domain/repositories/auth_repository.dart';

class LoginFailure implements Exception {
  final String message;
  LoginFailure(this.message);

  @override
  String toString() => 'LoginFailure: $message';
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource realDataSource;
  // final AuthRemoteDataSource mockDataSource;
  final bool useMock;

  AuthRepositoryImpl({
    required this.realDataSource,
    // required this.mockDataSource,
    this.useMock = false,
  });

  AuthRemoteDataSource get _dataSource => realDataSource;

  @override
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userModel = await _dataSource.loginWithEmail(email, password);
      return userModel.toEntity();
    } on Exception catch (e) {
      throw LoginFailure('Failed to login: ${e.toString()}');
    }
  }

  @override
 Future<AuthResult?> signInWithGoogle() async {
  try {
    final userModel = await _dataSource.loginWithGoogle();
    return userModel?.toEntity();
  } on UserProfileIncompleteException {
    // Let this bubble up to the Bloc
    rethrow;
  } catch (e) {
    throw LoginFailure('Failed to login: ${e.toString()}');
  }
}


  @override
  Future<void> signOut() async {
    try {
      await _dataSource.signOut();
    } on Exception catch (e) {
      throw LoginFailure('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final userModel = await _dataSource.signUpWithEmail(email, password);
      return userModel?.toEntity();
    } on Exception catch (e) {
      throw LoginFailure('Failed to sign up: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> saveUserProfile(UserProfileEntity profile) async {
    try {
      final updatedUserModel = await _dataSource.saveUserProfile(profile);
      return updatedUserModel.toEntity();
    } on Exception catch (e) {
      throw LoginFailure('Failed to save profile: ${e.toString()}');
    }
  }
}
