import 'package:ink/app/database/database.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/data/daos/projects_dao.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'projects_local_data_source.g.dart';

class ProjectsLocalDataSource {
  ProjectsLocalDataSource({required ProjectsDao projectsDao})
    : _projectsDao = projectsDao;

  final ProjectsDao _projectsDao;

  Future<ProjectModel> create(ProjectsCompanion note) =>
      _projectsDao.insertProject(note);

  Future<void> save(ProjectsCompanion note) => _projectsDao.updateProject(note);

  Future<void> acknowledgePushed(
    List<SyncAck> acknowledgements,
  ) => _projectsDao.acknowledgePushed(acknowledgements);

  Future<ProjectModel?> get(String id) => _projectsDao.getProject(id);

  Future<List<ProjectModel>> getAll() => _projectsDao.getAll();

  Future<List<ProjectModel>> getByIds(List<String> ids) =>
      _projectsDao.getByIds(ids);

  Future<void> applyRemoteDeltas({
    List<ProjectsCompanion> upserts = const [],
    List<String> deletes = const [],
    List<(ProjectsCompanion project, ProjectConflictsCompanion conflict)>
        conflicts =
        const [],
  }) => _projectsDao.applyRemoteDeltas(
    upserts: upserts,
    deletes: deletes,
    conflicts: conflicts,
  );

  Future<List<ProjectModel>> getPending() => _projectsDao.getPending();

  Future<void> delete(String id) => _projectsDao.deleteProject(id);
}

@riverpod
ProjectsLocalDataSource projectsLocalDataSource(Ref ref) => throw StateError(
  'projectsLocalDataSourceProvider must be overridden at the app root',
);
