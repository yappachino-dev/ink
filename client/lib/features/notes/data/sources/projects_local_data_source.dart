import 'package:ink/app/database/database.dart';
import 'package:ink/app/database/database_provider.dart';
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
    List<SyncAcknowledgement> acknowledgements,
  ) => _projectsDao.acknowledgePushed(acknowledgements);

  Future<ProjectModel?> get(String id) => _projectsDao.getProject(id);

  Future<List<ProjectModel>> getAll() => _projectsDao.getAll();

  Future<List<ProjectModel>> getPending() => _projectsDao.getPending();

  Future<void> delete(String id) => _projectsDao.deleteProject(id);
}

@riverpod
ProjectsLocalDataSource projectsLocalDataSource(Ref ref) =>
    ProjectsLocalDataSource(
      projectsDao: ref.watch(appDatabaseProvider).projectsDao,
    );
