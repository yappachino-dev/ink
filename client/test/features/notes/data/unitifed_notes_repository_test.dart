import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/features/notes/data/sources/notes_local_data_source.dart';
import 'package:ink/features/notes/data/sources/projects_local_data_source.dart';
import 'package:ink/features/notes/data/unified_notes_repository.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/notes_fixtures.dart';
import '../../../helpers/test_helpers.dart';

class MockNotesLocalDataSource extends Mock implements NotesLocalDataSource {}

class MockProjectsLocalDataSource extends Mock
    implements ProjectsLocalDataSource {}

void main() {
  setUpAll(registerTestFallbacks);

  late MockNotesLocalDataSource mockNotesLocal;
  late MockProjectsLocalDataSource mockProjectsLocal;
  late UnifiedNotesRepository repository;

  setUp(() {
    mockNotesLocal = MockNotesLocalDataSource();
    mockProjectsLocal = MockProjectsLocalDataSource();
    repository = UnifiedNotesRepository(
      localNotes: mockNotesLocal,
      localProjects: mockProjectsLocal,
    );
  });

  group('UnifiedNotesRepository - applyRemoteNotes (Sync Engine)', () {
    test('creates note locally if it does not exist', () async {
      when(() => mockNotesLocal.get(any())).thenAnswer((_) async => null);
      when(
        () => mockNotesLocal.create(any()),
      ).thenAnswer((_) async => NotesFixtures.buildNoteModel());

      final remoteDto = NotesFixtures.buildEncryptedNote(id: 'new_server_note');

      final result = await repository.applyRemoteNotes([remoteDto]);

      expect(result, isA<Success<void, NotesFailure>>());
      verify(() => mockNotesLocal.get('new_server_note')).called(1);
      verify(() => mockNotesLocal.create(any())).called(1);
    });

    test(
      'ignores remote note if it does not exist locally AND is marked deleted on server',
      () async {
        when(() => mockNotesLocal.get(any())).thenAnswer((_) async => null);

        final remoteDto = NotesFixtures.buildEncryptedNote(
          id: 'ghost_note',
          deletedAt: DateTime.now(),
        );

        final result = await repository.applyRemoteNotes([remoteDto]);

        expect(result, isA<Success<void, NotesFailure>>());
        verifyNever(() => mockNotesLocal.create(any()));
        verifyNever(() => mockNotesLocal.delete(any()));
      },
    );

    test(
      'saves with conflict if note modified locally AND on server',
      () async {
        final localModel = NotesFixtures.buildNoteModel(
          id: 'conflict_note',
          localVersion: 2,
          lastSyncedVersion: 1,
        );

        when(
          () => mockNotesLocal.get(any()),
        ).thenAnswer((_) async => localModel);
        when(
          () => mockNotesLocal.saveWithConflict(any(), any()),
        ).thenAnswer((_) async {});

        final remoteDto = NotesFixtures.buildEncryptedNote(
          id: 'conflict_note',
          version: 2,
        );

        await repository.applyRemoteNotes([remoteDto]);

        verify(() => mockNotesLocal.saveWithConflict(any(), any())).called(1);
        verifyNever(() => mockNotesLocal.save(any()));
      },
    );

    test(
      'saves with conflict if server deleted it, but local has unsynced changes',
      () async {
        final localModel = NotesFixtures.buildNoteModel(
          id: 'del_conflict',
          localVersion: 2,
          lastSyncedVersion: 1,
        );

        when(
          () => mockNotesLocal.get(any()),
        ).thenAnswer((_) async => localModel);
        when(
          () => mockNotesLocal.saveWithConflict(any(), any()),
        ).thenAnswer((_) async {});

        final remoteDto = NotesFixtures.buildEncryptedNote(
          id: 'del_conflict',
          version: 1,
          deletedAt: DateTime.now(),
        );

        await repository.applyRemoteNotes([remoteDto]);

        verify(() => mockNotesLocal.saveWithConflict(any(), any())).called(1);
        verifyNever(() => mockNotesLocal.delete(any()));
      },
    );

    test(
      'deletes locally if server deleted it and no local unsynced changes exist',
      () async {
        final localModel = NotesFixtures.buildNoteModel(
          id: 'clean_delete',
          localVersion: 1,
          lastSyncedVersion: 1,
        );

        when(
          () => mockNotesLocal.get(any()),
        ).thenAnswer((_) async => localModel);
        when(() => mockNotesLocal.delete(any())).thenAnswer((_) async {});

        final remoteDto = NotesFixtures.buildEncryptedNote(
          id: 'clean_delete',
          version: 2,
          deletedAt: DateTime.now(),
        );

        await repository.applyRemoteNotes([remoteDto]);

        verify(() => mockNotesLocal.delete('clean_delete')).called(1);
      },
    );

    test(
      'performs clean save if server has newer version and local has no unsynced changes',
      () async {
        final localModel = NotesFixtures.buildNoteModel(
          id: 'clean_update',
          localVersion: 1,
          lastSyncedVersion: 1,
        );

        when(
          () => mockNotesLocal.get(any()),
        ).thenAnswer((_) async => localModel);
        when(() => mockNotesLocal.save(any())).thenAnswer((_) async {});

        final remoteDto = NotesFixtures.buildEncryptedNote(
          id: 'clean_update',
          version: 2,
        );

        await repository.applyRemoteNotes([remoteDto]);

        verify(() => mockNotesLocal.save(any())).called(1);
        verifyNever(() => mockNotesLocal.saveWithConflict(any(), any()));
      },
    );
  });
}
