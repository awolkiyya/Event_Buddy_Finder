
import 'package:event_buddy_finder/futures/events/domain/entities/event.dart';

class EventModel extends EventEntity {
  EventModel({
    required String id,
    required String title,
    String? description,
    required String location,
    required DateTime time,
    required List<String> tags,
    required List<String> attendeesIds,
    String? imageUrl,
    double? latitude,
    double? longitude,
  }) : super(
          id: id,
          title: title,
          description: description,
          location: location,
          time: time,
          tags: tags,
          attendeesIds: attendeesIds,
          imageUrl: imageUrl,
          latitude: latitude,
          longitude: longitude,
        );

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String,
      time: DateTime.parse(json['time'] as String),
      tags: List<String>.from(json['tags'] ?? []),
      attendeesIds: List<String>.from(json['attendees'] ?? []),
      imageUrl: json['imageUrl'] as String?,
      latitude: (json['latitude'] != null) ? (json['latitude'] as num).toDouble() : null,
      longitude: (json['longitude'] != null) ? (json['longitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'location': location,
      'time': time.toIso8601String(),
      'tags': tags,
      'attendees': attendeesIds,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
