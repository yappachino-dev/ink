import 'package:ink/core/infrastructure/grpc/gen/vault/v1/vault.pbgrpc.dart';
import 'package:ink/core/infrastructure/grpc/grpc_connection_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vault_remote_data_source.g.dart';

class VaultRemoteDataSource {
  VaultRemoteDataSource({required VaultServiceClient client})
    : _client = client;

  final VaultServiceClient _client;

  Future<List<KeySlot>> getKeySlots() async {
    final response = await _client.getKeySlots(GetKeySlotsRequest());
    return response.keySlots.toList();
  }

  Future<void> saveKeySlots(List<KeySlot> slots) async {
    await _client.saveKeySlots(SaveKeySlotsRequest(keySlots: slots));
  }
}

@Riverpod(keepAlive: true)
VaultRemoteDataSource vaultRemoteDataSource(Ref ref) {
  final connection = ref.watch(grpcAuthConnectionProvider);

  return VaultRemoteDataSource(
    client: VaultServiceClient(
      connection.channel,
      options: connection.options,
      interceptors: connection.interceptors,
    ),
  );
}
