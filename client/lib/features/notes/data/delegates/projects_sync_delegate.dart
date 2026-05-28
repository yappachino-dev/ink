import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/grpc/gen/sync/v1/sync.pb.dart';
import 'package:ink/core/services/sync/syncable.dart';
import 'package:ink/features/notes/data/mappers/encrypted_project_remote_mapper.dart';
import 'package:ink/features/notes/data/projects_sync_engine.dart';
import 'package:ink/features/notes/domain/mappers/failures_mapper.dart';

class ProjectsSyncDelegate implements Syncable {
  ProjectsSyncDelegate({required ProjectsSyncEngine engine}) : _engine = engine;

  final ProjectsSyncEngine _engine;

  // @override
  // String get syncKey => 'projects';

  @override
  int get syncPriority => 100;

  @override
  Future<Result<void, CoreFailure>> collectLocalChanges(
    SyncChanges changes,
  ) async {
    final result = await _engine.getPendingProjects();

    return result.fold((projects) {
      changes.projects.addAll(projects.map((project) => project.toProto()));
      return const Success(null);
    }, (failure) => Failure(failure.toCore()));
  }

  // @override
  // Future<Result<List<Map<String, dynamic>>, CoreFailure>>
  // getLocalChanges() async {
  //   final result = await _engine.getPendingProjects();
  //
  //   return result.fold(
  //     (dtos) => Success(dtos.map((dto) => dto.toJson()).toList()),
  //     (failure) => Failure(failure.toCore()),
  //   );
  // }

  // @override
  // Future<Result<void, CoreFailure>> acknowledgePush(
  //   List<Map<String, dynamic>> pushedData,
  // ) async {
  //   final dtos = pushedData.map(ProjectDto.fromJson).toList();
  //
  //   final acknowledgements = dtos
  //       .map(
  //         (dto) => (
  //           id: dto.id,
  //           version: dto.version,
  //           isDeleted: dto.deletedAt != null,
  //         ),
  //       )
  //       .toList();
  //
  //   final result = await _engine.acknowledgePushedProjects(acknowledgements);
  //
  //   return result.fold(
  //     Success.new,
  //     (failure) => Failure(failure.toCore()),
  //   );
  // }

  @override
  Future<Result<void, CoreFailure>> acknowledgePush(SyncChanges changes) async {
    final acks = changes.projects
        .map(
          (project) => (
            id: project.id,
            version: project.version,
            isDeleted: project.hasDeletedAt(),
          ),
        )
        .toList();

    final result = await _engine.acknowledgePushedProjects(acks);

    return result.fold(
      Success.new,
      (failure) => Failure(failure.toCore()),
    );
  }

  // @override
  // Future<Result<void, CoreFailure>> applyRemoteChanges(
  //   dynamic remoteData,
  // ) async {
  //   final rawList = remoteData as List<dynamic>;
  //   final dtos = rawList
  //       .map((e) => ProjectDto.fromJson(e as Map<String, dynamic>))
  //       .toList();
  //
  //   final result = await _engine.applyRemoteProjects(dtos);
  //
  //   return result.fold(
  //     Success.new,
  //     (failure) => Failure(failure.toCore()),
  //   );
  // }

  @override
  Future<Result<void, CoreFailure>> applyRemoteChanges(
    SyncChanges changes,
  ) async {
    final result = await _engine.applyRemoteProjects(
      changes.projects.map((project) => project.toDomain()).toList(),
    );

    return result.fold(
      Success.new,
      (failure) => Failure(failure.toCore()),
    );
  }
}
