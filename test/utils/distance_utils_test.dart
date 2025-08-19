import 'package:flutter_test/flutter_test.dart';
import 'package:pinme/presentation/utils/distance_utils.dart';

void main() {
  group('DistanceUtils', () {
    test('calculateDistance returns correct distance', () {
      // San Francisco to Los Angeles (approximately 559 km)
      const lat1 = 37.7749;
      const lon1 = -122.4194;
      const lat2 = 34.0522;
      const lon2 = -118.2437;
      
      final distance = DistanceUtils.calculateDistance(lat1, lon1, lat2, lon2);
      
      // Allow 1% margin of error
      expect(distance, closeTo(559000, 5590));
    });
    
    test('calculateDistance returns 0 for same coordinates', () {
      const lat = 37.7749;
      const lon = -122.4194;
      
      final distance = DistanceUtils.calculateDistance(lat, lon, lat, lon);
      
      expect(distance, equals(0));
    });
    
    test('shouldTriggerWithHysteresis prevents oscillation', () {
      const radius = 100.0;
      const hysteresisPercent = 0.1;
      
      // Test enter trigger with hysteresis
      bool shouldTrigger = DistanceUtils.shouldTriggerWithHysteresis(
        85, // 85m from center
        radius,
        false, // was outside
        hysteresisPercent: hysteresisPercent,
      );
      expect(shouldTrigger, isTrue); // Should trigger enter (85 < 90)
      
      // Test exit trigger with hysteresis
      shouldTrigger = DistanceUtils.shouldTriggerWithHysteresis(
        115, // 115m from center
        radius,
        true, // was inside
        hysteresisPercent: hysteresisPercent,
      );
      expect(shouldTrigger, isTrue); // Should trigger exit (115 > 110)
      
      // Test no trigger in buffer zone
      shouldTrigger = DistanceUtils.shouldTriggerWithHysteresis(
        95, // 95m from center
        radius,
        false, // was outside
        hysteresisPercent: hysteresisPercent,
      );
      expect(shouldTrigger, isFalse); // Should not trigger (95 > 90)
    });
    
    test('formatDistance formats correctly', () {
      expect(DistanceUtils.formatDistance(50), equals('50m'));
      expect(DistanceUtils.formatDistance(999), equals('999m'));
      expect(DistanceUtils.formatDistance(1000), equals('1.0km'));
      expect(DistanceUtils.formatDistance(1500), equals('1.5km'));
      expect(DistanceUtils.formatDistance(12345), equals('12.3km'));
    });
  });
}