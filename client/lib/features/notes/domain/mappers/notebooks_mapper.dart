import 'dart:typed_data';

import 'package:ink/features/notes/domain/entities/encrypted_notebook.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';

extension NotebookToEncrypted on Notebook {
  EncryptedNotebook toEncrypted({required Uint8List encryptedContent}) =>
      EncryptedNotebook(
        id: id,

        encryptedContent: encryptedContent,

        localVersion: localVersion,
        lastSyncedVersion: lastSyncedVersion,
        syncStatus: syncStatus,

        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );
}

extension EncryptedToNotebook on EncryptedNotebook {
  Notebook toNotebook({
    required String title,
    required String emoji,
    required int colorValue,
  }) => Notebook(
    id: id,

    title: title,
    emoji: emoji,
    colorValue: colorValue,

    localVersion: localVersion,
    lastSyncedVersion: lastSyncedVersion,
    syncStatus: syncStatus,

    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}
