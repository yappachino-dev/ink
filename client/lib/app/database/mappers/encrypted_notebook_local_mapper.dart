import 'package:drift/drift.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/features/notes/domain/entities/encrypted_notebook.dart';

extension NotebookModelToEncrypted on NotebookModel {
  EncryptedNotebook toDomain() => EncryptedNotebook(
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

extension EncryptedNotebookToCompanion on EncryptedNotebook {
  NotebooksCompanion toCompanion() => NotebooksCompanion.insert(
    id: Value(id),

    encryptedContent: encryptedContent,

    localVersion: Value(localVersion),
    lastSyncedVersion: Value(lastSyncedVersion),
    syncStatus: Value(syncStatus),

    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    deletedAt: Value(deletedAt),
  );

  NotebookConflictsCompanion toConflictCompanion() =>
      NotebookConflictsCompanion.insert(
        id: id,
        encryptedContent: encryptedContent,
        version: localVersion,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: Value(deletedAt),
      );
}
