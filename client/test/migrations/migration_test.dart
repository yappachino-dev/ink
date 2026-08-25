import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/app/database/database.dart';

import 'schema.dart' as helper;
import 'schema_v1.dart' as v1;
import 'schema_v2.dart' as v2;

// Schema files under migrations/ are regenerated whenever the database schema
// changes:
//   dart run drift_dev schema dump lib/app/database/database.dart drift_schemas/
//   dart run drift_dev schema generate drift_schemas/ test/migrations/
//
// See development.md for the full checklist when bumping schemaVersion.
void main() {
  final verifier = SchemaVerifier(helper.GeneratedHelper());

  test('v1 -> v2 migrates cleanly and preserves existing rows', () async {
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
    await verifier.migrateAndValidate(db, 2);

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
    final checkDb = v2.DatabaseAtV2(schema.newConnection());
    final rows = await checkDb
        .customSelect(
          "SELECT encrypted_content FROM notes WHERE id = 'note_1'",
        )
        .get();
    expect(rows, hasLength(1));
    expect(rows.single.data['encrypted_content'], equals(bytes));
    await checkDb.close();
  });
}
