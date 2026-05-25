import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';

part 'key_slot.freezed.dart';

@freezed
sealed class KeySlot with _$KeySlot {
  const factory KeySlot({
    required KeyType type,
    required Uint8List salt,
    required Uint8List wrappedMasterKey,
    required DateTime updatedAt,
    @Default(SyncStatus.modified) SyncStatus syncStatus,
  }) = _KeySlot;
}
