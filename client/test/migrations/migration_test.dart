import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/app/database/database.dart';

import 'schema.dart' as helper;
import 'schema_v1.dart' as v1;
import 'schema_v2.dart' as v2;
import 'schema_v3.dart' as v3;
import 'schema_v4.dart' as v4;
import 'schema_v5.dart' as v5;

// Schema files under migrations/ are regenerated whenever the database schema
// changes:
//   dart run drift_dev schema dump lib/app/database/database.dart \
//     drift_schemas/
//   dart run drift_dev schema generate drift_schemas/ test/migrations/
//
// See development.md for the full checklist when bumping schemaVersion.
void main() {
  final verifier = SchemaVerifier(helper.GeneratedHelper());
  // The app's own target, so a schema bump does not silently leave these tests
  // validating against a version the app has moved past.
  //
  // Bumping this by hand is a trap: the failure surfaces as a schema mismatch
  // naming a column rather than as "you forgot to bump the version", which is
  // close to unreadable. The test below pins it to the database instead.
  const currentVersion = 5;

  test('the migration target matches the database', () {
    // `schemaVersion` is an instance getter, so this needs a throwaway handle.
    // If this fails, `currentVersion` above is stale - do not "fix" the schema
    // mismatch, fix the constant.
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, currentVersion);
  });

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
    // The old table name, deliberately: this row is written while the database
    // is still on schema v1, where the table is `projects`. Everything in this
    // test that describes *historical* state keeps the old names - only the
    // current schema and the Dart API around it are renamed.
    await oldDb.customInsert(
      "INSERT INTO projects (id, encrypted_content) VALUES ('project_1', ?)",
      variables: [Variable.withBlob(bytes)],
    );
    await oldDb.close();

    // Migrate using the real AppDatabase migration strategy.
    final db = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(db, currentVersion);

    // notebook_conflicts exists and accepts rows.
    await db
        .into(db.notebookConflicts)
        .insert(
          NotebookConflictsCompanion.insert(
            id: 'project_1',
            encryptedContent: bytes,
            version: 5,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );
    await db.close();

    // Pre-existing data survived the upgrade.
    // Checked against the version we migrated to, not the one we came from: a
    // snapshot opened on a newer database is itself a schema mismatch, and
    // drift reports it as a missing upgrade strategy. Every post-migration
    // assertion here therefore has to move up whenever `currentVersion` does.
    final checkDb = v5.DatabaseAtV5(schema.newConnection());
    final rows = await checkDb
        .customSelect("SELECT encrypted_content FROM notes WHERE id = 'note_1'")
        .get();
    expect(rows, hasLength(1));
    expect(rows.single.data['encrypted_content'], equals(bytes));
    await checkDb.close();
  });

  test('v2 -> current adds derived columns and preserves rows', () async {
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
    await verifier.migrateAndValidate(db, currentVersion);
    await db.close();

    final checkDb = v5.DatabaseAtV5(schema.newConnection());

    // The pre-existing row and its ciphertext survived untouched.
    //
    // `has_uncompleted_tasks` is not in this list. It is deliberately absent:
    // the v3 step still creates it so a v2 database can pass through v3, and
    // the v5 step drops it, so selecting it here is what would catch a v5 step
    // that quietly stopped running.
    final rows = await checkDb
        .customSelect(
          'SELECT encrypted_content, title_preview, body_preview, '
          'due_date_day, metadata_version '
          "FROM notes WHERE id = 'note_1'",
        )
        .get();
    expect(rows, hasLength(1));
    expect(rows.single.data['encrypted_content'], equals(bytes));

    // The derived columns exist, and default to empty rather than NULL, so a
    // query against them never has to guard for null.
    expect(rows.single.data['title_preview'], equals(''));
    expect(rows.single.data['body_preview'], equals(''));
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

  test("v3 -> v4 renames the notebook table and the note's foreign key, and "
      'keeps the relationship intact', () async {
    final schema = await verifier.schemaAt(3);
    final notebookBytes = Uint8List.fromList([4, 5, 6]);
    final noteBytes = Uint8List.fromList([7, 8, 9]);

    // Seed a notebook and a note that points at it, in the v3 shape.
    final oldDb = v3.DatabaseAtV3(schema.newConnection());
    await oldDb.customInsert(
      "INSERT INTO projects (id, encrypted_content) VALUES ('nb_1', ?)",
      variables: [Variable.withBlob(notebookBytes)],
    );
    await oldDb.customInsert(
      'INSERT INTO notes (id, project_id, encrypted_title, encrypted_content) '
      "VALUES ('note_1', 'nb_1', ?, ?)",
      variables: [Variable.withBlob(noteBytes), Variable.withBlob(noteBytes)],
    );
    await oldDb.close();

    final db = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(db, currentVersion);
    await db.close();

    // Re-open against the *current* schema. The point of the test is that both
    // renames landed and the foreign key still resolves across them: a rename
    // that kept the tables but orphaned the link would pass a schema check and
    // quietly detach every note from its notebook.
    final checkDb = AppDatabase.forTesting(schema.newConnection());

    final notebooks = await checkDb
        .customSelect(
          'SELECT encrypted_content FROM notebooks WHERE id = ?',
          variables: [Variable.withString('nb_1')],
        )
        .get();
    expect(notebooks, hasLength(1));
    expect(notebooks.single.data['encrypted_content'], equals(notebookBytes));

    final notes = await checkDb
        .customSelect(
          'SELECT notebook_id, encrypted_content FROM notes WHERE id = ?',
          variables: [Variable.withString('note_1')],
        )
        .get();
    expect(notes, hasLength(1));
    expect(notes.single.data['encrypted_content'], equals(noteBytes));
    expect(
      notes.single.data['notebook_id'],
      'nb_1',
      reason: 'the renamed foreign key must still point at the renamed table',
    );

    // And the old names are gone, not merely unused. A rename that left the
    // old table behind would keep the rows reachable and still pass everything
    // above, so the absence is asserted rather than assumed.
    final oldNames = await checkDb
        .customSelect(
          'SELECT name FROM sqlite_master WHERE name IN '
          "('projects', 'project_conflicts')",
        )
        .get();
    expect(oldNames, isEmpty, reason: 'a renamed table was left behind');

    await checkDb.close();
  });

  test(
    'v4 -> v5 drops has_uncompleted_tasks and keeps the note intact',
    () async {
      final schema = await verifier.schemaAt(4);
      final titleBytes = Uint8List.fromList([1, 2, 3]);
      final bodyBytes = Uint8List.fromList([4, 5, 6]);

      // Seed in the v4 shape, with the column this migration removes carrying a
      // non-default value. If the drop were done by rebuilding the table and
      // forgetting to carry the encrypted columns over, the note would survive
      // with a null body and the assertions below would catch it.
      // Seeded at v4, not v5: the point is to start from the shape that still
      // has the column, so the drop has something to remove.
      final oldDb = v4.DatabaseAtV4(schema.newConnection());
      await oldDb.customInsert(
        'INSERT INTO notes (id, encrypted_title, encrypted_content, '
        'title_preview, metadata_version, has_uncompleted_tasks) '
        "VALUES (?, ?, ?, 'Kept preview', 1, 1)",
        variables: [
          Variable.withString('note_1'),
          Variable.withBlob(titleBytes),
          Variable.withBlob(bodyBytes),
        ],
      );
      await oldDb.close();

      final db = AppDatabase.forTesting(schema.newConnection());
      await verifier.migrateAndValidate(db, currentVersion);
      await db.close();

      final checkDb = v5.DatabaseAtV5(schema.newConnection());

      final columns = await checkDb.customSelect('SELECT * FROM notes').get();
      expect(
        columns.single.data.keys,
        isNot(contains('has_uncompleted_tasks')),
        reason: 'the column was removed, not merely left unused',
      );

      // The payload is the source of truth; the dropped column was only ever a
      // derived mirror of it. Losing the column is safe, losing this is not.
      final notes = await checkDb
          .customSelect(
            'SELECT encrypted_title, encrypted_content, title_preview '
            'FROM notes WHERE id = ?',
            variables: [Variable.withString('note_1')],
          )
          .get();
      expect(notes, hasLength(1));
      expect(notes.single.data['encrypted_title'], equals(titleBytes));
      expect(notes.single.data['encrypted_content'], equals(bodyBytes));

      // The sibling cache columns are untouched by the drop. Asserting one
      // specifically is what distinguishes "dropped one column" from "rebuilt
      // the table and lost the rest of the row".
      expect(notes.single.data['title_preview'], equals('Kept preview'));

      await checkDb.close();
    },
  );
}
