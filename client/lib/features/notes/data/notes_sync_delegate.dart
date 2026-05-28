import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/grpc/gen/sync/v1/sync.pb.dart';
import 'package:ink/core/services/sync/syncable.dart';
import 'package:ink/features/notes/data/mappers/encrypted_note_remote_mapper.dart';
import 'package:ink/features/notes/data/notes_sync_engine.dart';
import 'package:ink/features/notes/domain/mappers/failures_mapper.dart';

class NotesSyncDelegate implements Syncable {
  NotesSyncDelegate({required NotesSyncEngine engine}) : _engine = engine;

  final NotesSyncEngine _engine;

  @override
  int get syncPriority => 50;

  @override
  Future<Result<void, CoreFailure>> collectLocalChanges(
    SyncChanges changes,
  ) async {
    final result = await _engine.getPendingNotes();

    return result.fold((notes) {
      changes.notes.addAll(notes.map((note) => note.toProto()));
      return const Success(null);
    }, (failure) => Failure(failure.toCore()));
  }

  @override
  Future<Result<void, CoreFailure>> acknowledgePush(SyncChanges changes) async {
    final acks = changes.notes
        .map(
          (note) => (
            id: note.id,
            version: note.version,
            isDeleted: note.hasDeletedAt(),
          ),
        )
        .toList();

    final result = await _engine.acknowledgePushedNotes(acks);

    return result.fold(
      Success.new,
      (failure) => Failure(failure.toCore()),
    );
  }

  @override
  Future<Result<void, CoreFailure>> applyRemoteChanges(
    SyncChanges changes,
  ) async {
    final result = await _engine.applyRemoteNotes(
      changes.notes.map((note) => note.toDomain()).toList(),
    );

    return result.fold(
      Success.new,
      (failure) => Failure(failure.toCore()),
    );
  }
}
