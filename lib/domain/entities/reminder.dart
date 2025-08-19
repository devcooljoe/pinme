import 'package:equatable/equatable.dart';

enum TriggerType { enter, exit, dwell }

class Reminder extends Equatable {
  final String id;
  final String title;
  final String notes;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final TriggerType triggerType;
  final int? dwellMinutes;
  final bool enabled;
  final DateTime createdAt;
  final DateTime? lastTriggeredAt;
  final int cooldownMinutes;
  final String placeName;
  final String address;

  const Reminder({
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

  Reminder copyWith({
    String? id,
    String? title,
    String? notes,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    TriggerType? triggerType,
    int? dwellMinutes,
    bool? enabled,
    DateTime? createdAt,
    DateTime? lastTriggeredAt,
    int? cooldownMinutes,
    String? placeName,
    String? address,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      triggerType: triggerType ?? this.triggerType,
      dwellMinutes: dwellMinutes ?? this.dwellMinutes,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      lastTriggeredAt: lastTriggeredAt ?? this.lastTriggeredAt,
      cooldownMinutes: cooldownMinutes ?? this.cooldownMinutes,
      placeName: placeName ?? this.placeName,
      address: address ?? this.address,
    );
  }

  bool get isInCooldown {
    if (lastTriggeredAt == null) return false;
    final cooldownEnd = lastTriggeredAt!.add(Duration(minutes: cooldownMinutes));
    return DateTime.now().isBefore(cooldownEnd);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        notes,
        latitude,
        longitude,
        radiusMeters,
        triggerType,
        dwellMinutes,
        enabled,
        createdAt,
        lastTriggeredAt,
        cooldownMinutes,
        placeName,
        address,
      ];
}