import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/api/api_endpoints.dart' as endpoints;
import 'package:ink/core/infrastructure/api/dio_provider.dart';
import 'package:ink/core/infrastructure/data_source_runner.dart';
import 'package:ink/core/infrastructure/logger.dart';
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

      final dio = ref.read(dioProvider);
      final syncStorage = ref.read(syncStorageProvider);
      final currentCursor = syncStorage.getSyncCursor() ?? 0;

      final pushPayload = {
        'cursor': currentCursor,
        'changes': <String, dynamic>{},
      };

      final pendingChanges = pushPayload['changes']! as Map<String, dynamic>;

      for (final feature in syncables) {
        final localResult = await feature.getLocalChanges();

        if (localResult case Failure(error: final e)) {
          state = SyncError(e);
          return;
        }

        pendingChanges[feature.syncKey] = localResult.unwrap;
      }

      final networkResult = await remoteRunner(
        call: () => dio.post<Map<String, dynamic>>(
          endpoints.sync,
          data: pushPayload,
        ),
        mapCore: (core) => core,
      );

      if (networkResult case Failure(error: final e)) {
        state = SyncError(e);
        return;
      }

      final responseData = networkResult.unwrap.data;

      if (responseData == null) {
        state = const SyncError(UnexpectedFailure('Null response data'));
        return;
      }

      final remoteChanges = responseData['changes'] as Map<String, dynamic>;

      for (final feature in syncables) {
        if (pendingChanges.containsKey(feature.syncKey)) {
          final acknowledgementResult = await feature.acknowledgePush(
            pendingChanges[feature.syncKey] as List<Map<String, dynamic>>,
          );

          if (acknowledgementResult case Failure(error: final e)) {
            state = SyncError(e);
            return;
          }
        }

        if (remoteChanges.containsKey(feature.syncKey)) {
          final applyResult = await feature.applyRemoteChanges(
            remoteChanges[feature.syncKey],
          );

          if (applyResult case Failure(error: final e)) {
            state = SyncError(e);
            return;
          }
        }
      }

      if (responseData.containsKey('nextCursor')) {
        await syncStorage.saveSyncCursor(responseData['nextCursor'] as int);
      }

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
