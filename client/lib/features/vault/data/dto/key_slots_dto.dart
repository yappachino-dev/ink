import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/features/vault/data/dto/key_slot_dto.dart';

part 'key_slots_dto.freezed.dart';
part 'key_slots_dto.g.dart';

@freezed
sealed class KeySlotsDto with _$KeySlotsDto {
  const factory KeySlotsDto({
    required List<KeySlotDto> keys,
  }) = _KeySlotsDto;

  factory KeySlotsDto.fromJson(Map<String, dynamic> json) =>
      _$KeySlotsDtoFromJson(json);
}
