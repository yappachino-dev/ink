// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectDto _$ProjectDtoFromJson(Map<String, dynamic> json) => _ProjectDto(
  id: json['id'] as String,
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
);

Map<String, dynamic> _$ProjectDtoToJson(_ProjectDto instance) =>
    <String, dynamic>{
      'id': instance.id,
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
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
