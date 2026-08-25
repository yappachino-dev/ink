import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/features/notes/data/sources/notes_local_data_source.dart';
import 'package:ink/features/notes/data/sources/projects_local_data_source.dart';
import 'package:ink/features/notes/data/unified_notes_repository.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';

import '../../../fixtures/notes_fixtures.dart';

void main() {
  late AppDatabase db;
  late UnifiedNotesRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = UnifiedNotesRepository(
      localNotes: NotesLocalDataSource(notesDao: db.notesDao),
      localProjects: ProjectsLocalDataSource(projectsDao: db.projectsDao),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<NoteModel?> noteById(String id) =>
      (db.select(db.notes)..where(($t) => $t.id.equals(id))).getSingleOrNull();

  Future<NoteConflictModel?> noteConflictById(String id) => (db.select(
    db.noteConflicts,
  )..where(($t) => $t.id.equals(id))).getSingleOrNull();

  Future<ProjectModel?> projectById(String id) => (db.select(
    db.projects,
  )..where(($t) => $t.id.equals(id))).getSingleOrNull();

  Future<ProjectConflictModel?> projectConflictById(String id) => (db.select(
    db.projectConflicts,
  )..where(($t) => $t.id.equals(id))).getSingleOrNull();

  /// Seeds a row and returns it as the sync engine would see it.
  Future<void> seedNote({
    required String id,
    int localVersion = 1,
    int lastSyncedVersion = 1,
    SyncStatus syncStatus = SyncStatus.synced,
  }) => db.notesDao.insertNote(
    NotesFixtures.buildNoteCompanion(
      id: id,
      localVersion: localVersion,
      lastSyncedVersion: lastSyncedVersion,
      syncStatus: syncStatus,
    ),
  );

  Future<void> seedProject({
    required String id,
    int localVersion = 1,
    int lastSyncedVersion = 1,
    SyncStatus syncStatus = SyncStatus.synced,
  }) => db.projectsDao.insertProject(
    NotesFixtures.buildProjectCompanion(
      id: id,
      localVersion: localVersion,
      lastSyncedVersion: lastSyncedVersion,
      syncStatus: syncStatus,
    ),
  );

  group('UnifiedNotesRepository - applyRemoteNotes', () {
    test('creates missing note locally', () async {
      final result = await repository.applyRemoteNotes([
        NotesFixtures.buildEncryptedNote(id: 'n_new', version: 3),
      ]);

      expect(result, isA<Success<void, NotesFailure>>());
      final row = await noteById('n_new');
      expect(row, isNotNull);
      expect(row!.localVersion, equals(3));
      expect(row.lastSyncedVersion, isZero);
      // Incoming deltas describe server-acknowledged state.
      expect(row.syncStatus, equals(SyncStatus.synced));
    });

    test('ignores tombstone for unknown id', () async {
      final result = await repository.applyRemoteNotes([
        NotesFixtures.buildEncryptedNote(
          id: 'n_ghost',
          version: 2,
          deletedAt: DateTime.now(),
        ),
      ]);

      expect(result, isA<Success<void, NotesFailure>>());
      expect(await noteById('n_ghost'), isNull);
      expect(await db.notesDao.getAllNotes(), isEmpty);
    });

    test('overwrites clean local row when server is newer', () async {
      await seedNote(
        id: 'n_clean',
      );

      await repository.applyRemoteNotes([
        NotesFixtures.buildEncryptedNote(
          id: 'n_clean',
          version: 4,
        ),
      ]);

      final row = (await noteById('n_clean'))!;
      expect(row.localVersion, equals(4));
      expect(row.syncStatus, equals(SyncStatus.synced));
    });

    test('skips stale live delta for clean local row', () async {
      await seedNote(id: 'n_stale', localVersion: 5, lastSyncedVersion: 5);

      await repository.applyRemoteNotes([
        NotesFixtures.buildEncryptedNote(id: 'n_stale', version: 3),
      ]);

      final row = (await noteById('n_stale'))!;
      expect(row.localVersion, equals(5));
      expect(row.syncStatus, equals(SyncStatus.synced));
    });

    test('conflict keeps local edits and stores server copy', () async {
      await seedNote(
        id: 'n_conflict',
        localVersion: 2,
        syncStatus: SyncStatus.modified,
      );

      await repository.applyRemoteNotes([
        NotesFixtures.buildEncryptedNote(id: 'n_conflict', version: 3),
      ]);

      final row = (await noteById('n_conflict'))!;
      expect(row.syncStatus, equals(SyncStatus.conflicted));
      expect(row.localVersion, equals(2));

      final conflictRow = (await noteConflictById('n_conflict'))!;
      expect(conflictRow.version, equals(3));
    });

    test('conflict when server deletes a locally modified row', () async {
      await seedNote(
        id: 'n_del_conflict',
        localVersion: 2,
        syncStatus: SyncStatus.modified,
      );

      await repository.applyRemoteNotes([
        NotesFixtures.buildEncryptedNote(
          id: 'n_del_conflict',
          version: 2,
          deletedAt: DateTime.now(),
        ),
      ]);

      final row = (await noteById('n_del_conflict'))!;
      expect(row.syncStatus, equals(SyncStatus.conflicted));

      final conflictRow = (await noteConflictById('n_del_conflict'))!;
      expect(conflictRow.deletedAt, isNotNull);
    });

    test('deletes clean local row when server deleted it', () async {
      await seedNote(
        id: 'n_deleted',
      );

      await repository.applyRemoteNotes([
        NotesFixtures.buildEncryptedNote(
          id: 'n_deleted',
          version: 2,
          deletedAt: DateTime.now(),
        ),
      ]);

      expect(await noteById('n_deleted'), isNull);
    });

    test('applies a mixed batch of deltas atomically', () async {
      await seedNote(id: 'n_keep', localVersion: 2);
      await seedNote(
        id: 'n_drop',
      );
      await seedNote(
        id: 'n_over',
      );
      await seedNote(id: 'n_skip', localVersion: 9, lastSyncedVersion: 9);

      final result = await repository.applyRemoteNotes([
        NotesFixtures.buildEncryptedNote(id: 'n_add', version: 1),
        NotesFixtures.buildEncryptedNote(id: 'n_over', version: 2),
        NotesFixtures.buildEncryptedNote(
          id: 'n_drop',
          version: 2,
          deletedAt: DateTime.now(),
        ),
        NotesFixtures.buildEncryptedNote(id: 'n_keep', version: 3),
        NotesFixtures.buildEncryptedNote(id: 'n_skip', version: 5),
      ]);

      expect(result, isA<Success<void, NotesFailure>>());

      final ids = (await db.notesDao.getAllNotes()).map((e) => e.id);
      expect(ids, containsAll(['n_add', 'n_over', 'n_keep', 'n_skip']));
      expect(ids, isNot(contains('n_drop')));

      final conflicted = (await noteById('n_keep'))!;
      expect(conflicted.syncStatus, equals(SyncStatus.conflicted));

      final overwritten = (await noteById('n_over'))!;
      expect(overwritten.localVersion, equals(2));
      expect(overwritten.syncStatus, equals(SyncStatus.synced));

      final skipped = (await noteById('n_skip'))!;
      expect(skipped.localVersion, equals(9));
    });
  });

  group('UnifiedNotesRepository - applyRemoteProjects', () {
    test('creates missing project locally', () async {
      final result = await repository.applyRemoteProjects([
        NotesFixtures.buildEncryptedProject(id: 'p_new', version: 2),
      ]);

      expect(result, isA<Success<void, NotesFailure>>());
      final row = await projectById('p_new');
      expect(row, isNotNull);
      expect(row!.localVersion, equals(2));
    });

    test('ignores tombstone for unknown id', () async {
      await repository.applyRemoteProjects([
        NotesFixtures.buildEncryptedProject(
          id: 'p_ghost',
          version: 1,
          deletedAt: DateTime.now(),
        ),
      ]);

      expect(await projectById('p_ghost'), isNull);
    });

    test('overwrites clean local row when server is newer', () async {
      await seedProject(
        id: 'p_clean',
      );

      await repository.applyRemoteProjects([
        NotesFixtures.buildEncryptedProject(id: 'p_clean', version: 6),
      ]);

      final row = (await projectById('p_clean'))!;
      expect(row.localVersion, equals(6));
      expect(row.syncStatus, equals(SyncStatus.synced));
    });

    test(
      'does not drop unsynced local changes on newer server delta '
      '(old LWW behavior silently overwrote them)',
      () async {
        await seedProject(
          id: 'p_dirty',
          localVersion: 3,
          syncStatus: SyncStatus.modified,
        );

        await repository.applyRemoteProjects([
          NotesFixtures.buildEncryptedProject(id: 'p_dirty', version: 5),
        ]);

        final row = (await projectById('p_dirty'))!;
        expect(row.syncStatus, equals(SyncStatus.conflicted));
        expect(row.localVersion, equals(3));

        final conflictRow = (await projectConflictById('p_dirty'))!;
        expect(conflictRow.version, equals(5));
      },
    );

    test('skips stale live delta', () async {
      await seedProject(id: 'p_stale', localVersion: 4, lastSyncedVersion: 4);

      await repository.applyRemoteProjects([
        NotesFixtures.buildEncryptedProject(id: 'p_stale', version: 2),
      ]);

      final row = (await projectById('p_stale'))!;
      expect(row.localVersion, equals(4));
    });

    test('deletes clean local row when server deleted it', () async {
      await seedProject(
        id: 'p_gone',
      );

      await repository.applyRemoteProjects([
        NotesFixtures.buildEncryptedProject(
          id: 'p_gone',
          version: 2,
          deletedAt: DateTime.now(),
        ),
      ]);

      expect(await projectById('p_gone'), isNull);
    });

    test('applies mixed batch atomically', () async {
      await seedProject(id: 'p_keep', localVersion: 2);
      await seedProject(
        id: 'p_drop',
      );

      await repository.applyRemoteProjects([
        NotesFixtures.buildEncryptedProject(id: 'p_add', version: 1),
        NotesFixtures.buildEncryptedProject(
          id: 'p_drop',
          version: 2,
          deletedAt: DateTime.now(),
        ),
        NotesFixtures.buildEncryptedProject(id: 'p_keep', version: 4),
      ]);

      final ids = (await db.projectsDao.getAll()).map((e) => e.id);
      expect(ids, containsAll(['p_add', 'p_keep']));
      expect(ids, isNot(contains('p_drop')));

      expect(
        (await projectById('p_keep'))!.syncStatus,
        equals(SyncStatus.conflicted),
      );
    });
  });
}
