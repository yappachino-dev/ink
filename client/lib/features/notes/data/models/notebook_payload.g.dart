// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notebook_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotebookPayload _$NotebookPayloadFromJson(Map<String, dynamic> json) =>
    _NotebookPayload(
      title: json['title'] as String,
      emoji: json['emoji'] as String,
      colorValue: const ColorConverter().fromJson(json['colorValue'] as String),
    );

Map<String, dynamic> _$NotebookPayloadToJson(_NotebookPayload instance) =>
    <String, dynamic>{
      'title': instance.title,
      'emoji': instance.emoji,
      'colorValue': const ColorConverter().toJson(instance.colorValue),
    };
