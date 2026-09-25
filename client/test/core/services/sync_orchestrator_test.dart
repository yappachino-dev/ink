import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/grpc/gen/sync/v1/sync.pb.dart';
import 'package:ink/core/services/sync/sync_client.dart';
import 'package:ink/core/services/sync/sync_orchestrator.dart';
import 'package:ink/core/services/sync/sync_state.dart';
import 'package:ink/core/services/sync/sync_storage.dart';
import 'package:ink/core/services/sync/syncable.dart';
import 'package:mocktail/mocktail.dart';

class _MockSyncClient extends Mock implements SyncClient {}

class _MockSyncStorage extends Mock implements SyncStorage {}

class _RecordingSyncable implements Syncable {
  SyncChanges? acknowledgedChanges;
  SyncChanges? appliedChanges;

  @override
  int get syncPriority => 0;

  @override
  Future<Result<void, CoreFailure>> collectLocalChanges(
    SyncChanges changes,
  ) async {
    changes.notes.add(Note(id: 'local-note', version: 1));
    return const Success(null);
  }

  @override
  Future<Result<void, CoreFailure>> acknowledgePush(
    SyncChanges pushedChanges,
  ) async {
    acknowledgedChanges = pushedChanges;
    return const Success(null);
  }

  @override
  Future<Result<void, CoreFailure>> applyRemoteChanges(
    SyncChanges changes,
  ) async {
    appliedChanges = changes;
    return const Success(null);
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(SyncRequest());
  });

  test('acknowledges only changes collected for the push request', () async {
    final syncClient = _MockSyncClient();
    final syncStorage = _MockSyncStorage();
    final syncable = _RecordingSyncable();

    when(syncStorage.getSyncCursor).thenReturn(0);
    when(() => syncStorage.saveSyncCursor(any())).thenAnswer((_) async {});
    when(() => syncClient.sync(any())).thenAnswer(
      (_) async => SyncResponse(
        nextCursor: 1,
        changes: SyncChanges(notes: [Note(id: 'remote-only-note', version: 2)]),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        registeredSyncablesProvider.overrideWithValue([syncable]),
        syncClientProvider.overrideWithValue(syncClient),
        syncStorageProvider.overrideWithValue(syncStorage),
      ],
    );
    addTearDown(container.dispose);

    await container.read(syncOrchestratorProvider.notifier).performSync();

    expect(container.read(syncOrchestratorProvider), isA<SyncSuccess>());
    expect(syncable.acknowledgedChanges?.notes.single.id, 'local-note');
    expect(syncable.appliedChanges?.notes.single.id, 'remote-only-note');
    verify(() => syncStorage.saveSyncCursor(1)).called(1);
  });
}
