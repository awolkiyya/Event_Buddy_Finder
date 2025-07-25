import 'package:event_buddy_finder/commens/services/geo_point_service.dart';

class UserProfileEntity {
  final String uid;
  final String fullName;
  final String email;
  final String? bio;
  final String? profileImageUrl;
  final String? location; // Human-readable name (e.g., city)
  final GeoPoint? geo; // Coordinates
  final List<String>? interests;

  UserProfileEntity({
    required this.uid,
    required this.fullName,
    required this.email,
    this.bio,
    this.profileImageUrl,
    this.location,
    this.geo,
    this.interests,
  });
}
