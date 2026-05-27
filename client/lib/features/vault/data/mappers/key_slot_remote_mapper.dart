import 'dart:typed_data';

import 'package:ink/core/infrastructure/grpc/gen/vault/v1/vault.pb.dart' as pb;
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/features/vault/data/dto/key_slot_dto.dart';
import 'package:ink/features/vault/domain/entities/key_slot.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

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

extension ProtoKeySlotToDomain on pb.KeySlot {
  KeySlot toDomain() => KeySlot(
    type: type.toDomain(),
    salt: Uint8List.fromList(salt),
    wrappedMasterKey: Uint8List.fromList(wrappedMasterKey),
    updatedAt: updatedAt.toDateTime(),
  );
}

extension ProtoKeyTypeToDomain on pb.KeyType {
  KeyType toDomain() => switch (this) {
    pb.KeyType.KEY_TYPE_PIN => KeyType.pin,
    pb.KeyType.KEY_TYPE_PATTERN => KeyType.pattern,
    pb.KeyType.KEY_TYPE_RECOVERY => KeyType.recoveryPhrase,
    _ => KeyType.unknown,
  };
}

extension KeySlotToProto on KeySlot {
  pb.KeySlot toProto() => pb.KeySlot(
    type: type.toProto(),
    salt: salt,
    wrappedMasterKey: wrappedMasterKey,
    updatedAt: Timestamp.fromDateTime(updatedAt),
  );
}

extension KeyTypeToProto on KeyType {
  pb.KeyType toProto() => switch (this) {
    KeyType.pin => pb.KeyType.KEY_TYPE_PIN,
    KeyType.pattern => pb.KeyType.KEY_TYPE_PATTERN,
    KeyType.recoveryPhrase => pb.KeyType.KEY_TYPE_RECOVERY,
    _ => pb.KeyType.KEY_TYPE_UNSPECIFIED,
  };
}
