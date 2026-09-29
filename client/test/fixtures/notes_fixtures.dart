import 'package:drift/drift.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/encrypted_notebook.dart';
import 'package:ink/features/notes/domain/entities/note_metadata.dart';

class NotesFixtures {
  static Uint8List generateBytes(int length, int fill) =>
      Uint8List.fromList(List.filled(length, fill));

  static Uint8List defaultBytes = generateBytes(8, 1);
  static DateTime defaultDate = DateTime(2026);

  // --- Companion builders ---

  static NotesCompanion buildNoteCompanion({
    String? id,
    Uint8List? encryptedTitle,
    Uint8List? encryptedContent,
    int? localVersion,
    int? lastSyncedVersion,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? notebookId,
  }) {
    return NotesCompanion.insert(
      id: id != null ? Value(id) : const Value('note_1'),
      encryptedTitle: encryptedTitle ?? defaultBytes,
      encryptedContent: encryptedContent ?? defaultBytes,
      localVersion: localVersion != null ? Value(localVersion) : const Value(1),
      lastSyncedVersion: lastSyncedVersion != null
          ? Value(lastSyncedVersion)
          : const Value(0),
      syncStatus: syncStatus != null
          ? Value(syncStatus)
          : const Value(SyncStatus.modified),
      createdAt: createdAt != null ? Value(createdAt) : Value(defaultDate),
      updatedAt: updatedAt != null ? Value(updatedAt) : Value(defaultDate),
      deletedAt: Value(deletedAt),
      notebookId: Value(notebookId),
    );
  }

  static NoteConflictsCompanion buildConflictCompanion({
    String? id,
    Uint8List? encryptedTitle,
    Uint8List? encryptedContent,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? notebookId,
  }) {
    return NoteConflictsCompanion.insert(
      id: id ?? 'note_1',
      encryptedTitle: encryptedTitle ?? defaultBytes,
      encryptedContent: encryptedContent ?? defaultBytes,
      version: version ?? 2,
      createdAt: createdAt ?? defaultDate,
      updatedAt: updatedAt ?? defaultDate,
      deletedAt: Value(deletedAt),
      notebookId: Value(notebookId),
    );
  }

  static NotebookConflictsCompanion buildNotebookConflictCompanion({
    String? id,
    Uint8List? encryptedContent,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return NotebookConflictsCompanion.insert(
      id: id ?? 'notebook_1',
      encryptedContent: encryptedContent ?? defaultBytes,
      version: version ?? 2,
      createdAt: createdAt ?? defaultDate,
      updatedAt: updatedAt ?? defaultDate,
      deletedAt: Value(deletedAt),
    );
  }

  static NotebooksCompanion buildNotebookCompanion({
    String? id,
    Uint8List? encryptedContent,
    int? localVersion,
    int? lastSyncedVersion,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return NotebooksCompanion.insert(
      id: id != null ? Value(id) : const Value('notebook_1'),
      encryptedContent: encryptedContent ?? defaultBytes,
      localVersion: localVersion != null ? Value(localVersion) : const Value(1),
      lastSyncedVersion: lastSyncedVersion != null
          ? Value(lastSyncedVersion)
          : const Value(0),
      syncStatus: syncStatus != null
          ? Value(syncStatus)
          : const Value(SyncStatus.modified),
      createdAt: createdAt != null ? Value(createdAt) : Value(defaultDate),
      updatedAt: updatedAt != null ? Value(updatedAt) : Value(defaultDate),
      deletedAt: Value(deletedAt),
    );
  }

  // --- Model builders ---

  static NoteModel buildNoteModel({
    String? id,
    int? localVersion,
    int? lastSyncedVersion,
    SyncStatus? syncStatus,
    String? titlePreview,
    String? bodyPreview,
    DateTime? dueDateDay,
    int? metadataVersion,
  }) {
    return NoteModel(
      id: id ?? 'note_1',
      encryptedTitle: defaultBytes,
      encryptedContent: defaultBytes,
      titlePreview: titlePreview ?? '',
      bodyPreview: bodyPreview ?? '',
      dueDateDay: dueDateDay,
      metadataVersion: metadataVersion ?? noteMetadataVersion,
      localVersion: localVersion ?? 1,
      lastSyncedVersion: lastSyncedVersion ?? 0,
      syncStatus: syncStatus ?? SyncStatus.synced,
      createdAt: defaultDate,
      updatedAt: defaultDate,
    );
  }

  static NotebookModel buildNotebookModel({
    String? id,
    int? localVersion,
    int? lastSyncedVersion,
    SyncStatus? syncStatus,
  }) {
    return NotebookModel(
      id: id ?? 'notebook_1',
      encryptedContent: defaultBytes,
      localVersion: localVersion ?? 1,
      lastSyncedVersion: lastSyncedVersion ?? 0,
      syncStatus: syncStatus ?? SyncStatus.synced,
      createdAt: defaultDate,
      updatedAt: defaultDate,
    );
  }

  // --- Remote entity builders ---

  static EncryptedNote buildEncryptedNote({
    String? id,
    int? version,
    DateTime? deletedAt,
  }) {
    return EncryptedNote(
      id: id ?? 'note_1',
      encryptedTitle: defaultBytes,
      encryptedContent: defaultBytes,
      localVersion: version ?? 1,
      lastSyncedVersion: 0,
      syncStatus: SyncStatus.synced,
      createdAt: defaultDate,
      updatedAt: defaultDate,
      deletedAt: deletedAt,
    );
  }

  static EncryptedNotebook buildEncryptedNotebook({
    String? id,
    int? version,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return EncryptedNotebook(
      id: id ?? 'notebook_1',
      encryptedContent: defaultBytes,
      localVersion: version ?? 1,
      lastSyncedVersion: 0,
      syncStatus: SyncStatus.synced,
      createdAt: defaultDate,
      updatedAt: updatedAt ?? defaultDate,
      deletedAt: deletedAt,
    );
  }

  // --- Value object builders ---

  static SyncAck buildAck({String? id, int? version, bool? isDeleted}) {
    return (
      id: id ?? 'note_1',
      version: version ?? 1,
      isDeleted: isDeleted ?? false,
    );
  }
}
