import 'package:drift/drift.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/services/sync/sync_indexes.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/data/tables/project_conflicts.dart';
import 'package:ink/features/notes/data/tables/projects.dart';

part 'projects_dao.g.dart';

@DriftAccessor(tables: [Projects, ProjectConflicts])
class ProjectsDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectsDaoMixin {
  ProjectsDao(super.attachedDatabase);

  Future<ProjectModel> insertProject(ProjectsCompanion note) =>
      into(projects).insertReturning(note);

  Future<void> updateProject(ProjectsCompanion note) =>
      update(projects).replace(note);

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

  Future<List<ProjectModel>> getAll() =>
      (select(projects)..where(
            (tbl) => tbl.syncStatus.isNotInValues(const [SyncStatus.deleted]),
          ))
          .get();

  Future<List<ProjectModel>> getByIds(List<String> ids) =>
      (select(projects)..where((tbl) => tbl.id.isIn(ids))).get();

  /// Applies a pre-computed set of remote delta writes atomically: every
  /// upsert, delete and conflict write runs inside a single transaction.
  Future<void> applyRemoteDeltas({
    List<ProjectsCompanion> upserts = const [],
    List<String> deletes = const [],
    List<(ProjectsCompanion project, ProjectConflictsCompanion conflict)>
        conflicts =
        const [],
  }) => batch((b) {
    b
      ..insertAll(projects, upserts, mode: InsertMode.replace)
      ..insertAll(
        projectConflicts,
        [for (final (_, conflict) in conflicts) conflict],
        mode: InsertMode.replace,
      );
    for (final (project, _) in conflicts) {
      b.update(
        projects,
        project,
        where: (tbl) => tbl.id.equals(project.id.value),
      );
    }
    if (deletes.isNotEmpty) {
      b.deleteWhere(projects, (tbl) => tbl.id.isIn(deletes));
    }
  });

  Future<List<ProjectModel>> getPending() =>
      (select(projects)..where(
            (tbl) => tbl.syncStatus.isIn(syncPendingPushIndexes),
          ))
          .get();

  /// Marks the project as locally deleted instead of removing it: the
  /// tombstone row stays in the pending-push queue so the deletion reaches
  /// the server on the next sync. It is physically removed once the push is
  /// acknowledged.
  Future<void> deleteProject(String id) =>
      (update(projects)..where((tbl) => tbl.id.equals(id))).write(
        ProjectsCompanion(
          syncStatus: const Value(SyncStatus.deleted),
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
}
