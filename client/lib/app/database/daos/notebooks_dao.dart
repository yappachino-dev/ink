import 'package:drift/drift.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/services/sync/sync_indexes.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/data/tables/notebook_conflicts.dart';
import 'package:ink/features/notes/data/tables/notebooks.dart';

part 'notebooks_dao.g.dart';

@DriftAccessor(tables: [Notebooks, NotebookConflicts])
class NotebooksDao extends DatabaseAccessor<AppDatabase>
    with _$NotebooksDaoMixin {
  NotebooksDao(super.attachedDatabase);

  Future<NotebookModel> insertNotebook(NotebooksCompanion note) =>
      into(notebooks).insertReturning(note);

  Future<void> updateNotebook(NotebooksCompanion note) =>
      update(notebooks).replace(note);

  Future<void> acknowledgePushed(List<SyncAck> acknowledgements) =>
      batch((batch) {
        for (final ack in acknowledgements) {
          if (ack.isDeleted) {
            batch.deleteWhere(
              notebooks,
              (tbl) =>
                  tbl.id.equals(ack.id) & tbl.localVersion.equals(ack.version),
            );
          } else {
            batch.update(
              notebooks,
              NotebooksCompanion(
                syncStatus: const Value(SyncStatus.synced),
                lastSyncedVersion: Value(ack.version),
              ),
              where: (tbl) =>
                  tbl.id.equals(ack.id) & tbl.localVersion.equals(ack.version),
            );
          }
        }
      });

  Future<NotebookModel?> getNotebook(String id) =>
      (select(notebooks)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<List<NotebookModel>> getAll() =>
      (select(notebooks)..where(
            (tbl) => tbl.syncStatus.isNotInValues(const [SyncStatus.deleted]),
          ))
          .get();

  Future<List<NotebookModel>> getByIds(List<String> ids) =>
      (select(notebooks)..where((tbl) => tbl.id.isIn(ids))).get();

  /// Applies a pre-computed set of remote delta writes atomically: every
  /// upsert, delete and conflict write runs inside a single transaction.
  Future<void> applyRemoteDeltas({
    List<NotebooksCompanion> upserts = const [],
    List<String> deletes = const [],
    List<(NotebooksCompanion notebook, NotebookConflictsCompanion conflict)>
        conflicts =
        const [],
  }) => batch((b) {
    b
      ..insertAll(notebooks, upserts, mode: InsertMode.replace)
      ..insertAll(notebookConflicts, [
        for (final (_, conflict) in conflicts) conflict,
      ], mode: InsertMode.replace);
    for (final (notebook, _) in conflicts) {
      b.update(
        notebooks,
        notebook,
        where: (tbl) => tbl.id.equals(notebook.id.value),
      );
    }
    if (deletes.isNotEmpty) {
      b.deleteWhere(notebooks, (tbl) => tbl.id.isIn(deletes));
    }
  });

  Future<List<NotebookModel>> getPending() => (select(
    notebooks,
  )..where((tbl) => tbl.syncStatus.isIn(syncPendingPushIndexes))).get();

  /// Marks the notebook as locally deleted instead of removing it: the
  /// tombstone row stays in the pending-push queue so the deletion reaches
  /// the server on the next sync. It is physically removed once the push is
  /// acknowledged.
  Future<void> deleteNotebook(String id) =>
      (update(notebooks)..where((tbl) => tbl.id.equals(id))).write(
        NotebooksCompanion(
          syncStatus: const Value(SyncStatus.deleted),
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
}
