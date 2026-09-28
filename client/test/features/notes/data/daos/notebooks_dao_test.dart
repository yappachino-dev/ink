import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/app/database/daos/notebooks_dao.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/core/domain/sync_status.dart';

import '../../../../fixtures/notes_fixtures.dart';

void main() {
  late AppDatabase db;
  late NotebooksDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.notebooksDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('NotebooksDao', () {
    test('insertNotebook and getNotebook work correctly', () async {
      final notebook = NotesFixtures.buildNotebookCompanion(id: 'proj_1');
      await dao.insertNotebook(notebook);

      final result = await dao.getNotebook('proj_1');
      expect(result, isNotNull);
      expect(result!.id, equals('proj_1'));
    });

    test('getPending returns correctly filtered notebooks', () async {
      final syncedProj = NotesFixtures.buildNotebookCompanion(
        id: 'p_sync',
        syncStatus: SyncStatus.synced,
      );
      final modProj = NotesFixtures.buildNotebookCompanion(
        id: 'p_mod',
        syncStatus: SyncStatus.modified,
      );

      await dao.insertNotebook(syncedProj);
      await dao.insertNotebook(modProj);

      final pending = await dao.getPending();
      expect(pending.length, equals(1));
      expect(pending.first.id, equals('p_mod'));
    });

    test(
      'deleteNotebook tombstones the row so the deletion can be pushed',
      () async {
        await dao.insertNotebook(
          NotesFixtures.buildNotebookCompanion(
            id: 'p_tomb',
            syncStatus: SyncStatus.synced,
          ),
        );

        await dao.deleteNotebook('p_tomb');

        final row = await dao.getNotebook('p_tomb');
        expect(row, isNotNull);
        expect(row!.syncStatus, equals(SyncStatus.deleted));
        expect(row.deletedAt, isNotNull);

        // The tombstone must still be queued for push...
        final pending = await dao.getPending();
        expect(pending.map((e) => e.id), contains('p_tomb'));
        // ...but hidden from reads that back the UI.
        expect(
          (await dao.getAll()).map((e) => e.id),
          isNot(contains('p_tomb')),
        );
      },
    );

    test(
      'acknowledgePushed properly applies server acknowledgements',
      () async {
        final notebook = NotesFixtures.buildNotebookCompanion(
          id: 'proj_1',
          localVersion: 3,
          syncStatus: SyncStatus.modified,
        );
        await dao.insertNotebook(notebook);

        await dao.acknowledgePushed([
          NotesFixtures.buildAck(id: 'proj_1', version: 3, isDeleted: false),
        ]);

        final result = await dao.getNotebook('proj_1');
        expect(result!.syncStatus, equals(SyncStatus.synced));
        expect(result.lastSyncedVersion, equals(3));
      },
    );

    test('getByIds returns only requested rows', () async {
      await dao.insertNotebook(NotesFixtures.buildNotebookCompanion(id: 'a'));
      await dao.insertNotebook(NotesFixtures.buildNotebookCompanion(id: 'b'));

      final rows = await dao.getByIds(['b']);

      expect(rows.map((e) => e.id), ['b']);
    });

    test(
      'applyRemoteDeltas upserts, conflicts and deletes atomically',
      () async {
        await dao.insertNotebook(
          NotesFixtures.buildNotebookCompanion(
            id: 'conf_1',
            localVersion: 2,
            lastSyncedVersion: 1,
            syncStatus: SyncStatus.modified,
          ),
        );
        await dao.insertNotebook(
          NotesFixtures.buildNotebookCompanion(id: 'del_1'),
        );

        await dao.applyRemoteDeltas(
          upserts: [NotesFixtures.buildNotebookCompanion(id: 'new_1')],
          deletes: ['del_1'],
          conflicts: [
            (
              NotesFixtures.buildNotebookCompanion(
                id: 'conf_1',
                localVersion: 2,
                lastSyncedVersion: 1,
                syncStatus: SyncStatus.conflicted,
              ),
              NotesFixtures.buildNotebookConflictCompanion(
                id: 'conf_1',
                version: 4,
              ),
            ),
          ],
        );

        expect(await dao.getNotebook('del_1'), isNull);
        expect(await dao.getNotebook('new_1'), isNotNull);

        final conflicted = (await dao.getNotebook('conf_1'))!;
        expect(conflicted.syncStatus, equals(SyncStatus.conflicted));
        final conflictRow = await (db.select(
          db.notebookConflicts,
        )..where((tbl) => tbl.id.equals('conf_1'))).getSingleOrNull();
        expect(conflictRow, isNotNull);
        expect(conflictRow!.version, equals(4));
      },
    );
  });
}
