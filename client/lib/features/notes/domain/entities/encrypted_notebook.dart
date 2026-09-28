import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/core/domain/sync_status.dart';

part 'encrypted_notebook.freezed.dart';

@freezed
sealed class EncryptedNotebook with _$EncryptedNotebook {
  const factory EncryptedNotebook({
    required String id,

    required Uint8List encryptedContent,

    required int localVersion,
    required int lastSyncedVersion,
    required SyncStatus syncStatus,

    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _EncryptedNotebook;

  const EncryptedNotebook._();
}
