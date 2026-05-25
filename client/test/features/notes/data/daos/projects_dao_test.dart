import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/core/services/sync/sync_status.dart';
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

    test('deleteProject physically removes the project row', () async {
      final project = NotesFixtures.buildProjectCompanion(id: 'del_me');
      await dao.insertProject(project);

      await dao.deleteProject('del_me');

      final result = await dao.getProject('del_me');
      expect(result, isNull);
    });
  });
}
