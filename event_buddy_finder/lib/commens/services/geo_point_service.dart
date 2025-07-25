import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GeoPoint {
  final String type;
  final List<double> coordinates;

  GeoPoint({required this.type, required this.coordinates});

  Map<String, dynamic> toJson() => {
        'type': type,
        'coordinates': coordinates,
      };
}

class GeoData {
  final GeoPoint geo;
  final String location;

  GeoData({required this.geo, required this.location});

  Map<String, dynamic> toJson() => {
        'geo': geo.toJson(),
        'location': location,
      };
}

class LocationService {
  final bool debug;

  LocationService({this.debug = false});

  Future<bool> _ensureServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) throw Exception("Location services are disabled.");
    return enabled;
  }

  Future<void> _ensurePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied.");
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied.");
    }
  }

  Future<Position> _getPosition() async {
    await _ensureServiceEnabled();
    await _ensurePermission();

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> _getLocationName(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return place.locality ??
            place.administrativeArea ??
            place.country ??
            '';
      }
    } catch (e) {
      if (debug) print("Reverse geocoding error: $e");
    }
    return '';
  }

  Future<GeoData> getGeoData() async {
    final pos = await _getPosition();

    final geoPoint = GeoPoint(
      type: 'Point',
      coordinates: [pos.longitude, pos.latitude],
    );

    final locationName = await _getLocationName(pos.latitude, pos.longitude);

    return GeoData(geo: geoPoint, location: locationName);
  }
}
