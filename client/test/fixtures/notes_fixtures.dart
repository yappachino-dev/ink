import 'package:drift/drift.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/encrypted_project.dart';

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
    String? projectId,
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
      projectId: Value(projectId),
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
    String? projectId,
  }) {
    return NoteConflictsCompanion.insert(
      id: id ?? 'note_1',
      encryptedTitle: encryptedTitle ?? defaultBytes,
      encryptedContent: encryptedContent ?? defaultBytes,
      version: version ?? 2,
      createdAt: createdAt ?? defaultDate,
      updatedAt: updatedAt ?? defaultDate,
      deletedAt: Value(deletedAt),
      projectId: Value(projectId),
    );
  }

  static ProjectConflictsCompanion buildProjectConflictCompanion({
    String? id,
    Uint8List? encryptedContent,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ProjectConflictsCompanion.insert(
      id: id ?? 'project_1',
      encryptedContent: encryptedContent ?? defaultBytes,
      version: version ?? 2,
      createdAt: createdAt ?? defaultDate,
      updatedAt: updatedAt ?? defaultDate,
      deletedAt: Value(deletedAt),
    );
  }

  static ProjectsCompanion buildProjectCompanion({
    String? id,
    Uint8List? encryptedContent,
    int? localVersion,
    int? lastSyncedVersion,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ProjectsCompanion.insert(
      id: id != null ? Value(id) : const Value('project_1'),
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
  }) {
    return NoteModel(
      id: id ?? 'note_1',
      encryptedTitle: defaultBytes,
      encryptedContent: defaultBytes,
      localVersion: localVersion ?? 1,
      lastSyncedVersion: lastSyncedVersion ?? 0,
      syncStatus: syncStatus ?? SyncStatus.synced,
      createdAt: defaultDate,
      updatedAt: defaultDate,
    );
  }

  static ProjectModel buildProjectModel({
    String? id,
    int? localVersion,
    int? lastSyncedVersion,
    SyncStatus? syncStatus,
  }) {
    return ProjectModel(
      id: id ?? 'project_1',
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

  static EncryptedProject buildEncryptedProject({
    String? id,
    int? version,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return EncryptedProject(
      id: id ?? 'project_1',
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

  static SyncAck buildAck({
    String? id,
    int? version,
    bool? isDeleted,
  }) {
    return (
      id: id ?? 'note_1',
      version: version ?? 1,
      isDeleted: isDeleted ?? false,
    );
  }
}
