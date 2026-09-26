import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/app/database/database.dart';

import 'schema.dart' as helper;
import 'schema_v1.dart' as v1;
import 'schema_v2.dart' as v2;
import 'schema_v3.dart' as v3;

// Schema files under migrations/ are regenerated whenever the database schema
// changes:
//   dart run drift_dev schema dump lib/app/database/database.dart drift_schemas/
//   dart run drift_dev schema generate drift_schemas/ test/migrations/
//
// See development.md for the full checklist when bumping schemaVersion.
void main() {
  final verifier = SchemaVerifier(helper.GeneratedHelper());

  // The real MigrationStrategy always migrates to the current version, so an
  // upgrade from an old schema is validated against the newest one.
  test('v1 -> current migrates cleanly and preserves existing rows', () async {
    final schema = await verifier.schemaAt(1);
    final bytes = Uint8List.fromList([1, 2, 3]);

    // Seed a note while still on schema v1.
    final oldDb = v1.DatabaseAtV1(schema.newConnection());
    await oldDb.customInsert(
      'INSERT INTO notes (id, encrypted_title, encrypted_content) '
      "VALUES ('note_1', ?, ?)",
      variables: [Variable.withBlob(bytes), Variable.withBlob(bytes)],
    );
    // A seeded project is needed later to satisfy the project_conflicts FK.
    await oldDb.customInsert(
      "INSERT INTO projects (id, encrypted_content) VALUES ('project_1', ?)",
      variables: [Variable.withBlob(bytes)],
    );
    await oldDb.close();

    // Migrate using the real AppDatabase migration strategy.
    final db = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);

    // project_conflicts exists and accepts rows.
    await db
        .into(db.projectConflicts)
        .insert(
          ProjectConflictsCompanion.insert(
            id: 'project_1',
            encryptedContent: bytes,
            version: 5,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );
    await db.close();

    // Pre-existing data survived the upgrade.
    final checkDb = v3.DatabaseAtV3(schema.newConnection());
    final rows = await checkDb
        .customSelect(
          "SELECT encrypted_content FROM notes WHERE id = 'note_1'",
        )
        .get();
    expect(rows, hasLength(1));
    expect(rows.single.data['encrypted_content'], equals(bytes));
    await checkDb.close();
  });

  test('v2 -> v3 adds derived columns and preserves existing rows', () async {
    final schema = await verifier.schemaAt(2);
    final bytes = Uint8List.fromList([9, 8, 7]);

    // Seed a note while still on schema v2, i.e. before any derived column
    // exists. This is the case the backfill has to find later.
    final oldDb = v2.DatabaseAtV2(schema.newConnection());
    await oldDb.customInsert(
      'INSERT INTO notes (id, encrypted_title, encrypted_content) '
      "VALUES ('note_1', ?, ?)",
      variables: [Variable.withBlob(bytes), Variable.withBlob(bytes)],
    );
    await oldDb.close();

    final db = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    await db.close();

    final checkDb = v3.DatabaseAtV3(schema.newConnection());

    // The pre-existing row and its ciphertext survived untouched.
    final rows = await checkDb
        .customSelect(
          'SELECT encrypted_content, title_preview, body_preview, '
          'has_uncompleted_tasks, due_date_day, metadata_version '
          "FROM notes WHERE id = 'note_1'",
        )
        .get();
    expect(rows, hasLength(1));
    expect(rows.single.data['encrypted_content'], equals(bytes));

    // The derived columns exist, and default to empty rather than NULL, so a
    // query against them never has to guard for null.
    expect(rows.single.data['title_preview'], equals(''));
    expect(rows.single.data['body_preview'], equals(''));
    expect(rows.single.data['has_uncompleted_tasks'], equals(0));
    expect(rows.single.data['due_date_day'], equals(null));

    // version 0 marks the row as not-yet-derived, which is how the backfill
    // finds it. A fresh install writes the current version directly.
    expect(rows.single.data['metadata_version'], equals(0));

    // The index arrives with the column. `migrateAndValidate` would already
    // fail without it, since the dumped schema carries the index too; asserted
    // here so the intent is visible rather than implied.
    final indexes = await checkDb
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name = 'notes_metadata_version'",
        )
        .get();
    expect(indexes, hasLength(1));

    await checkDb.close();
  });
}
