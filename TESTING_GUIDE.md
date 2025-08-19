# PinMe Testing Guide

This guide covers testing strategies for the PinMe location-based reminder app.

## Testing Strategy

### Unit Tests
- Domain entities and business logic
- Utility functions (distance calculations, hysteresis)
- Repository implementations
- Use cases

### Integration Tests
- Geofence service integration
- Notification service
- Location service
- Database operations

### Manual Testing
- Location simulation
- Background behavior
- Permission flows
- Platform-specific features

## Running Tests

### Unit Tests
```bash
flutter test
```

### With Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Integration Tests
```bash
flutter test integration_test/
```

## Location Simulation

### Android Studio
1. Open Extended Controls (⋯ button in emulator)
2. Navigate to Location tab
3. Set custom coordinates or load GPX/KML files

### Xcode Simulator
1. Device → Location → Custom Location
2. Enter coordinates manually
3. Use GPX files: Debug → Simulate Location

### Test Locations (San Francisco)
```
Whole Foods Market: 37.7749, -122.4194
Union Square: 37.7880, -122.4075
Golden Gate Park: 37.7694, -122.4862
Fisherman's Wharf: 37.8080, -122.4177
Lombard Street: 37.8021, -122.4187
```

## Test Scenarios

### Basic Functionality
1. **Create Reminder**
   - Open app
   - Tap + button
   - Fill form with test location
   - Save reminder
   - Verify reminder appears in list

2. **Enter Geofence**
   - Create reminder with ENTER trigger
   - Simulate location inside geofence
   - Verify notification appears
   - Check reminder shows as triggered

3. **Exit Geofence**
   - Create reminder with EXIT trigger
   - Simulate location inside geofence
   - Move location outside geofence
   - Verify notification appears

4. **Dwell Trigger**
   - Create reminder with DWELL trigger (5 minutes)
   - Simulate location inside geofence
   - Wait 5 minutes (or use timer manipulation)
   - Verify notification appears

### Edge Cases

1. **Rapid Location Changes**
   - Create reminder near boundary
   - Rapidly toggle location in/out of geofence
   - Verify debouncing prevents spam notifications

2. **Cooldown Period**
   - Trigger reminder
   - Immediately trigger again
   - Verify cooldown prevents duplicate notification

3. **App Backgrounded**
   - Create reminder
   - Background app
   - Trigger geofence
   - Verify notification still appears

4. **Device Reboot**
   - Create reminders
   - Reboot device/simulator
   - Verify reminders are restored
   - Verify geofences are re-registered

### Permission Testing

1. **Location Permission Denied**
   - Deny location permission
   - Verify permission banner appears
   - Verify app handles gracefully

2. **Always Permission Required**
   - Grant "While Using App" only
   - Verify app requests "Always" permission
   - Test background functionality

3. **Notification Permission**
   - Deny notification permission
   - Verify app requests permission
   - Test notification functionality

### Platform-Specific Testing

#### iOS
1. **Geofence Limit**
   - Create 25+ reminders
   - Verify only nearest 20 are active
   - Verify limit banner appears

2. **Background App Refresh**
   - Disable Background App Refresh
   - Test geofence functionality
   - Verify limitations are handled

#### Android
1. **Battery Optimization**
   - Enable battery optimization for app
   - Test background functionality
   - Verify optimization prompt appears

2. **Doze Mode**
   - Enable Doze mode simulation
   - Test geofence reliability
   - Verify wake locks work correctly

## Mock Data for Testing

### Sample Reminders
The app includes sample data in `assets/sample_data/sample_reminders.json`:

1. **Grocery Store** (Enter trigger, 150m radius)
2. **Dry Cleaner** (Enter trigger, 100m radius)  
3. **Home** (Dwell trigger, 10 minutes, 200m radius)
4. **Office** (Exit trigger, 300m radius, disabled)
5. **Garden Center** (Enter trigger, 50m radius, daily cooldown)

### Loading Sample Data
```dart
// In debug mode, load sample data
if (kDebugMode) {
  await loadSampleReminders();
}
```

## Performance Testing

### Battery Usage
1. Monitor battery drain over 24 hours
2. Compare different accuracy settings
3. Test with various numbers of active geofences

### Memory Usage
1. Monitor memory usage during normal operation
2. Test with large numbers of reminders
3. Check for memory leaks in background operation

### Location Accuracy
1. Test different accuracy settings
2. Measure actual vs expected trigger distances
3. Test in various environments (urban, rural, indoor)

## Automated Testing

### GitHub Actions
The CI pipeline runs:
- Unit tests
- Code analysis
- Build verification
- Coverage reporting

### Local Testing Script
```bash
#!/bin/bash
echo "Running PinMe test suite..."

echo "1. Unit tests..."
flutter test

echo "2. Integration tests..."
flutter test integration_test/

echo "3. Code analysis..."
flutter analyze

echo "4. Build verification..."
flutter build apk --debug
flutter build ios --debug --no-codesign

echo "All tests completed!"
```

## Debugging Tips

### Location Issues
```bash
# Android: Check location services
adb shell dumpsys location

# View geofence logs
adb logcat | grep -i geofence

# Check notification logs
adb logcat | grep -i notification
```

### iOS Debugging
```bash
# View device logs
xcrun simctl spawn booted log stream --predicate 'subsystem contains "com.example.pinme"'

# Check location authorization
xcrun simctl privacy booted grant location com.example.pinme
```

### Common Issues

1. **Geofences not triggering**
   - Check location permissions
   - Verify location services enabled
   - Ensure geofence radius ≥ 100m
   - Check battery optimization settings

2. **Notifications not appearing**
   - Verify notification permissions
   - Check Do Not Disturb settings
   - Ensure notification channel is created

3. **Background operation failing**
   - Check battery optimization
   - Verify background app refresh (iOS)
   - Ensure app is not being killed by system

## Test Coverage Goals

- **Unit Tests**: >90% coverage
- **Integration Tests**: All critical paths
- **Manual Tests**: All user scenarios
- **Platform Tests**: iOS and Android specific features

## Reporting Issues

When reporting bugs, include:
1. Device model and OS version
2. App version and build number
3. Steps to reproduce
4. Expected vs actual behavior
5. Relevant logs or screenshots
6. Location simulation details (if applicable)