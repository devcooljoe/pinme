import 'dart:io';
import 'package:equatable/equatable.dart';

enum LocationAccuracy { high, balanced, low }

class AppSettings extends Equatable {
  final LocationAccuracy accuracy;
  final int locationUpdateIntervalMs;
  final int maxActiveGeofences;
  final String notificationChannelId;

  const AppSettings({
    required this.accuracy,
    required this.locationUpdateIntervalMs,
    required this.maxActiveGeofences,
    required this.notificationChannelId,
  });

  factory AppSettings.defaultSettings() {
    return AppSettings(
      accuracy: LocationAccuracy.balanced,
      locationUpdateIntervalMs: 30000, // 30 seconds
      maxActiveGeofences: Platform.isIOS ? 20 : 100, // Platform-specific limits
      notificationChannelId: 'pinme_reminders',
    );
  }

  AppSettings copyWith({
    LocationAccuracy? accuracy,
    int? locationUpdateIntervalMs,
    int? maxActiveGeofences,
    String? notificationChannelId,
  }) {
    return AppSettings(
      accuracy: accuracy ?? this.accuracy,
      locationUpdateIntervalMs: locationUpdateIntervalMs ?? this.locationUpdateIntervalMs,
      maxActiveGeofences: maxActiveGeofences ?? this.maxActiveGeofences,
      notificationChannelId: notificationChannelId ?? this.notificationChannelId,
    );
  }

  @override
  List<Object> get props => [
        accuracy,
        locationUpdateIntervalMs,
        maxActiveGeofences,
        notificationChannelId,
      ];
}