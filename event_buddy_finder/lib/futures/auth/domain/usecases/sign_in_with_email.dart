import 'package:event_buddy_finder/futures/auth/domain/entities/auth_result.dart';
import 'package:event_buddy_finder/futures/auth/domain/repositories/auth_repository.dart';

class SignInWithEmailAndPasswordUseCase {
  final AuthRepository repository;

  SignInWithEmailAndPasswordUseCase(this.repository);

  Future<AuthResult> call(String email, String password) async {
    final authResult = await repository.signInWithEmailAndPassword(email, password);
    if (authResult == null) {
      throw Exception('Invalid email or password');
    }
    return authResult;
  }
}
