import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/core/domain/sync_status.dart';

part 'encrypted_note.freezed.dart';

@freezed
sealed class EncryptedNote with _$EncryptedNote {
  const factory EncryptedNote({
    required String id,

    required Uint8List encryptedTitle,
    required Uint8List encryptedContent,

    required int localVersion,
    required int lastSyncedVersion,
    required SyncStatus syncStatus,

    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,

    String? projectId,
  }) = _EncryptedNote;

  const EncryptedNote._();

  bool get isSynced => syncStatus == SyncStatus.synced;
}
