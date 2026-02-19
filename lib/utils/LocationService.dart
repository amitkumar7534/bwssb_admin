import 'package:geolocator/geolocator.dart';

class LocationService {
  double? latitude;
  double? longitude;

  /// Request location permission and fetch current coordinates
  Future<void> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("❌ Location services are disabled.");
    }

    // Check & request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("❌ Location permission denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("❌ Location permission permanently denied. Enable in settings.");
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    latitude = position.latitude;
    longitude = position.longitude;
  }

  /// Returns lat/long as a simple map
  Map<String, double?> toMap() {
    return {
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}
