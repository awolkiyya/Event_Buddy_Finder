import 'package:event_buddy_finder/futures/auth/data/models/GeoPoint.dart';

class UserProfileModel {
  final String uid;
  final String email;
  final String? profileImageUrl;
  final String fullName;
  final String? bio;
  final List<String> interests;
  final String location; // e.g. city name
  final GeoPointModel? geo;   // geo coordinates for precise location

  UserProfileModel({
    required this.uid,
    required this.email,
    this.profileImageUrl,
    required this.fullName,
    this.bio,
    required this.interests,
    required this.location,
    this.geo,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'profileImageUrl': profileImageUrl,
        'fullName': fullName,
        'bio': bio,
        'interests': interests,
        'location': location,
        'geo': geo?.toJson(),
      };

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      fullName: json['fullName'] as String,
      bio: json['bio'] as String?,
      interests: List<String>.from(json['interests'] ?? []),
      location: json['location'] as String? ?? '',
      geo: json['geo'] != null ? GeoPointModel.fromJson(json['geo']) : null,
    );
  }
}
