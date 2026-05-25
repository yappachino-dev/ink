// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NoteDto _$NoteDtoFromJson(Map<String, dynamic> json) => _NoteDto(
  id: json['id'] as String,
  encryptedTitle: const Uint8ListConverter().fromJson(
    json['encryptedTitle'] as String,
  ),
  encryptedContent: const Uint8ListConverter().fromJson(
    json['encryptedContent'] as String,
  ),
  version: (json['version'] as num).toInt(),
  createdAt: const DateTimeUtcConverter().fromJson(json['createdAt'] as String),
  updatedAt: const DateTimeUtcConverter().fromJson(json['updatedAt'] as String),
  deletedAt: _$JsonConverterFromJson<String, DateTime>(
    json['deletedAt'],
    const DateTimeUtcConverter().fromJson,
  ),
  projectId: json['projectId'] as String?,
);

Map<String, dynamic> _$NoteDtoToJson(_NoteDto instance) => <String, dynamic>{
  'id': instance.id,
  'encryptedTitle': const Uint8ListConverter().toJson(instance.encryptedTitle),
  'encryptedContent': const Uint8ListConverter().toJson(
    instance.encryptedContent,
  ),
  'version': instance.version,
  'createdAt': const DateTimeUtcConverter().toJson(instance.createdAt),
  'updatedAt': const DateTimeUtcConverter().toJson(instance.updatedAt),
  'deletedAt': _$JsonConverterToJson<String, DateTime>(
    instance.deletedAt,
    const DateTimeUtcConverter().toJson,
  ),
  'projectId': instance.projectId,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
