import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:geofence_service/geofence_service.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/reminder.dart';
import 'notification_service.dart';

class PinMeGeofenceService {
  static final GeofenceService _geofenceService = GeofenceService.instance
      .setup(
        interval: 5000,
        accuracy: 100,
        loiteringDelayMs: 60000,
        statusChangeDelayMs: 10000,
        useActivityRecognition: true,
        allowMockLocations: false,
        printDevLog: false,
        geofenceRadiusSortType: GeofenceRadiusSortType.DESC,
      );

  static final Map<String, Timer> _dwellTimers = {};
  static final Map<String, DateTime> _lastTriggerTimes = {};
  static const int _debounceSeconds = 120; // 2 minutes

  static Future<void> initialize() async {
    _geofenceService.addGeofenceStatusChangeListener((
      geofence,
      geofenceRadius,
      geofenceStatus,
      location,
    ) async {
      _onGeofenceStatusChanged(
        geofence,
        geofenceRadius,
        geofenceStatus,
        location,
      );
    });
    _geofenceService.addLocationChangeListener((location) {
      _onLocationChanged(location);
    });
    _geofenceService.addLocationServicesStatusChangeListener((status) {
      _onLocationServicesStatusChanged(status);
    });
    _geofenceService.addActivityChangeListener((prevActivity, currActivity) {
      _onActivityChanged(prevActivity, currActivity);
    });
  }

  static Future<void> registerGeofences(List<Reminder> reminders) async {
    final enabledReminders = reminders.where((r) => r.enabled).toList();
    
    // Apply platform-specific limits
    final limitedReminders = _applyPlatformLimits(enabledReminders);
    
    final geofences = limitedReminders
        .map(
          (r) => Geofence(
            id: r.id,
            latitude: r.latitude,
            longitude: r.longitude,
            radius: [
              GeofenceRadius(id: 'radius_${r.id}', length: r.radiusMeters),
            ],
          ),
        )
        .toList();

    _geofenceService.clearGeofenceList();
    _geofenceService.addGeofenceList(geofences);
  }
  
  static List<Reminder> _applyPlatformLimits(List<Reminder> reminders) {
    // iOS has ~20 geofence limit, Android can handle 50-100
    final limit = Platform.isIOS ? 20 : 100;
    
    if (reminders.length <= limit) return reminders;
    
    // Return limited number of reminders
    return reminders.take(limit).toList();
  }

  static Future<void> startService() async {
    if (_geofenceService.isRunningService) return;
    await _geofenceService.start();
  }

  static Future<void> stopService() async {
    await _geofenceService.stop();
  }

  static void _onGeofenceStatusChanged(
    Geofence geofence,
    GeofenceRadius geofenceRadius,
    GeofenceStatus geofenceStatus,
    Location location,
  ) {
    final reminderId = geofence.id;
    final now = DateTime.now();

    // Debounce rapid status changes
    final lastTrigger = _lastTriggerTimes[reminderId];
    if (lastTrigger != null &&
        now.difference(lastTrigger).inSeconds < _debounceSeconds) {
      return;
    }

    _lastTriggerTimes[reminderId] = now;

    switch (geofenceStatus) {
      case GeofenceStatus.ENTER:
        _handleEnterEvent(reminderId);
        break;
      case GeofenceStatus.EXIT:
        _handleExitEvent(reminderId);
        break;
      case GeofenceStatus.DWELL:
        _handleDwellEvent(reminderId);
        break;
    }
  }

  static void _handleEnterEvent(String reminderId) {
    // Get reminder from storage and check if it's ENTER type
    _triggerReminder(reminderId, TriggerType.enter);

    // Start dwell timer if needed
    _startDwellTimer(reminderId);
  }

  static void _handleExitEvent(String reminderId) {
    // Cancel dwell timer
    _dwellTimers[reminderId]?.cancel();
    _dwellTimers.remove(reminderId);

    // Trigger if EXIT type
    _triggerReminder(reminderId, TriggerType.exit);
  }

  static void _handleDwellEvent(String reminderId) {
    // This is handled by our custom timer
  }

  static void _startDwellTimer(String reminderId) {
    // This would need to get the reminder from storage to check dwell time
    // For now, using a placeholder
    const dwellMinutes = 5;

    _dwellTimers[reminderId] = Timer(Duration(minutes: dwellMinutes), () {
      _triggerReminder(reminderId, TriggerType.dwell);
    });
  }

  static void _triggerReminder(String reminderId, TriggerType expectedType) {
    // This would need to:
    // 1. Get reminder from storage
    // 2. Check if trigger type matches
    // 3. Check cooldown
    // 4. Show notification
    // 5. Update lastTriggeredAt

    NotificationService.showReminderNotification(
      id: reminderId.hashCode,
      title: 'Location Reminder',
      body: 'You have a reminder at this location',
      payload: reminderId,
    );
  }

  static void _onLocationChanged(Location location) {
    // Handle location updates if needed
  }

  static void _onLocationServicesStatusChanged(bool status) {
    // Handle location services status changes
  }

  static void _onActivityChanged(Activity prevActivity, Activity currActivity) {
    // Handle activity changes for better battery optimization
  }

  @pragma('vm:entry-point')
  static void onStart() async {
    // Background service entry point
  }

  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}
