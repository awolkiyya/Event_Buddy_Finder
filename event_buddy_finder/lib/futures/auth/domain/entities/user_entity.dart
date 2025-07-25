class UserEntity {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String? userStatus;
  final DateTime? lastSeen;
  final String? location; // ⬅️ New field for city, region, etc.

  UserEntity({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    this.userStatus,
    this.lastSeen,
    this.location,
  });
}
