import 'package:event_buddy_finder/futures/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required String userId,
    String? userName,  // made optional
    String? userPhotoUrl,
    String? userStatus,
    DateTime? lastSeen,
  }) : super(
          userId: userId,
          userName: userName ?? '',  // default empty string if null
          userPhotoUrl: userPhotoUrl,
          userStatus: userStatus,
          lastSeen: lastSeen,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      userName: json['userName'] as String?,  // nullable
      userPhotoUrl: json['userPhotoUrl'] as String?,
      userStatus: json['userStatus'] as String?,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'userStatus': userStatus,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  // Optional: Convert this model back to entity (useful in repo layer)
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      userStatus: userStatus,
      lastSeen: lastSeen,
    );
  }
   factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      userId: entity.userId,
      userName: entity.userName,
      userPhotoUrl: entity.userPhotoUrl,
      userStatus: entity.userStatus,
      lastSeen: entity.lastSeen,
    );
  }
}
