// domain/entities/user_entity.dart
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String photoURL;
  final String? bio;
  final String? location;
  final List<String> interests;
  final DateTime lastOnline;
  final String status; // 'online' or 'offline'

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.photoURL,
    this.bio,
    this.location,
    required this.interests,
    required this.lastOnline,
    required this.status,
  });
}
