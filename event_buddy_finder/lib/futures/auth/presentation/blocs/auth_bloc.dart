import 'package:event_buddy_finder/commens/errors/user_profile_incomplete_exception.dart';
import 'package:event_buddy_finder/commens/services/userSession_service.dart';
import 'package:event_buddy_finder/futures/auth/data/models/user_model.dart';
import 'package:event_buddy_finder/futures/auth/domain/usecases/save_user_profile.dart';
import 'package:event_buddy_finder/futures/auth/domain/usecases/sign_in_with_email.dart';
import 'package:event_buddy_finder/futures/auth/domain/usecases/sign_in_with_google.dart';
import 'package:event_buddy_finder/futures/auth/domain/usecases/sign_out.dart';
import 'package:event_buddy_finder/futures/auth/domain/usecases/sign_up_with_email.dart';
import 'package:event_buddy_finder/futures/auth/presentation/blocs/auth_event.dart';
import 'package:event_buddy_finder/futures/auth/presentation/blocs/auth_state.dart';
import 'package:event_buddy_finder/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmailAndPasswordUseCase signInWithEmailAndPassword;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignOutUseCase signOutUseCase;
  final SignUpWithEmailAndPasswordUseCase signUpWithEmailAndPassword;
  final SaveUserProfileUseCase saveUserProfileUseCase;

  AuthBloc({
    required this.signInWithEmailAndPassword,
    required this.signInWithGoogleUseCase,
    required this.signOutUseCase,
    required this.signUpWithEmailAndPassword,
    required this.saveUserProfileUseCase,
  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthSignInWithEmailRequested>(_onSignInWithEmailRequested);
    on<AuthSignInWithGoogleRequested>(_onGoogleSignInRequested);
    on<RegisterWithEmailRequested>(_onSignUpWithEmailRequested);
    on<SaveProfileRequested>(_onSaveProfileRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    // Add logic here if needed to check user authentication state
    emit(AuthInitial());
  }

  
Future<void> _onSignInWithEmailRequested(
    AuthSignInWithEmailRequested event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  try {
    final user = await signInWithEmailAndPassword.call(event.email, event.password);
    if (user != null) {
      // here two things are needed store token also 
      await sl<UserSession>().saveUserToStorage(UserModel.fromEntity(user.user),user.token);
      emit(AuthAuthenticated(user.user));
    } else {
      emit(AuthFailure('Failed to authenticate user.'));
    }
  } catch (e) {
    emit(AuthFailure('Error signing in: ${e.toString()}'));
  }
}

Future<void> _onSignUpWithEmailRequested(
    RegisterWithEmailRequested event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  try {
    final user = await signUpWithEmailAndPassword.call(event.email, event.password);
    if (user != null) {
      await sl<UserSession>().saveUserToStorage(UserModel.fromEntity(user.user),user.token);
      emit(AuthAuthenticated(user.user));
    } else {
      emit(AuthFailure('Failed to register user.'));
    }
  } catch (e) {
    emit(AuthFailure('Error signing up: ${e.toString()}'));
  }
}

Future<void> _onGoogleSignInRequested(
  AuthSignInWithGoogleRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());

  try {
    final authResult = await signInWithGoogleUseCase.call();

    if (authResult != null) {
      // Save user session (user model + token)
      await sl<UserSession>().saveUserToStorage(
        UserModel.fromEntity(authResult.user),
        authResult.token,
      );

      emit(AuthAuthenticated(authResult.user));
    } else {
      emit(AuthUnauthenticated());
    }
  } on UserProfileIncompleteException catch (e) {
    // This means user is authenticated via Firebase but no profile in DB
    // You can emit a special state with the UID so UI can navigate to profile completion page
    emit(AuthProfileIncomplete(e.uid));
  } catch (e) {
    emit(AuthFailure('Google sign-in failed: ${e.toString()}'));
  }
}


Future<void> _onSaveProfileRequested(
    SaveProfileRequested event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  try {
    final updatedUser = await saveUserProfileUseCase.call(event.profile);
    await sl<UserSession>().saveUserToStorage(UserModel.fromEntity(updatedUser.user),updatedUser.token);
    emit(AuthProfileSaved(updatedUser.user));
  } catch (e) {
    emit(AuthFailure('Failed to save profile: ${e.toString()}'));
  }
}

Future<void> _onSignOutRequested(
    AuthSignOutRequested event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  try {
    await signOutUseCase.call();
    await sl<UserSession>().clearUser();
    emit(AuthUnauthenticated());
  } catch (e) {
    emit(AuthFailure('Sign out failed: ${e.toString()}'));
  }
}
}
