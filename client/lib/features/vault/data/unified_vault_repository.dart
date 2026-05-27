import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/data_source_runner.dart';
import 'package:ink/core/infrastructure/network/network_state_provider.dart';
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/features/vault/data/mappers/key_slot_local_mapper.dart';
import 'package:ink/features/vault/data/mappers/key_slot_remote_mapper.dart';
import 'package:ink/features/vault/data/sources/vault_local_data_source.dart';
import 'package:ink/features/vault/data/sources/vault_remote_data_source.dart';
import 'package:ink/features/vault/domain/entities/key_slot.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';
import 'package:ink/features/vault/domain/vault_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unified_vault_repository.g.dart';

class UnifiedVaultRepository with DataSourceRunner implements VaultRepository {
  UnifiedVaultRepository({
    required VaultLocalDataSource local,
    required VaultRemoteDataSource remote,
    required bool Function() canSync,
  }) : _local = local,
       _remote = remote,
       _canSync = canSync;

  final VaultLocalDataSource _local;
  final VaultRemoteDataSource _remote;
  final bool Function() _canSync;

  @override
  Future<Result<void, VaultFailure>> saveKeySlot(KeySlot slot) async {
    return localRunner(
      call: () => _local.saveKeySlot(slot.toCompanion()),
      mapCore: VaultCoreFailure.new,
    );
  }

  @override
  Future<Result<void, VaultFailure>> saveKeySlots(List<KeySlot> slots) async {
    final companions = slots.map((s) => s.toCompanion()).toList();

    return localRunner(
      call: () => _local.saveKeySlots(companions),
      mapCore: VaultCoreFailure.new,
    );
  }

  @override
  Future<Result<List<KeySlot>, VaultFailure>> getAll() async {
    final result = await localRunner(
      call: _local.getAll,
      mapCore: VaultCoreFailure.new,
    );

    return result.map(
      (models) => models.map((model) => model.toDomain()).toList(),
    );
  }

  @override
  Future<Result<KeySlot?, VaultFailure>> getKeySlotByType(KeyType type) async {
    final result = await localRunner(
      call: () => _local.getKeySlotByType(type),
      mapCore: VaultCoreFailure.new,
    );

    return result.map((model) => model?.toDomain());
  }

  @override
  Future<Result<void, VaultFailure>> pushKeys() async {
    final result = await localRunner(
      call: _local.getAll,
      mapCore: VaultCoreFailure.new,
    );

    if (result case Failure(error: final e)) return Failure(e);
    final keys = result.unwrap;

    return remoteRunner(
      call: () => _remote.saveKeySlots(
        keys.map((m) => m.toDomain().toProto()).toList(),
      ),
      mapCore: VaultCoreFailure.new,
    );
  }

  @override
  Future<Result<void, VaultFailure>> syncKeys() async {
    final remoteResult = await remoteRunner(
      call: _remote.getKeySlots,
      mapCore: VaultCoreFailure.new,
    );

    if (remoteResult case Failure(error: final e)) return Failure(e);
    final remoteProtos = remoteResult.unwrap;

    // LWW update
    for (final remoteProto in remoteProtos) {
      final remoteKeySlot = remoteProto.toDomain();

      final localModelResult = await localRunner(
        call: () => _local.getKeySlotByType(remoteKeySlot.type),
        mapCore: VaultCoreFailure.new,
      );

      if (localModelResult case Failure(error: final e)) return Failure(e);
      final localModel = localModelResult.unwrap;

      if (localModel == null ||
          remoteKeySlot.updatedAt.isAfter(localModel.updatedAt)) {
        await localRunner(
          call: () => _local.saveKeySlot(remoteKeySlot.toCompanion()),
          mapCore: VaultCoreFailure.new,
        );
      }
    }

    final pendingModelsResult = await localRunner(
      call: _local.getPending,
      mapCore: VaultCoreFailure.new,
    );

    if (pendingModelsResult case Failure(error: final e)) return Failure(e);
    final pendingModels = pendingModelsResult.unwrap;

    if (pendingModels.isNotEmpty) {
      final pendingProtos = pendingModels
          .map((m) => m.toDomain().toProto())
          .toList();

      final saveResult = await remoteRunner(
        call: () => _remote.saveKeySlots(pendingProtos),
        mapCore: VaultCoreFailure.new,
      );

      if (saveResult is Success) {
        final toUpdate = pendingModels
            .map(
              (m) =>
                  m.copyWith(syncStatus: SyncStatus.synced).toCompanion(true),
            )
            .toList();

        await localRunner(
          call: () => _local.saveKeySlots(toUpdate),
          mapCore: VaultCoreFailure.new,
        );
      }
    }

    return const Success(null);
  }
}

@Riverpod(keepAlive: true)
VaultRepository vaultRepository(Ref ref) => UnifiedVaultRepository(
  local: ref.watch(vaultLocalDataSourceProvider),
  remote: ref.watch(vaultRemoteDataSourceProvider),
  canSync: () => ref.read(networkStateProvider).isAllowedToSync,
);
