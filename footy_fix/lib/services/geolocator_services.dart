import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

class GeolocatorService {
  static final GeolocatorService _instance = GeolocatorService._internal();
  Position? _currentPosition;
  Timer? _locationTimer;

  factory GeolocatorService() {
    return _instance;
  }

  GeolocatorService._internal();

  Position? get currentPosition => _currentPosition;

  // Method to start periodic location updates
  void startPeriodicLocationUpdates(Duration interval) {
    _locationTimer?.cancel(); // Cancel any existing timer
    _locationTimer = Timer.periodic(interval, (Timer t) async {
      await determinePosition();
      // Do something with the updated location, like a callback or a Stream
    });
  }

  // Optional: Method to stop periodic location updates
  void stopPeriodicLocationUpdates() {
    _locationTimer?.cancel();
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // continue accessing the position of the device
    _currentPosition = await Geolocator.getCurrentPosition();

    if (_currentPosition != null) {
      return _currentPosition!;
    } else {
      return Future.error('Could not determine current position');
    }
  }

  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    double distance = Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);

    return double.parse((distance).toStringAsFixed(1));
  }

  Future<double> distanceToLocation(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) async {
    return calculateDistance(
        startLatitude, startLongitude, endLatitude, endLongitude);
  }

  // Optional: Method to refresh the current position
  Future<void> refreshPosition() async {
    _currentPosition = null;
    await determinePosition();
  }

  Future<Map<double, double>?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        double latitude = locations.first.latitude;
        double longitude = locations.first.longitude;

        return {latitude: longitude};
      } else {
        return null;
      }
    } catch (e) {
      print("Error occurred: $e");
      return null;
    }
  }

  void setupLocationListener() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position? position) {
      if (position != null) {
        // Handle the location change here
        print("Location updated: ${position.latitude}, ${position.longitude}");
      }
    });

    // Don't forget to cancel the stream subscription when no longer needed
    // positionStream.cancel();
  }
}
