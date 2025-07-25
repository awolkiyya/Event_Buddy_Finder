class GeoPoint {
  final String type; // Always 'Point'
  final List<double> coordinates; // [longitude, latitude]

  GeoPoint({
    this.type = 'Point',
    required this.coordinates,
  });
}
