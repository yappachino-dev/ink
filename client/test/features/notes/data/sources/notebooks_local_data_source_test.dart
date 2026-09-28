import 'package:flutter_test/flutter_test.dart';
import 'package:ink/app/database/adapters/notebooks_local_data_source.dart';
import 'package:ink/app/database/daos/notebooks_dao.dart';
import 'package:ink/app/database/database.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/notes_fixtures.dart';
import '../../../../helpers/test_helpers.dart';

class MockNotebooksDao extends Mock implements NotebooksDao {}

void main() {
  setUpAll(registerTestFallbacks);

  late MockNotebooksDao mockDao;
  late NotebooksLocalDataSource dataSource;

  setUp(() {
    mockDao = MockNotebooksDao();
    dataSource = NotebooksLocalDataSource(notebooksDao: mockDao);
  });

  group('NotebooksLocalDataSource', () {
    test('create delegates to NotebooksDao.insertNotebook', () async {
      when(
        () => mockDao.insertNotebook(any()),
      ).thenAnswer((_) async => NotesFixtures.buildNotebookModel());

      final companion = NotesFixtures.buildNotebookCompanion();
      await dataSource.create(companion);

      verify(() => mockDao.insertNotebook(companion)).called(1);
    });

    test(
      'applyRemoteDeltas delegates to NotebooksDao.applyRemoteDeltas',
      () async {
        when(() => mockDao.applyRemoteDeltas()).thenAnswer((_) async {});

        await dataSource.applyRemoteDeltas();

        verify(() => mockDao.applyRemoteDeltas()).called(1);
      },
    );

    test('getByIds delegates to NotebooksDao.getByIds', () async {
      when(
        () => mockDao.getByIds(any()),
      ).thenAnswer((_) async => <NotebookModel>[]);

      await dataSource.getByIds(['a', 'b']);

      verify(() => mockDao.getByIds(['a', 'b'])).called(1);
    });

    test('getPending delegates to NotebooksDao.getPending', () async {
      when(() => mockDao.getPending()).thenAnswer((_) async => []);

      await dataSource.getPending();

      verify(() => mockDao.getPending()).called(1);
    });

    test('delete delegates to NotebooksDao.deleteNotebook', () async {
      when(() => mockDao.deleteNotebook(any())).thenAnswer((_) async {});

      await dataSource.delete('del_id');

      verify(() => mockDao.deleteNotebook('del_id')).called(1);
    });
  });
}
