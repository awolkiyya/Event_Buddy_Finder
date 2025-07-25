import 'package:equatable/equatable.dart';
import 'package:event_buddy_finder/futures/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// New state for when profile is saved successfully
class AuthProfileSaved extends AuthState {
  final UserEntity user;

  const AuthProfileSaved(this.user);

  @override
  List<Object?> get props => [user];
}

// New state for when user profile is incomplete and needs completion
class AuthProfileIncomplete extends AuthState {
  final String uid;

  const AuthProfileIncomplete(this.uid);

  @override
  List<Object?> get props => [uid];
}
