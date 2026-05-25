import 'package:flutter_test/flutter_test.dart';
import 'package:ink/features/notes/data/daos/projects_dao.dart';
import 'package:ink/features/notes/data/sources/projects_local_data_source.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/notes_fixtures.dart';
import '../../../../helpers/test_helpers.dart';

class MockProjectsDao extends Mock implements ProjectsDao {}

void main() {
  setUpAll(registerTestFallbacks);

  late MockProjectsDao mockDao;
  late ProjectsLocalDataSource dataSource;

  setUp(() {
    mockDao = MockProjectsDao();
    dataSource = ProjectsLocalDataSource(projectsDao: mockDao);
  });

  group('ProjectsLocalDataSource', () {
    test('create delegates to ProjectsDao.insertProject', () async {
      when(
        () => mockDao.insertProject(any()),
      ).thenAnswer((_) async => NotesFixtures.buildProjectModel());

      final companion = NotesFixtures.buildProjectCompanion();
      await dataSource.create(companion);

      verify(() => mockDao.insertProject(companion)).called(1);
    });

    test('getPending delegates to ProjectsDao.getPending', () async {
      when(() => mockDao.getPending()).thenAnswer((_) async => []);

      await dataSource.getPending();

      verify(() => mockDao.getPending()).called(1);
    });

    test('delete delegates to ProjectsDao.deleteProject', () async {
      when(() => mockDao.deleteProject(any())).thenAnswer((_) async {});

      await dataSource.delete('del_id');

      verify(() => mockDao.deleteProject('del_id')).called(1);
    });
  });
}
