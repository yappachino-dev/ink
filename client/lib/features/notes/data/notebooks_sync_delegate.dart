import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/grpc/gen/sync/v1/sync.pb.dart';
import 'package:ink/core/services/sync/syncable.dart';
import 'package:ink/features/notes/data/mappers/encrypted_notebook_remote_mapper.dart';
import 'package:ink/features/notes/data/notebooks_sync_engine.dart';
import 'package:ink/features/notes/domain/mappers/failures_mapper.dart';

class NotebooksSyncDelegate implements Syncable {
  NotebooksSyncDelegate({required NotebooksSyncEngine engine})
    : _engine = engine;

  final NotebooksSyncEngine _engine;

  @override
  int get syncPriority => 100;

  @override
  Future<Result<void, CoreFailure>> collectLocalChanges(
    SyncChanges changes,
  ) async {
    final result = await _engine.getPendingNotebooks();

    return result.fold((notebooks) {
      changes.notebooks.addAll(notebooks.map((notebook) => notebook.toProto()));
      return const Success(null);
    }, (failure) => Failure(failure.toCore()));
  }

  @override
  Future<Result<void, CoreFailure>> acknowledgePush(
    SyncChanges pushedChanges,
  ) async {
    final acks = pushedChanges.notebooks
        .map(
          (notebook) => (
            id: notebook.id,
            version: notebook.version,
            isDeleted: notebook.hasDeletedAt(),
          ),
        )
        .toList();

    final result = await _engine.acknowledgePushedNotebooks(acks);

    return result.fold(Success.new, (failure) => Failure(failure.toCore()));
  }

  @override
  Future<Result<void, CoreFailure>> applyRemoteChanges(
    SyncChanges changes,
  ) async {
    final result = await _engine.applyRemoteNotebooks(
      changes.notebooks.map((notebook) => notebook.toDomain()).toList(),
    );

    return result.fold(Success.new, (failure) => Failure(failure.toCore()));
  }
}
