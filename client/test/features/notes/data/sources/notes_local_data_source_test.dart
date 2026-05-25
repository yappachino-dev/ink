import 'package:flutter_test/flutter_test.dart';
import 'package:ink/features/notes/data/daos/notes_dao.dart';
import 'package:ink/features/notes/data/sources/notes_local_data_source.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/notes_fixtures.dart';
import '../../../../helpers/test_helpers.dart';

class MockNotesDao extends Mock implements NotesDao {}

void main() {
  setUpAll(registerTestFallbacks);

  late MockNotesDao mockDao;
  late NotesLocalDataSource dataSource;

  setUp(() {
    mockDao = MockNotesDao();
    dataSource = NotesLocalDataSource(notesDao: mockDao);
  });

  group('NotesLocalDataSource', () {
    test('create delegates to NotesDao.insertNote', () async {
      when(
        () => mockDao.insertNote(any()),
      ).thenAnswer((_) async => NotesFixtures.buildNoteModel());

      final companion = NotesFixtures.buildNoteCompanion();
      await dataSource.create(companion);

      verify(() => mockDao.insertNote(companion)).called(1);
    });

    test('saveWithConflict delegates to NotesDao.updateWithConflict', () async {
      when(
        () => mockDao.updateWithConflict(any(), any()),
      ).thenAnswer((_) async {});

      final note = NotesFixtures.buildNoteCompanion();
      final conflict = NotesFixtures.buildConflictCompanion();

      await dataSource.saveWithConflict(note, conflict);

      verify(() => mockDao.updateWithConflict(note, conflict)).called(1);
    });

    test('acknowledgePushed delegates to NotesDao.acknowledgePushed', () async {
      when(() => mockDao.acknowledgePushed(any())).thenAnswer((_) async {});

      final acks = [NotesFixtures.buildAck()];
      await dataSource.acknowledgePushed(acks);

      verify(() => mockDao.acknowledgePushed(acks)).called(1);
    });

    test('get delegates to NotesDao.getNote', () async {
      when(() => mockDao.getNote(any())).thenAnswer((_) async => null);

      await dataSource.get('test_id');

      verify(() => mockDao.getNote('test_id')).called(1);
    });
  });
}
