import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/grpc/gen/sync/v1/sync.pb.dart';

abstract class Syncable {
  int get syncPriority;

  Future<Result<void, CoreFailure>> collectLocalChanges(SyncChanges changes);
  Future<Result<void, CoreFailure>> acknowledgePush(SyncChanges changes);
  Future<Result<void, CoreFailure>> applyRemoteChanges(SyncChanges changes);
}
