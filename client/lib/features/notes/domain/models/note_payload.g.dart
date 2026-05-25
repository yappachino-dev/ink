// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotePayload _$NotePayloadFromJson(Map<String, dynamic> json) => _NotePayload(
  quillData: json['quillData'] as List<dynamic>,
  isCompleted: json['isCompleted'] as bool? ?? false,
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  dueTime: _$JsonConverterFromJson<String, TimeOfDay>(
    json['dueTime'],
    const TimeOfDayConverter().fromJson,
  ),
  priority:
      $enumDecodeNullable(_$TaskPriorityEnumMap, json['priority']) ??
      TaskPriority.none,
  reminderMinutesBefore: (json['reminderMinutesBefore'] as num?)?.toInt(),
);

Map<String, dynamic> _$NotePayloadToJson(_NotePayload instance) =>
    <String, dynamic>{
      'quillData': instance.quillData,
      'isCompleted': instance.isCompleted,
      'dueDate': instance.dueDate?.toIso8601String(),
      'dueTime': _$JsonConverterToJson<String, TimeOfDay>(
        instance.dueTime,
        const TimeOfDayConverter().toJson,
      ),
      'priority': _$TaskPriorityEnumMap[instance.priority]!,
      'reminderMinutesBefore': instance.reminderMinutesBefore,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$TaskPriorityEnumMap = {
  TaskPriority.none: 'none',
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
