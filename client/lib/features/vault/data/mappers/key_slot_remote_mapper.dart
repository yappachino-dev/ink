import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/features/vault/data/dto/key_slot_dto.dart';
import 'package:ink/features/vault/domain/entities/key_slot.dart';

extension KeySlotDtoToDomain on KeySlotDto {
  KeySlot toDomain() => KeySlot(
    type: type,
    salt: salt,
    wrappedMasterKey: wrappedMasterKey,
    syncStatus: SyncStatus.synced,
    updatedAt: updatedAt,
  );
}

extension KeySlotToDto on KeySlot {
  KeySlotDto toDto() => KeySlotDto(
    type: type,
    salt: salt,
    wrappedMasterKey: wrappedMasterKey,
    updatedAt: updatedAt,
  );
}
