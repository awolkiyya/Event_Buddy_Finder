class EventEntity {
  final String id;
  final String title;
  final String? description;
  final String location;
  final DateTime time;
  final List<String> tags;
  final List<String> attendeesIds;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  EventEntity({
    required this.id,
    required this.title,
    this.description,
    required this.location,
    required this.time,
    required this.tags,
    required this.attendeesIds,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });
}
