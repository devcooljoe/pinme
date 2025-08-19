import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/reminder.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class ReminderModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String notes;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  final double radiusMeters;

  @HiveField(6)
  final int triggerType; // 0: enter, 1: exit, 2: dwell

  @HiveField(7)
  final int? dwellMinutes;

  @HiveField(8)
  final bool enabled;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime? lastTriggeredAt;

  @HiveField(11)
  final int cooldownMinutes;

  @HiveField(12)
  final String placeName;

  @HiveField(13)
  final String address;

  ReminderModel({
    required this.id,
    required this.title,
    required this.notes,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.triggerType,
    this.dwellMinutes,
    required this.enabled,
    required this.createdAt,
    this.lastTriggeredAt,
    required this.cooldownMinutes,
    required this.placeName,
    required this.address,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) =>
      _$ReminderModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReminderModelToJson(this);

  factory ReminderModel.fromEntity(Reminder reminder) {
    return ReminderModel(
      id: reminder.id,
      title: reminder.title,
      notes: reminder.notes,
      latitude: reminder.latitude,
      longitude: reminder.longitude,
      radiusMeters: reminder.radiusMeters,
      triggerType: reminder.triggerType.index,
      dwellMinutes: reminder.dwellMinutes,
      enabled: reminder.enabled,
      createdAt: reminder.createdAt,
      lastTriggeredAt: reminder.lastTriggeredAt,
      cooldownMinutes: reminder.cooldownMinutes,
      placeName: reminder.placeName,
      address: reminder.address,
    );
  }

  Reminder toEntity() {
    return Reminder(
      id: id,
      title: title,
      notes: notes,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      triggerType: TriggerType.values[triggerType],
      dwellMinutes: dwellMinutes,
      enabled: enabled,
      createdAt: createdAt,
      lastTriggeredAt: lastTriggeredAt,
      cooldownMinutes: cooldownMinutes,
      placeName: placeName,
      address: address,
    );
  }
}