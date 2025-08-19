// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 1;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      accuracy: fields[0] as int,
      locationUpdateIntervalMs: fields[1] as int,
      maxActiveGeofences: fields[2] as int,
      notificationChannelId: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.accuracy)
      ..writeByte(1)
      ..write(obj.locationUpdateIntervalMs)
      ..writeByte(2)
      ..write(obj.maxActiveGeofences)
      ..writeByte(3)
      ..write(obj.notificationChannelId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsModel _$SettingsModelFromJson(Map<String, dynamic> json) =>
    SettingsModel(
      accuracy: json['accuracy'] as int,
      locationUpdateIntervalMs: json['locationUpdateIntervalMs'] as int,
      maxActiveGeofences: json['maxActiveGeofences'] as int,
      notificationChannelId: json['notificationChannelId'] as String,
    );

Map<String, dynamic> _$SettingsModelToJson(SettingsModel instance) =>
    <String, dynamic>{
      'accuracy': instance.accuracy,
      'locationUpdateIntervalMs': instance.locationUpdateIntervalMs,
      'maxActiveGeofences': instance.maxActiveGeofences,
      'notificationChannelId': instance.notificationChannelId,
    };