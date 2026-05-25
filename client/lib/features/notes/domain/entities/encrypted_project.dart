import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/core/services/sync/sync_status.dart';

part 'encrypted_project.freezed.dart';

@freezed
sealed class EncryptedProject with _$EncryptedProject {
  const factory EncryptedProject({
    required String id,

    required Uint8List encryptedContent,

    required int localVersion,
    required int lastSyncedVersion,
    required SyncStatus syncStatus,

    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _EncryptedProject;

  const EncryptedProject._();
}
