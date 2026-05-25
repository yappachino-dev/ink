import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/core/infrastructure/serialization/json_helpers.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';

part 'key_slot_dto.g.dart';
part 'key_slot_dto.freezed.dart';

@freezed
sealed class KeySlotDto with _$KeySlotDto {
  const factory KeySlotDto({
    required KeyType type,
    @Uint8ListConverter() required Uint8List salt,
    @Uint8ListConverter() required Uint8List wrappedMasterKey,
    @DateTimeUtcConverter() required DateTime updatedAt,
  }) = _KeySlotDto;

  factory KeySlotDto.fromJson(Map<String, dynamic> json) =>
      _$KeySlotDtoFromJson(json);
}
