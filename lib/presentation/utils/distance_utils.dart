import 'dart:math' as math;

class DistanceUtils {
  /// Calculate distance between two points using Haversine formula
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // Earth's radius in meters
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  /// Apply hysteresis to prevent oscillation at geofence boundaries
  static bool shouldTriggerWithHysteresis(
    double currentDistance,
    double radius,
    bool wasInside,
    {double hysteresisPercent = 0.1}
  ) {
    final double hysteresisBuffer = radius * hysteresisPercent;
    
    if (wasInside) {
      // If was inside, need to be clearly outside to trigger exit
      return currentDistance > (radius + hysteresisBuffer);
    } else {
      // If was outside, need to be clearly inside to trigger enter
      return currentDistance < (radius - hysteresisBuffer);
    }
  }
  
  /// Format distance for display
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
    }
  }
  
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}