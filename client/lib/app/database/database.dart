import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ink/app/database/daos/key_slots_dao.dart';
import 'package:ink/app/database/daos/notebooks_dao.dart';
import 'package:ink/app/database/daos/notes_dao.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/services/sync/sync_indexes.dart';
import 'package:ink/features/notes/data/tables/note_conflicts.dart';
import 'package:ink/features/notes/data/tables/notebook_conflicts.dart';
import 'package:ink/features/notes/data/tables/notebooks.dart';
import 'package:ink/features/notes/data/tables/notes.dart';
import 'package:ink/features/vault/data/tables/key_slots.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/v7.dart';

part 'database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [KeySlots, Notes, NoteConflicts, Notebooks, NotebookConflicts],
  daos: [KeySlotsDao, NotesDao, NotebooksDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  Future<void> resetDatabase() async {
    await transaction(() async {
      await customStatement('PRAGMA foreign_keys = OFF');

      for (final table in allTables) {
        await delete(table).go();
      }

      await customStatement('PRAGMA foreign_keys = ON');
    });
  }

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(notebookConflicts);
        }
        if (from < 3) {
          // Locally derived plaintext mirrors of data inside the encrypted
          // payload. Existing rows get the default (empty, version 0) and are
          // repaired once, after unlock, by NoteMetadataBackfill: this layer
          // has no key and must not be handed one just to fill a cache.
          await m.addColumn(notes, notes.titlePreview);
          await m.addColumn(notes, notes.bodyPreview);
          await m.addColumn(notes, notes.hasUncompletedTasks);
          await m.addColumn(notes, notes.dueDateDay);
          await m.addColumn(notes, notes.metadataVersion);
          // The index arrives with the column it covers: the table predates
          // both, so creating the index alone would not compile.
          await m.createIndex(notesMetadataVersion);
        }
        if (from < 4) {
          // A rename, not a shape change: `projects` -> `notebooks` and
          // `notes.project_id` -> `notes.notebook_id`.
          //
          // These are plain `ALTER TABLE ... RENAME` statements, so the rows
          // survive and the foreign key keeps pointing at the right table.
          //
          // Two wrong approaches came first, both worth recording. Dropping and
          // recreating loses the notes, and Drift's schema verifier rejects
          // `dropColumn` outright. `TableMigration` is not a rename either: it
          // creates the *new* table and copies columns of the same name out of
          // a table assumed to already exist under that new name, so it builds
          // an empty `notebooks` and then fails looking for a `project_id` that
          // the preceding step had not moved.
          //
          // The table goes first: both foreign keys are renamed onto the new
          // name afterwards, and the schema verifier checks each step against
          // the final shape, so pointing a column at a table that does not
          // exist yet fails the migration.
          await m.renameTable(notebooks, 'projects');
          await m.renameColumn(notes, 'project_id', notes.notebookId);
          // The second of the two foreign keys to `projects`. Easy to miss -
          // the verifier caught it, which is the only reason it is here.
          await m.renameColumn(
            noteConflicts,
            'project_id',
            noteConflicts.notebookId,
          );

          // `project_conflicts` did not exist at v1; the `from < 2` step above
          // creates it, and it creates it under its *current* name. So the
          // rename only applies to databases that already had the old table,
          // and running it unconditionally fails from v1 with "no such table".
          if (from >= 2) {
            await m.renameTable(notebookConflicts, 'project_conflicts');
          }
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
