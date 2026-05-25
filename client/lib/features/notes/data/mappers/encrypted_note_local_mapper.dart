import 'package:drift/drift.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';

extension NoteModelToEncrypted on NoteModel {
  EncryptedNote toDomain() => EncryptedNote(
    id: id,

    encryptedTitle: encryptedTitle,
    encryptedContent: encryptedContent,

    localVersion: localVersion,
    lastSyncedVersion: lastSyncedVersion,
    syncStatus: syncStatus,

    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,

    projectId: projectId,
  );
}

extension EncryptedNoteToCompanion on EncryptedNote {
  NotesCompanion toCompanion() => NotesCompanion.insert(
    id: Value(id),

    encryptedTitle: encryptedTitle,
    encryptedContent: encryptedContent,

    localVersion: Value(localVersion),
    lastSyncedVersion: Value(lastSyncedVersion),
    syncStatus: Value(syncStatus),

    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    deletedAt: Value(deletedAt),

    projectId: Value(projectId),
  );

  NoteConflictsCompanion toConflictCompanion() => NoteConflictsCompanion.insert(
    id: id,

    encryptedTitle: encryptedTitle,
    encryptedContent: encryptedContent,

    version: localVersion,

    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: Value(deletedAt),

    projectId: Value(projectId),
  );
}
