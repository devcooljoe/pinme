import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/app_settings.dart';

class LocationService {
  static Future<bool> isLocationServiceEnabled() async {
    return await geo.Geolocator.isLocationServiceEnabled();
  }

  static Future<geo.LocationPermission> checkPermission() async {
    return await geo.Geolocator.checkPermission();
  }

  static Future<geo.LocationPermission> requestPermission() async {
    return await geo.Geolocator.requestPermission();
  }

  static Future<bool> requestAlwaysLocationPermission() async {
    final status = await Permission.locationAlways.request();
    return status == PermissionStatus.granted;
  }

  static Future<geo.Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.balanced,
  }) async {
    try {
      return await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: _mapAccuracy(accuracy),
      );
    } catch (e) {
      return null;
    }
  }

  static Stream<geo.Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.balanced,
    int intervalMs = 30000,
  }) {
    final locationSettings = geo.LocationSettings(
      accuracy: _mapAccuracy(accuracy),
      distanceFilter: 10,
      timeLimit: Duration(milliseconds: intervalMs),
    );

    return geo.Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return geo.Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  static double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return geo.Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  static geo.LocationAccuracy _mapAccuracy(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.high:
        return geo.LocationAccuracy.best;
      case LocationAccuracy.balanced:
        return geo.LocationAccuracy.high;
      case LocationAccuracy.low:
        return geo.LocationAccuracy.medium;
    }
  }

  static Future<bool> openLocationSettings() async {
    return await geo.Geolocator.openLocationSettings();
  }

  static Future<bool> openAppSettings() async {
    return await geo.Geolocator.openAppSettings();
  }

  static Future<PermissionStatus> getLocationPermissionStatus() async {
    return await Permission.locationAlways.status;
  }

  static Future<bool> shouldShowRequestPermissionRationale() async {
    return await Permission.locationAlways.shouldShowRequestRationale;
  }
}
