import 'package:drift/drift.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/data/tables/note_conflicts.dart';
import 'package:ink/features/notes/data/tables/notes.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [Notes, NoteConflicts])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.attachedDatabase);

  Future<NoteModel> insertNote(NotesCompanion note) =>
      into(notes).insertReturning(note);

  Future<void> updateNote(NotesCompanion note) => update(notes).replace(note);

  Future<void> upsertNote(NotesCompanion note) =>
      into(notes).insert(note, mode: InsertMode.insertOrReplace);

  Future<void> upsertConflict(NoteConflictsCompanion conflict) =>
      into(noteConflicts).insert(conflict, mode: InsertMode.insertOrReplace);

  Future<void> updateWithConflict(
    NotesCompanion note,
    NoteConflictsCompanion conflict,
  ) => transaction(() async {
    await updateNote(note);
    await upsertConflict(conflict);
  });

  Future<void> acknowledgePushed(
    List<SyncAcknowledgement> acknowledgements,
  ) => batch((batch) {
    for (final ack in acknowledgements) {
      if (ack.isDeleted) {
        batch.deleteWhere(
          notes,
          (tbl) => tbl.id.equals(ack.id) & tbl.localVersion.equals(ack.version),
        );
      } else {
        batch.update(
          notes,
          NotesCompanion(
            syncStatus: const Value(SyncStatus.synced),
            lastSyncedVersion: Value(ack.version),
          ),
          where: (tbl) =>
              tbl.id.equals(ack.id) & tbl.localVersion.equals(ack.version),
        );
      }
    }
  });

  Future<NoteModel?> getNote(String id) =>
      (select(notes)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<List<NoteModel>> getAllNotes() => select(notes).get();

  Future<List<NoteModel>> getPending() =>
      (select(notes)..where(
            (tbl) => tbl.syncStatus.isIn([
              SyncStatus.modified.index,
              SyncStatus.deleted.index,
            ]),
          ))
          .get();

  Future<void> deleteNote(String id) =>
      (delete(notes)..where((tbl) => tbl.id.equals(id))).go();
}
