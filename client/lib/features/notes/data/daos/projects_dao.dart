import 'package:drift/drift.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/data/tables/projects.dart';

part 'projects_dao.g.dart';

@DriftAccessor(tables: [Projects])
class ProjectsDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectsDaoMixin {
  ProjectsDao(super.attachedDatabase);

  Future<ProjectModel> insertProject(ProjectsCompanion note) =>
      into(projects).insertReturning(note);

  Future<void> updateProject(ProjectsCompanion note) =>
      update(projects).replace(note);

  Future<void> upsertFolder(ProjectsCompanion project) =>
      into(projects).insert(project, mode: InsertMode.insertOrReplace);

  Future<void> acknowledgePushed(
    List<SyncAck> acknowledgements,
  ) => batch((batch) {
    for (final ack in acknowledgements) {
      if (ack.isDeleted) {
        batch.deleteWhere(
          projects,
          (tbl) => tbl.id.equals(ack.id) & tbl.localVersion.equals(ack.version),
        );
      } else {
        batch.update(
          projects,
          ProjectsCompanion(
            syncStatus: const Value(SyncStatus.synced),
            lastSyncedVersion: Value(ack.version),
          ),
          where: (tbl) =>
              tbl.id.equals(ack.id) & tbl.localVersion.equals(ack.version),
        );
      }
    }
  });

  Future<ProjectModel?> getProject(String id) =>
      (select(projects)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<List<ProjectModel>> getAll() => select(projects).get();

  Future<List<ProjectModel>> getPending() =>
      (select(projects)..where(
            (tbl) => tbl.syncStatus.isIn([
              SyncStatus.modified.index,
              SyncStatus.deleted.index,
            ]),
          ))
          .get();

  Future<void> deleteProject(String id) =>
      (delete(projects)..where((tbl) => tbl.id.equals(id))).go();
}
