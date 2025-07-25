import 'package:equatable/equatable.dart';
import 'package:event_buddy_finder/futures/auth/domain/entities/user_profile.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
  
}
class AppStarted extends AuthEvent {}
class AuthCheckRequested extends AuthEvent {}

class AuthSignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmailRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthSignInWithGoogleRequested extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}
class RegisterWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const RegisterWithEmailRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}
// the event that take profile detail and save the data to server
class SaveProfileRequested extends AuthEvent {
  final UserProfileEntity profile;

  SaveProfileRequested(this.profile);
}

