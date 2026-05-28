import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/data_source_runner.dart';
import 'package:ink/core/infrastructure/grpc/gen/sync/v1/sync.pbgrpc.dart';
import 'package:ink/core/infrastructure/logger.dart';
import 'package:ink/core/services/sync/sync_client.dart';
import 'package:ink/core/services/sync/sync_state.dart';
import 'package:ink/core/services/sync/sync_storage.dart';
import 'package:ink/core/services/sync/syncable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_orchestrator.g.dart';

@Riverpod(keepAlive: true)
List<Syncable> registeredSyncables(Ref ref) =>
    throw UnimplementedError('registeredSyncables must be overriden in main');

@Riverpod(keepAlive: true)
class SyncOrchestrator extends _$SyncOrchestrator with DataSourceRunner {
  @override
  SyncState build() => const SyncIdle();

  Future<void> performSync() async {
    if (state is SyncSyncing) return;
    state = const SyncSyncing();

    try {
      final rawSyncables = ref.read(registeredSyncablesProvider);
      final syncables = List<Syncable>.from(rawSyncables)
        ..sort((a, b) => b.syncPriority.compareTo(a.syncPriority));

      final syncClient = ref.read(syncClientProvider);
      final syncStorage = ref.read(syncStorageProvider);
      final currentCursor = syncStorage.getSyncCursor() ?? 0;

      final request = SyncRequest(
        cursor: currentCursor,
        changes: SyncChanges(),
      );

      for (final delegate in syncables) {
        final localResult = await delegate.collectLocalChanges(request.changes);

        if (localResult case Failure(error: final e)) {
          state = SyncError(e);
          return;
        }
      }

      final syncResult = await remoteRunner(
        call: () => syncClient.sync(request),
        mapCore: (core) => core,
      );

      if (syncResult case Failure(error: final e)) {
        state = SyncError(e);
        return;
      }

      final syncResponse = syncResult.unwrap;

      for (final delegate in syncables) {
        final ackResult = await delegate.acknowledgePush(
          syncResponse.changes,
        );
        if (ackResult case Failure(error: final e)) {
          state = SyncError(e);
          return;
        }

        final applyResult = await delegate.applyRemoteChanges(
          syncResponse.changes,
        );
        if (applyResult case Failure(error: final e)) {
          state = SyncError(e);
          return;
        }
      }

      await syncStorage.saveSyncCursor(syncResponse.nextCursor);

      state = const SyncSuccess();
    } catch (e, st) {
      logger.e(
        'Unhandled exception in SyncOrchestrator.performSync',
        error: e,
        stackTrace: st,
      );

      state = SyncError(UnexpectedFailure(e));
    }
  }
}
