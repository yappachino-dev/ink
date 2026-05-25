// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_slots_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KeySlotsDto _$KeySlotsDtoFromJson(Map<String, dynamic> json) => _KeySlotsDto(
  keys: (json['keys'] as List<dynamic>)
      .map((e) => KeySlotDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$KeySlotsDtoToJson(_KeySlotsDto instance) =>
    <String, dynamic>{'keys': instance.keys};
