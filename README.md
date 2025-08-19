# PinMe - Location-Based Reminder App

A production-ready Flutter app that creates location-based reminders using geofencing. Get reminded when you arrive at, leave, or spend time at specific locations.

## Features

- **Smart Geofencing**: Create reminders that trigger on enter, exit, or dwell
- **Background Operation**: Works when app is closed or device is locked
- **Battery Optimized**: Intelligent location tracking with configurable accuracy
- **Reliable Triggers**: Debouncing and hysteresis prevent false triggers
- **Cross-Platform**: Native Android and iOS support
- **Clean Architecture**: Domain-driven design with separation of concerns

## Tech Stack

- **State Management**: Hook Riverpod
- **Routing**: go_router
- **Storage**: Hive (encrypted local storage)
- **Location & Geofencing**: geofence_service + geolocator
- **Notifications**: flutter_local_notifications
- **Background Tasks**: workmanager
- **Maps**: google_maps_flutter + flutter_google_places
- **Permissions**: permission_handler

## Architecture

```
lib/
├── domain/              # Business logic layer
│   ├── entities/        # Core business objects
│   ├── repositories/    # Abstract interfaces
│   └── usecases/        # Business use cases
├── infrastructure/      # External concerns
│   ├── datasources/     # Data models (Hive)
│   ├── repositories/    # Repository implementations
│   └── services/        # Platform services
├── application/         # Application layer
│   ├── providers/       # Riverpod providers
│   └── notifiers/       # State notifiers
└── presentation/        # UI layer
    ├── pages/           # Screen widgets
    ├── widgets/         # Reusable components
    └── utils/           # UI utilities
```

## Platform Limitations

### iOS
- **Geofence Limit**: ~20 active geofences maximum
- **Permission Required**: "Always" location permission needed
- **Battery Optimization**: iOS may delay triggers to save battery
- **Background Modes**: Location updates must be declared

### Android
- **Geofence Capacity**: Can handle 50-100 geofences
- **Doze Mode**: May affect background operation
- **Battery Optimization**: Varies by manufacturer
- **Permissions**: Multiple location permissions required

## Setup Instructions

### Prerequisites

1. Flutter SDK (3.7.2+)
2. Android Studio / Xcode
3. Google Maps API key

### Installation

1. **Clone and setup**:
   ```bash
   git clone <repository-url>
   cd pinme
   flutter pub get
   ```

2. **Generate code**:
   ```bash
   flutter packages pub run build_runner build
   ```

3. **Google Maps API Key**:
   - Get API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Enable Maps SDK for Android/iOS and Places API
   - Add to `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_API_KEY_HERE" />
     ```
   - Add to `ios/Runner/AppDelegate.swift`:
     ```swift
     GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
     ```

### Android Setup

1. **Update `android/app/build.gradle`**:
   ```gradle
   android {
       compileSdkVersion 34
       minSdkVersion 21
       targetSdkVersion 34
   }
   ```

2. **Permissions are already configured in AndroidManifest.xml**

3. **Battery Optimization**:
   - App will prompt users to disable battery optimization
   - Required for reliable background operation

### iOS Setup

1. **Update `ios/Runner.xcodeproj`**:
   - Set minimum deployment target to iOS 12.0
   - Enable Background Modes capability
   - Add Location Updates background mode

2. **Permissions are already configured in Info.plist**

## Usage Guide

### Creating Reminders

1. **From Home**: Tap the + button
2. **From Map**: Long press on location, then tap "Add Reminder Here"
3. **Configure**:
   - Title and notes
   - Trigger type (Enter/Exit/Dwell)
   - Geofence radius (50m - 1000m)
   - Cooldown period (prevent spam)

### Trigger Types

- **On Arrive (Enter)**: Triggers when entering the geofence
- **On Leave (Exit)**: Triggers when leaving the geofence
- **While Here (Dwell)**: Triggers after staying inside for specified time

### Best Practices

1. **Geofence Size**: Use 100m+ radius for reliability
2. **Location Accuracy**: Balanced mode for battery efficiency
3. **Cooldown**: Set appropriate cooldown to prevent spam
4. **Permissions**: Always grant "Always" location permission

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Location Simulation

**Android Studio**:
1. Open Extended Controls (⋯ button)
2. Go to Location tab
3. Set custom coordinates
4. Use GPX/KML files for routes

**Xcode Simulator**:
1. Device → Location → Custom Location
2. Use GPX files: Debug → Simulate Location

### Sample Test Locations (San Francisco)
- Whole Foods: 37.7749, -122.4194
- Union Square: 37.7880, -122.4075
- Golden Gate Park: 37.7694, -122.4862

## CI/CD

### GitHub Actions
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk --debug
```

## Troubleshooting

### Common Issues

1. **Geofences not triggering**:
   - Check location permissions (Always)
   - Verify location services enabled
   - Disable battery optimization
   - Ensure geofence radius ≥ 100m

2. **App killed in background**:
   - Add to recent apps whitelist
   - Disable battery optimization
   - Check manufacturer-specific settings

3. **iOS geofence limit**:
   - App automatically manages nearest 20 reminders
   - Banner shown when limit reached

4. **Mock location detected**:
   - App shows warning but continues to work
   - Disable for production builds

### Debug Commands

```bash
# Check location permissions
adb shell dumpsys location

# View geofence status
adb logcat | grep -i geofence

# Monitor notifications
adb logcat | grep -i notification
```

## Performance Notes

### Battery Optimization
- **Balanced accuracy** by default (30-second intervals)
- **High accuracy** only when map is active
- **Geofence service** uses native region monitoring
- **Debouncing** prevents rapid trigger oscillation

### Memory Usage
- **Hive storage** for efficient local data
- **Stream providers** for reactive UI updates
- **Isolate-safe** background processing

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the excellent framework
- Plugin authors for geofencing and location services
- Clean Architecture principles by Robert C. Martin
