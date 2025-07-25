import 'package:event_buddy_finder/futures/connections/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required String id,
    required String name,
    required String email,
    required String photoURL,
    String? bio,
    String? location,
    required List<String> interests,
    required DateTime lastOnline,
    required String status,
  }) : super(
          id: id,
          name: name,
          email: email,
          photoURL: photoURL,
          bio: bio,
          location: location,
          interests: interests,
          lastOnline: lastOnline,
          status: status,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoURL: json['photoURL'] as String,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      interests: (json['interests'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      lastOnline: DateTime.parse(json['lastOnline'] as String),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      if (bio != null) 'bio': bio,
      if (location != null) 'location': location,
      'interests': interests,
      'lastOnline': lastOnline.toIso8601String(),
      'status': status,
    };
  }
}
