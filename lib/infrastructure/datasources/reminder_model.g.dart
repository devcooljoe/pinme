// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderModelAdapter extends TypeAdapter<ReminderModel> {
  @override
  final int typeId = 0;

  @override
  ReminderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderModel(
      id: fields[0] as String,
      title: fields[1] as String,
      notes: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      radiusMeters: fields[5] as double,
      triggerType: fields[6] as int,
      dwellMinutes: fields[7] as int?,
      enabled: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      lastTriggeredAt: fields[10] as DateTime?,
      cooldownMinutes: fields[11] as int,
      placeName: fields[12] as String,
      address: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.radiusMeters)
      ..writeByte(6)
      ..write(obj.triggerType)
      ..writeByte(7)
      ..write(obj.dwellMinutes)
      ..writeByte(8)
      ..write(obj.enabled)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.lastTriggeredAt)
      ..writeByte(11)
      ..write(obj.cooldownMinutes)
      ..writeByte(12)
      ..write(obj.placeName)
      ..writeByte(13)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReminderModel _$ReminderModelFromJson(Map<String, dynamic> json) =>
    ReminderModel(
      id: json['id'] as String,
      title: json['title'] as String,
      notes: json['notes'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeters: (json['radiusMeters'] as num).toDouble(),
      triggerType: json['triggerType'] as int,
      dwellMinutes: json['dwellMinutes'] as int?,
      enabled: json['enabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastTriggeredAt: json['lastTriggeredAt'] == null
          ? null
          : DateTime.parse(json['lastTriggeredAt'] as String),
      cooldownMinutes: json['cooldownMinutes'] as int,
      placeName: json['placeName'] as String,
      address: json['address'] as String,
    );

Map<String, dynamic> _$ReminderModelToJson(ReminderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'notes': instance.notes,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radiusMeters': instance.radiusMeters,
      'triggerType': instance.triggerType,
      'dwellMinutes': instance.dwellMinutes,
      'enabled': instance.enabled,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastTriggeredAt': instance.lastTriggeredAt?.toIso8601String(),
      'cooldownMinutes': instance.cooldownMinutes,
      'placeName': instance.placeName,
      'address': instance.address,
    };