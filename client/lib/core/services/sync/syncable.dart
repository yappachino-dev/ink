import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/grpc/gen/sync/v1/sync.pb.dart';

abstract class Syncable {
  // String get syncKey;
  int get syncPriority;

  // Future<Result<List<Map<String, dynamic>>, CoreFailure>> getLocalChanges();
  // Future<Result<void, CoreFailure>> acknowledgePush(
  //   List<Map<String, dynamic>> pushedData,
  // );
  // Future<Result<void, CoreFailure>> applyRemoteChanges(dynamic remoteData);

  Future<Result<void, CoreFailure>> collectLocalChanges(SyncChanges changes);
  Future<Result<void, CoreFailure>> acknowledgePush(SyncChanges changes);
  Future<Result<void, CoreFailure>> applyRemoteChanges(SyncChanges changes);
}
