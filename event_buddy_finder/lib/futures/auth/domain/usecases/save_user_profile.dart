import 'package:event_buddy_finder/futures/auth/domain/entities/auth_result.dart';
import 'package:event_buddy_finder/futures/auth/domain/entities/user_profile.dart';
import 'package:event_buddy_finder/futures/auth/domain/entities/user_entity.dart';
import 'package:event_buddy_finder/futures/auth/domain/repositories/auth_repository.dart';

class SaveUserProfileUseCase {
  final AuthRepository repository;

  SaveUserProfileUseCase(this.repository);

  /// Saves the user profile and returns the updated UserEntity.
  Future<AuthResult> call(UserProfileEntity profile) async {
    final updatedUser = await repository.saveUserProfile(profile);
    return updatedUser;
  }
}
