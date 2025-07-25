import '../../domain/entities/auth_result.dart';
import 'user_model.dart';

class AuthResultModel extends AuthResult {
  AuthResultModel({
    required super.user,
    required super.token,
  });

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    return AuthResultModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': (user as UserModel).toJson(),
      'token': token,
    };
  }

  AuthResult toEntity() {
    return AuthResult(
      user: user,  // user is already UserEntity type or subclass
      token: token,
    );
  }
}
