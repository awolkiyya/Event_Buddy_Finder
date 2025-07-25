
// lib/domain/auth/usecases/sign_in_with_email_and_password_usecase.dart

import 'package:event_buddy_finder/futures/auth/domain/entities/auth_result.dart';
import 'package:event_buddy_finder/futures/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<AuthResult> call() async {
  final user = await repository.signInWithGoogle();
  if (user == null) {
    throw Exception('User not found');
  }
  return user;
}
}
