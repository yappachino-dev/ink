import 'package:drift/drift.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/note_metadata.dart';

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

    notebookId: notebookId,

    // Rebuilt from the stored columns rather than re-derived: this is a read
    // path, and deriving here would mean decrypting on every list paint, which
    // is the cost these columns exist to remove.
    metadata: NoteMetadata(
      titlePreview: titlePreview,
      bodyPreview: bodyPreview,
      dueDateDay: dueDateDay,
      version: metadataVersion,
    ),
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

    notebookId: Value(notebookId),

    titlePreview: Value(metadata.titlePreview),
    bodyPreview: Value(metadata.bodyPreview),
    dueDateDay: Value(metadata.dueDateDay),
    metadataVersion: Value(metadata.version),
  );

  NoteConflictsCompanion toConflictCompanion() => NoteConflictsCompanion.insert(
    id: id,

    encryptedTitle: encryptedTitle,
    encryptedContent: encryptedContent,

    version: localVersion,

    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: Value(deletedAt),

    notebookId: Value(notebookId),
  );
}
