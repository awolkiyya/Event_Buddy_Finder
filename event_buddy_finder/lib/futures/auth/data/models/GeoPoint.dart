class GeoPointModel {
  final String type;
  final List<double> coordinates; // [longitude, latitude]

  GeoPointModel({
    required this.type,
    required this.coordinates,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'coordinates': coordinates,
      };

  factory GeoPointModel.fromJson(Map<String, dynamic> json) {
    return GeoPointModel(
      type: json['type'] as String,
      coordinates: List<double>.from(json['coordinates']),
    );
  }
}