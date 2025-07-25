
// lib/domain/auth/usecases/sign_in_with_email_and_password_usecase.dart

import 'package:event_buddy_finder/futures/auth/domain/repositories/auth_repository.dart';


class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> call() async {
   await repository.signOut();
  }
}
