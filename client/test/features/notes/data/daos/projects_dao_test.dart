import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/features/notes/data/daos/projects_dao.dart';

import '../../../../fixtures/notes_fixtures.dart';

void main() {
  late AppDatabase db;
  late ProjectsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.projectsDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('ProjectsDao', () {
    test('insertProject and getProject work correctly', () async {
      final project = NotesFixtures.buildProjectCompanion(id: 'proj_1');
      await dao.insertProject(project);

      final result = await dao.getProject('proj_1');
      expect(result, isNotNull);
      expect(result!.id, equals('proj_1'));
    });

    test('getPending returns correctly filtered projects', () async {
      final syncedProj = NotesFixtures.buildProjectCompanion(
        id: 'p_sync',
        syncStatus: SyncStatus.synced,
      );
      final modProj = NotesFixtures.buildProjectCompanion(
        id: 'p_mod',
        syncStatus: SyncStatus.modified,
      );

      await dao.insertProject(syncedProj);
      await dao.insertProject(modProj);

      final pending = await dao.getPending();
      expect(pending.length, equals(1));
      expect(pending.first.id, equals('p_mod'));
    });

    test(
      'deleteProject tombstones the row so the deletion can be pushed',
      () async {
        await dao.insertProject(
          NotesFixtures.buildProjectCompanion(
            id: 'p_tomb',
            syncStatus: SyncStatus.synced,
          ),
        );

        await dao.deleteProject('p_tomb');

        final row = await dao.getProject('p_tomb');
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
        final project = NotesFixtures.buildProjectCompanion(
          id: 'proj_1',
          localVersion: 3,
          syncStatus: SyncStatus.modified,
        );
        await dao.insertProject(project);

        await dao.acknowledgePushed([
          NotesFixtures.buildAck(id: 'proj_1', version: 3, isDeleted: false),
        ]);

        final result = await dao.getProject('proj_1');
        expect(result!.syncStatus, equals(SyncStatus.synced));
        expect(result.lastSyncedVersion, equals(3));
      },
    );

    test('getByIds returns only requested rows', () async {
      await dao.insertProject(NotesFixtures.buildProjectCompanion(id: 'a'));
      await dao.insertProject(NotesFixtures.buildProjectCompanion(id: 'b'));

      final rows = await dao.getByIds(['b']);

      expect(rows.map((e) => e.id), ['b']);
    });

    test(
      'applyRemoteDeltas upserts, conflicts and deletes atomically',
      () async {
        await dao.insertProject(
          NotesFixtures.buildProjectCompanion(
            id: 'conf_1',
            localVersion: 2,
            lastSyncedVersion: 1,
            syncStatus: SyncStatus.modified,
          ),
        );
        await dao.insertProject(
          NotesFixtures.buildProjectCompanion(id: 'del_1'),
        );

        await dao.applyRemoteDeltas(
          upserts: [NotesFixtures.buildProjectCompanion(id: 'new_1')],
          deletes: ['del_1'],
          conflicts: [
            (
              NotesFixtures.buildProjectCompanion(
                id: 'conf_1',
                localVersion: 2,
                lastSyncedVersion: 1,
                syncStatus: SyncStatus.conflicted,
              ),
              NotesFixtures.buildProjectConflictCompanion(
                id: 'conf_1',
                version: 4,
              ),
            ),
          ],
        );

        expect(await dao.getProject('del_1'), isNull);
        expect(await dao.getProject('new_1'), isNotNull);

        final conflicted = (await dao.getProject('conf_1'))!;
        expect(conflicted.syncStatus, equals(SyncStatus.conflicted));
        final conflictRow = await (db.select(
          db.projectConflicts,
        )..where((tbl) => tbl.id.equals('conf_1'))).getSingleOrNull();
        expect(conflictRow, isNotNull);
        expect(conflictRow!.version, equals(4));
      },
    );
  });
}
