import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/infrastructure/data_source_runner.dart';
import 'package:ink/core/infrastructure/network/network_state_provider.dart';
import 'package:ink/features/vault/data/mappers/key_slot_remote_mapper.dart';
import 'package:ink/features/vault/data/ports/vault_local_store.dart';
import 'package:ink/features/vault/data/sources/vault_local_store_provider.dart';
import 'package:ink/features/vault/data/sources/vault_remote_data_source.dart';
import 'package:ink/features/vault/domain/entities/key_slot.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';
import 'package:ink/features/vault/domain/vault_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unified_vault_repository.g.dart';

class UnifiedVaultRepository with DataSourceRunner implements VaultRepository {
  UnifiedVaultRepository({
    required VaultLocalStore local,
    required VaultRemoteDataSource remote,
    required bool Function() canSync,
  }) : _local = local,
       _remote = remote,
       _canSync = canSync;

  final VaultLocalStore _local;
  final VaultRemoteDataSource _remote;
  final bool Function() _canSync;

  @override
  Future<Result<void, VaultFailure>> saveKeySlot(KeySlot slot) {
    return localRunner(
      call: () => _local.saveKeySlotRecord(slot),
      mapCore: VaultCoreFailure.new,
    );
  }

  @override
  Future<Result<void, VaultFailure>> saveKeySlots(List<KeySlot> slots) {
    return localRunner(
      call: () => _local.saveKeySlotRecords(slots),
      mapCore: VaultCoreFailure.new,
    );
  }

  @override
  Future<Result<List<KeySlot>, VaultFailure>> getAll() {
    return localRunner(
      call: _local.getAllKeySlotRecords,
      mapCore: VaultCoreFailure.new,
    );
  }

  @override
  Future<Result<KeySlot?, VaultFailure>> getKeySlotByType(KeyType type) {
    return localRunner(
      call: () => _local.getKeySlotRecord(type),
      mapCore: VaultCoreFailure.new,
    );
  }

  @override
  Future<Result<void, VaultFailure>> pushKeys() async {
    if (!_canSync()) return const Success(null);

    final result = await localRunner(
      call: _local.getAllKeySlotRecords,
      mapCore: VaultCoreFailure.new,
    );
    if (result case Failure(error: final e)) return Failure(e);

    return remoteRunner(
      call: () => _remote.saveKeySlots(
        result.unwrap.map((slot) => slot.toProto()).toList(),
      ),
      mapCore: VaultCoreFailure.new,
    );
  }

  @override
  Future<Result<void, VaultFailure>> syncKeys() async {
    if (!_canSync()) return const Success(null);

    final remoteResult = await remoteRunner(
      call: _remote.getKeySlots,
      mapCore: VaultCoreFailure.new,
    );
    if (remoteResult case Failure(error: final e)) return Failure(e);

    for (final remoteProto in remoteResult.unwrap) {
      final remoteKeySlot = remoteProto.toDomain();
      final localResult = await localRunner(
        call: () => _local.getKeySlotRecord(remoteKeySlot.type),
        mapCore: VaultCoreFailure.new,
      );
      if (localResult case Failure(error: final e)) return Failure(e);

      if (localResult.unwrap == null ||
          remoteKeySlot.updatedAt.isAfter(localResult.unwrap!.updatedAt)) {
        await localRunner(
          call: () => _local.saveKeySlotRecord(remoteKeySlot),
          mapCore: VaultCoreFailure.new,
        );
      }
    }

    final pendingResult = await localRunner(
      call: _local.getPendingKeySlotRecords,
      mapCore: VaultCoreFailure.new,
    );
    if (pendingResult case Failure(error: final e)) return Failure(e);

    if (pendingResult.unwrap.isEmpty) return const Success(null);

    final saveResult = await remoteRunner(
      call: () => _remote.saveKeySlots(
        pendingResult.unwrap.map((slot) => slot.toProto()).toList(),
      ),
      mapCore: VaultCoreFailure.new,
    );
    if (saveResult case Failure(error: final e)) {
      return Failure(e);
    }

    await localRunner(
      call: () => _local.saveKeySlotRecords(
        pendingResult.unwrap
            .map((slot) => slot.copyWith(syncStatus: SyncStatus.synced))
            .toList(),
      ),
      mapCore: VaultCoreFailure.new,
    );

    return const Success(null);
  }
}

@Riverpod(keepAlive: true)
VaultRepository vaultRepository(Ref ref) => UnifiedVaultRepository(
  local: ref.watch(vaultLocalStoreProvider),
  remote: ref.watch(vaultRemoteDataSourceProvider),
  canSync: () => ref.read(networkStateProvider).isAllowedToSync,
);
