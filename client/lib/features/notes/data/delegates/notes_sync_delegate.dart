import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/services/sync/syncable.dart';
import 'package:ink/features/notes/data/dto/note_dto.dart';
import 'package:ink/features/notes/data/notes_sync_engine.dart';
import 'package:ink/features/notes/domain/mappers/failures_mapper.dart';

class NotesSyncDelegate implements Syncable {
  NotesSyncDelegate({required NotesSyncEngine engine}) : _engine = engine;

  final NotesSyncEngine _engine;

  @override
  String get syncKey => 'notes';

  @override
  int get syncPriority => 50;

  @override
  Future<Result<List<Map<String, dynamic>>, CoreFailure>>
  getLocalChanges() async {
    final result = await _engine.getPendingNotes();

    return result.fold(
      (dtos) => Success(dtos.map((dto) => dto.toJson()).toList()),
      (failure) => Failure(failure.toCore()),
    );
  }

  @override
  Future<Result<void, CoreFailure>> acknowledgePush(
    List<Map<String, dynamic>> pushedData,
  ) async {
    final dtos = pushedData.map(NoteDto.fromJson).toList();

    final acknowledgements = dtos
        .map(
          (dto) => (
            id: dto.id,
            version: dto.version,
            isDeleted: dto.deletedAt != null,
          ),
        )
        .toList();

    final result = await _engine.acknowledgePushedNotes(acknowledgements);

    return result.fold(
      Success.new,
      (failure) => Failure(failure.toCore()),
    );
  }

  @override
  Future<Result<void, CoreFailure>> applyRemoteChanges(
    dynamic remoteData,
  ) async {
    final rawList = remoteData as List<dynamic>;
    final dtos = rawList
        .map((e) => NoteDto.fromJson(e as Map<String, dynamic>))
        .toList();

    final result = await _engine.applyRemoteNotes(dtos);

    return result.fold(
      Success.new,
      (failure) => Failure(failure.toCore()),
    );
  }
}
