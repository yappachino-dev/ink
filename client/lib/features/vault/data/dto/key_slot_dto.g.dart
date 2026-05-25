// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_slot_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KeySlotDto _$KeySlotDtoFromJson(Map<String, dynamic> json) => _KeySlotDto(
  type: $enumDecode(_$KeyTypeEnumMap, json['type']),
  salt: const Uint8ListConverter().fromJson(json['salt'] as String),
  wrappedMasterKey: const Uint8ListConverter().fromJson(
    json['wrappedMasterKey'] as String,
  ),
  updatedAt: const DateTimeUtcConverter().fromJson(json['updatedAt'] as String),
);

Map<String, dynamic> _$KeySlotDtoToJson(_KeySlotDto instance) =>
    <String, dynamic>{
      'type': _$KeyTypeEnumMap[instance.type]!,
      'salt': const Uint8ListConverter().toJson(instance.salt),
      'wrappedMasterKey': const Uint8ListConverter().toJson(
        instance.wrappedMasterKey,
      ),
      'updatedAt': const DateTimeUtcConverter().toJson(instance.updatedAt),
    };

const _$KeyTypeEnumMap = {
  KeyType.pin: 'pin',
  KeyType.pattern: 'pattern',
  KeyType.recoveryPhrase: 'recoveryPhrase',
};
