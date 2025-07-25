import 'user_entity.dart';

class AuthResult {
  final UserEntity user;
  final String token;

  AuthResult({
    required this.user,
    required this.token,
  });
}
