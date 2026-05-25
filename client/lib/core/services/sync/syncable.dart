import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';

abstract class Syncable {
  String get syncKey;
  int get syncPriority;

  Future<Result<List<Map<String, dynamic>>, CoreFailure>> getLocalChanges();
  Future<Result<void, CoreFailure>> acknowledgePush(
    List<Map<String, dynamic>> pushedData,
  );
  Future<Result<void, CoreFailure>> applyRemoteChanges(dynamic remoteData);
}
