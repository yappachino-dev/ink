import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ink/app/database/daos/key_slots_dao.dart';
import 'package:ink/app/database/daos/notes_dao.dart';
import 'package:ink/app/database/daos/projects_dao.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/services/sync/sync_indexes.dart';
import 'package:ink/features/notes/data/tables/note_conflicts.dart';
import 'package:ink/features/notes/data/tables/notes.dart';
import 'package:ink/features/notes/data/tables/project_conflicts.dart';
import 'package:ink/features/notes/data/tables/projects.dart';
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
  tables: [KeySlots, Notes, NoteConflicts, Projects, ProjectConflicts],
  daos: [KeySlotsDao, NotesDao, ProjectsDao],
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(projectConflicts);
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
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
