import 'package:ink/core/infrastructure/grpc/gen/sync/v1/sync.pbgrpc.dart';
import 'package:ink/core/infrastructure/grpc/grpc_connection_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_client.g.dart';

class SyncClient {
  SyncClient({required SyncServiceClient client}) : _client = client;

  final SyncServiceClient _client;

  Future<SyncResponse> sync(SyncRequest request) {
    return _client.sync(request);
  }
}

@Riverpod(keepAlive: true)
SyncClient syncClient(Ref ref) {
  final connection = ref.watch(grpcAuthConnectionProvider);

  return SyncClient(
    client: SyncServiceClient(
      connection.channel,
      options: connection.options,
      interceptors: connection.interceptors,
    ),
  );
}
