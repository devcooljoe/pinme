import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/app_settings.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class SettingsModel extends HiveObject {
  @HiveField(0)
  final int accuracy; // 0: high, 1: balanced, 2: low

  @HiveField(1)
  final int locationUpdateIntervalMs;

  @HiveField(2)
  final int maxActiveGeofences;

  @HiveField(3)
  final String notificationChannelId;

  SettingsModel({
    required this.accuracy,
    required this.locationUpdateIntervalMs,
    required this.maxActiveGeofences,
    required this.notificationChannelId,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsModelToJson(this);

  factory SettingsModel.fromEntity(AppSettings settings) {
    return SettingsModel(
      accuracy: settings.accuracy.index,
      locationUpdateIntervalMs: settings.locationUpdateIntervalMs,
      maxActiveGeofences: settings.maxActiveGeofences,
      notificationChannelId: settings.notificationChannelId,
    );
  }

  AppSettings toEntity() {
    return AppSettings(
      accuracy: LocationAccuracy.values[accuracy],
      locationUpdateIntervalMs: locationUpdateIntervalMs,
      maxActiveGeofences: maxActiveGeofences,
      notificationChannelId: notificationChannelId,
    );
  }
}