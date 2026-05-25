import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/core/services/sync/sync_status.dart';
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

    test('updateWithConflict saves both the note and the conflict', () async {
      final note = NotesFixtures.buildNoteCompanion(id: 'conflict_test');
      await dao.insertNote(note);

      final updatedNote = NotesFixtures.buildNoteCompanion(
        id: 'conflict_test',
        localVersion: 3,
      );
      final conflict = NotesFixtures.buildConflictCompanion(
        id: 'conflict_test',
        version: 2,
      );

      await dao.updateWithConflict(updatedNote, conflict);

      final savedNote = await dao.getNote('conflict_test');
      expect(savedNote!.localVersion, equals(3));

      final savedConflict = await (db.select(
        db.noteConflicts,
      )..where((tbl) => tbl.id.equals('conflict_test'))).getSingleOrNull();

      expect(savedConflict, isNotNull);
      expect(savedConflict!.version, equals(2));
    });

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
