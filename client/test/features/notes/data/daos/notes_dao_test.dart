import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/features/notes/data/daos/notes_dao.dart';

import '../../../../fixtures/notes_fixtures.dart';

void main() {
  late AppDatabase db;
  late NotesDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.notesDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('NotesDao', () {
    test('insertNote and getNote work correctly', () async {
      final note = NotesFixtures.buildNoteCompanion(id: 'test_1');
      await dao.insertNote(note);

      final result = await dao.getNote('test_1');
      expect(result, isNotNull);
      expect(result!.id, equals('test_1'));
    });

    test('getPending returns only modified or deleted notes', () async {
      final syncedNote = NotesFixtures.buildNoteCompanion(
        id: 'synced_1',
        syncStatus: SyncStatus.synced,
      );
      final modifiedNote = NotesFixtures.buildNoteCompanion(
        id: 'mod_1',
        syncStatus: SyncStatus.modified,
      );
      final deletedNote = NotesFixtures.buildNoteCompanion(
        id: 'del_1',
        syncStatus: SyncStatus.deleted,
      );

      await dao.insertNote(syncedNote);
      await dao.insertNote(modifiedNote);
      await dao.insertNote(deletedNote);

      final pending = await dao.getPending();

      expect(pending.length, equals(2));
      final pendingIds = pending.map((e) => e.id).toList();
      expect(pendingIds, containsAll(['mod_1', 'del_1']));
      expect(pendingIds, isNot(contains('synced_1')));
    });

    test(
      'deleteNote tombstones the row so the deletion can be pushed',
      () async {
        await dao.insertNote(
          NotesFixtures.buildNoteCompanion(
            id: 'tomb_1',
            syncStatus: SyncStatus.synced,
          ),
        );

        await dao.deleteNote('tomb_1');

        final row = await dao.getNote('tomb_1');
        expect(row, isNotNull);
        expect(row!.syncStatus, equals(SyncStatus.deleted));
        expect(row.deletedAt, isNotNull);

        // The tombstone must still be queued for push...
        final pending = await dao.getPending();
        expect(pending.map((e) => e.id), contains('tomb_1'));
        // ...but hidden from reads that back the UI.
        expect(
          (await dao.getAllNotes()).map((e) => e.id),
          isNot(contains('tomb_1')),
        );
      },
    );

    test('getByIds keeps tombstones for conflict detection', () async {
      await dao.insertNote(
        NotesFixtures.buildNoteCompanion(
          id: 'tomb_2',
          syncStatus: SyncStatus.synced,
        ),
      );
      await dao.deleteNote('tomb_2');

      final rows = await dao.getByIds(['tomb_2']);
      expect(rows, hasLength(1));
      expect(rows.single.syncStatus, equals(SyncStatus.deleted));
    });

    test('getByIds returns only requested rows', () async {
      await dao.insertNote(NotesFixtures.buildNoteCompanion(id: 'a'));
      await dao.insertNote(NotesFixtures.buildNoteCompanion(id: 'b'));
      await dao.insertNote(NotesFixtures.buildNoteCompanion(id: 'c'));

      final rows = await dao.getByIds(['a', 'c']);

      expect(rows.map((e) => e.id), unorderedEquals(['a', 'c']));
    });

    test(
      'applyRemoteDeltas upserts, conflicts and deletes atomically',
      () async {
        await dao.insertNote(NotesFixtures.buildNoteCompanion(id: 'over_1'));
        await dao.insertNote(
          NotesFixtures.buildNoteCompanion(
            id: 'conf_1',
            localVersion: 2,
            lastSyncedVersion: 1,
            syncStatus: SyncStatus.modified,
          ),
        );
        await dao.insertNote(NotesFixtures.buildNoteCompanion(id: 'del_1'));

        await dao.applyRemoteDeltas(
          upserts: [
            NotesFixtures.buildNoteCompanion(id: 'new_1'),
            NotesFixtures.buildNoteCompanion(id: 'over_1', localVersion: 5),
          ],
          deletes: ['del_1'],
          conflicts: [
            (
              NotesFixtures.buildNoteCompanion(
                id: 'conf_1',
                localVersion: 2,
                lastSyncedVersion: 1,
                syncStatus: SyncStatus.conflicted,
              ),
              NotesFixtures.buildConflictCompanion(id: 'conf_1', version: 3),
            ),
          ],
        );

        expect(await dao.getNote('del_1'), isNull);
        expect(await dao.getNote('new_1'), isNotNull);
        expect((await dao.getNote('over_1'))!.localVersion, equals(5));

        final conflicted = (await dao.getNote('conf_1'))!;
        expect(conflicted.syncStatus, equals(SyncStatus.conflicted));
        final conflictRow = await (db.select(
          db.noteConflicts,
        )..where((tbl) => tbl.id.equals('conf_1'))).getSingleOrNull();
        expect(conflictRow, isNotNull);
        expect(conflictRow!.version, equals(3));
      },
    );

    test('acknowledgePushed updates sync status or deletes notes', () async {
      final noteToUpdate = NotesFixtures.buildNoteCompanion(
        id: 'upd_1',
        localVersion: 2,
        syncStatus: SyncStatus.modified,
      );
      final noteToDelete = NotesFixtures.buildNoteCompanion(
        id: 'del_1',
        localVersion: 1,
        syncStatus: SyncStatus.deleted,
      );

      await dao.insertNote(noteToUpdate);
      await dao.insertNote(noteToDelete);

      final acks = [
        NotesFixtures.buildAck(id: 'upd_1', version: 2, isDeleted: false),
        NotesFixtures.buildAck(id: 'del_1', version: 1, isDeleted: true),
      ];

      await dao.acknowledgePushed(acks);

      final updated = await dao.getNote('upd_1');
      expect(updated!.syncStatus, equals(SyncStatus.synced));
      expect(updated.lastSyncedVersion, equals(2));

      final deleted = await dao.getNote('del_1');
      expect(deleted, isNull);
    });
  });
}
