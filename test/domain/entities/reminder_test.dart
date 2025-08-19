import 'package:flutter_test/flutter_test.dart';
import 'package:pinme/domain/entities/reminder.dart';

void main() {
  group('Reminder', () {
    late Reminder testReminder;

    setUp(() {
      testReminder = Reminder(
        id: 'test-id',
        title: 'Test Reminder',
        notes: 'Test notes',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 100.0,
        triggerType: TriggerType.enter,
        enabled: true,
        createdAt: DateTime(2024, 1, 1),
        cooldownMinutes: 120,
        placeName: 'Test Place',
        address: 'Test Address',
      );
    });

    test('should create reminder with required fields', () {
      expect(testReminder.id, equals('test-id'));
      expect(testReminder.title, equals('Test Reminder'));
      expect(testReminder.enabled, isTrue);
      expect(testReminder.triggerType, equals(TriggerType.enter));
    });

    test('copyWith should update specified fields', () {
      final updatedReminder = testReminder.copyWith(
        title: 'Updated Title',
        enabled: false,
      );

      expect(updatedReminder.title, equals('Updated Title'));
      expect(updatedReminder.enabled, isFalse);
      expect(updatedReminder.id, equals(testReminder.id)); // Unchanged
    });

    test('isInCooldown should return false when never triggered', () {
      expect(testReminder.isInCooldown, isFalse);
    });

    test('isInCooldown should return true when in cooldown period', () {
      final recentlyTriggered = testReminder.copyWith(
        lastTriggeredAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );

      expect(recentlyTriggered.isInCooldown, isTrue);
    });

    test('isInCooldown should return false when cooldown period expired', () {
      final oldTrigger = testReminder.copyWith(
        lastTriggeredAt: DateTime.now().subtract(const Duration(hours: 3)),
      );

      expect(oldTrigger.isInCooldown, isFalse);
    });

    test('equality should work correctly', () {
      final sameReminder = Reminder(
        id: 'test-id',
        title: 'Test Reminder',
        notes: 'Test notes',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 100.0,
        triggerType: TriggerType.enter,
        enabled: true,
        createdAt: DateTime(2024, 1, 1),
        cooldownMinutes: 120,
        placeName: 'Test Place',
        address: 'Test Address',
      );

      expect(testReminder, equals(sameReminder));
    });
  });
}