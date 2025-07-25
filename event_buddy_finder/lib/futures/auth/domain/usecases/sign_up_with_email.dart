
// lib/domain/auth/usecases/sign_in_with_email_and_password_usecase.dart

import 'package:event_buddy_finder/futures/auth/domain/entities/auth_result.dart';
import 'package:event_buddy_finder/futures/auth/domain/entities/user_entity.dart';
import 'package:event_buddy_finder/futures/auth/domain/repositories/auth_repository.dart';


class SignUpWithEmailAndPasswordUseCase {
  final AuthRepository repository;

  SignUpWithEmailAndPasswordUseCase(this.repository);

   Future<AuthResult> call(String email, String password) async {
  final user = await repository.signUpWithEmailAndPassword(email, password);
  if (user == null) {
    throw Exception('User not found');
  }
  return user;
}
}


