import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/features/notes/data/daos/notes_dao.dart';
import 'package:ink/features/notes/data/daos/projects_dao.dart';
import 'package:ink/features/notes/data/tables/note_conflicts.dart';
import 'package:ink/features/notes/data/tables/notes.dart';
import 'package:ink/features/notes/data/tables/projects.dart';
import 'package:ink/features/vault/data/daos/key_slots_dao.dart';
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
  tables: [KeySlots, Notes, NoteConflicts, Projects],
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {},
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
