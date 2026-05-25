// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectPayload _$ProjectPayloadFromJson(Map<String, dynamic> json) =>
    _ProjectPayload(
      title: json['title'] as String,
      emoji: json['emoji'] as String,
      colorValue: const ColorConverter().fromJson(json['colorValue'] as String),
    );

Map<String, dynamic> _$ProjectPayloadToJson(_ProjectPayload instance) =>
    <String, dynamic>{
      'title': instance.title,
      'emoji': instance.emoji,
      'colorValue': const ColorConverter().toJson(instance.colorValue),
    };
