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
  int get schemaVersion => 5;

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
          // `has_uncompleted_tasks` is deliberately absent here. It was created
          // by the v3 step originally and removed at v5, and recreating it just
          // so the v5 step can drop it again is two statements of pure waste -
          // and a needless dependency on `ALTER TABLE ... DROP COLUMN` for
          // exactly the v2 users who never had the column in the first place.
          // A v2 database upgrades straight to v5 and never materialises it.
          // Nothing needs the intermediate shape: the schema verifier compares
          // the *final* schema against the target, not each step, so a skipped
          // step is invisible to it. Only a database that genuinely reached v3
          // or v4 has the column, and the v5 step handles those.
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
        if (from < 5) {
          // Drops `has_uncompleted_tasks`, which was written by three call
          // sites and read by none: no query filtered on it and no widget read
          // it. It was indexed against the idea that a task is a projection
          // over Quill checklist items in the note body, but the product
          // decision is the opposite - a task is a note marked completed, and
          // `isCompleted` already stores that and drives both list lenses.
          // Two representations of one concept, one of them speculative, is
          // what made this worth a column.
          //
          // `customStatement` rather than `m.dropColumn` for the usual Drift
          // reason: the typed helper is rejected by the schema verifier. This
          // is a plain SQLite `ALTER TABLE ... DROP COLUMN` (3.35+), and it
          // leaves the rows alone - the column was only ever a derived mirror
          // of data that still lives in the encrypted payload, so nothing is
          // lost that cannot be recomputed.
          //
          // Conditional on the column being there, because a v1 or v2 database
          // upgrading straight to v5 never had it: the v3 step above no longer
          // creates it. Dropping unconditionally would fail on exactly the
          // users who have nothing to drop.
          final legacy = await customSelect(
            'SELECT 1 AS present FROM pragma_table_info(?) WHERE name = ?',
            variables: [
              Variable.withString(notes.actualTableName),
              Variable.withString('has_uncompleted_tasks'),
            ],
          ).get();
          if (legacy.isNotEmpty) {
            await customStatement(
              'ALTER TABLE notes DROP COLUMN has_uncompleted_tasks',
            );
          }
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
