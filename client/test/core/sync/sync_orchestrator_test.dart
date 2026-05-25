import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/api/api_endpoints.dart' as endpoints;
import 'package:ink/core/infrastructure/api/dio_provider.dart';
import 'package:ink/core/services/sync/sync_orchestrator.dart';
import 'package:ink/core/services/sync/sync_state.dart';
import 'package:ink/core/services/sync/sync_storage.dart';
import 'package:ink/core/services/sync/syncable.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helpers.dart';

class MockDio extends Mock implements Dio {}

class MockSyncStorage extends Mock implements SyncStorage {}

class MockSyncable extends Mock implements Syncable {}

void main() {
  setUpAll(registerTestFallbacks);

  late MockDio mockDio;
  late MockSyncStorage mockSyncStorage;

  late MockSyncable delegateHigh;
  late MockSyncable delegateLow;

  late ProviderContainer container;

  setUp(() {
    mockDio = MockDio();
    mockSyncStorage = MockSyncStorage();

    delegateHigh = MockSyncable();
    when(() => delegateHigh.syncPriority).thenReturn(100);
    when(() => delegateHigh.syncKey).thenReturn('high_priority');

    delegateLow = MockSyncable();
    when(() => delegateLow.syncPriority).thenReturn(50);
    when(() => delegateLow.syncKey).thenReturn('low_priority');

    container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(mockDio),
        syncStorageProvider.overrideWithValue(mockSyncStorage),
        registeredSyncablesProvider.overrideWithValue([
          delegateLow,
          delegateHigh,
        ]),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  SyncOrchestrator getOrchestrator() =>
      container.read(syncOrchestratorProvider.notifier);
  SyncState getState() => container.read(syncOrchestratorProvider);

  group('SyncOrchestrator', () {
    test('initial state is SyncIdle', () {
      expect(getState(), isA<SyncIdle>());
    });

    test(
      'Happy Path: Complete sync workflow succeeds and saves cursor',
      () async {
        when(() => mockSyncStorage.getSyncCursor()).thenReturn(1);
        when(
          () => mockSyncStorage.saveSyncCursor(any()),
        ).thenAnswer((_) async {});

        when(
          () => delegateHigh.getLocalChanges(),
        ).thenAnswer((_) async => const Success([]));
        when(
          () => delegateLow.getLocalChanges(),
        ).thenAnswer((_) async => const Success([]));

        final mockResponse = Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: endpoints.sync),
          data: {
            'next_cursor': 2,
            'changes': {
              'high_priority': [
                {'id': '1'},
              ],
              'low_priority': [
                {'id': '2'},
              ],
            },
          },
        );

        when(
          () => mockDio.post<Map<String, dynamic>>(
            endpoints.sync,
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => mockResponse);

        when(
          () => delegateHigh.acknowledgePush(any()),
        ).thenAnswer((_) async => const Success(null));
        when(
          () => delegateLow.acknowledgePush(any()),
        ).thenAnswer((_) async => const Success(null));
        when(
          () => delegateHigh.applyRemoteChanges(any()),
        ).thenAnswer((_) async => const Success(null));
        when(
          () => delegateLow.applyRemoteChanges(any()),
        ).thenAnswer((_) async => const Success(null));

        await getOrchestrator().performSync();

        verifyInOrder([
          () => delegateHigh.getLocalChanges(),
          () => delegateLow.getLocalChanges(),

          () => mockDio.post<Map<String, dynamic>>(
            endpoints.sync,
            data: any(named: 'data'),
          ),

          () => delegateHigh.acknowledgePush(any()),
          () => delegateHigh.applyRemoteChanges(any()),

          () => delegateLow.acknowledgePush(any()),
          () => delegateLow.applyRemoteChanges(any()),

          () => mockSyncStorage.saveSyncCursor(2),
        ]);

        expect(getState(), isA<SyncSuccess>());
      },
    );

    test(
      'Short-circuit: Aborts and emits SyncError if getLocalChanges fails',
      () async {
        when(() => mockSyncStorage.getSyncCursor()).thenReturn(1);

        when(() => delegateHigh.getLocalChanges()).thenAnswer(
          (_) async => const Failure(StorageFailure('DB Error')),
        );

        await getOrchestrator().performSync();

        expect(getState(), isA<SyncError>());

        verifyNever(() => mockDio.post(any(), data: any(named: 'data')));
        verifyNever(() => delegateLow.getLocalChanges());
      },
    );

    test(
      'Short-circuit: Aborts and emits SyncError if network request fails',
      () async {
        when(() => mockSyncStorage.getSyncCursor()).thenReturn(1);
        when(
          () => delegateHigh.getLocalChanges(),
        ).thenAnswer((_) async => const Success([]));
        when(
          () => delegateLow.getLocalChanges(),
        ).thenAnswer((_) async => const Success([]));

        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          ),
        ).thenThrow(
          DioException(requestOptions: RequestOptions(path: endpoints.sync)),
        );

        await getOrchestrator().performSync();

        expect(getState(), isA<SyncError>());

        verifyNever(() => delegateHigh.applyRemoteChanges(any()));
        verifyNever(() => mockSyncStorage.saveSyncCursor(any()));
      },
    );

    test(
      'Short-circuit: Aborts and emits SyncError if applying remote changes fails',
      () async {
        when(() => mockSyncStorage.getSyncCursor()).thenReturn(1);
        when(
          () => delegateHigh.getLocalChanges(),
        ).thenAnswer((_) async => const Success([]));
        when(
          () => delegateLow.getLocalChanges(),
        ).thenAnswer((_) async => const Success([]));

        final mockResponse = Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: endpoints.sync),
          data: {
            'next_cursor': 2,
            'changes': {'high_priority': []},
          },
        );

        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => mockResponse);

        when(
          () => delegateHigh.acknowledgePush(any()),
        ).thenAnswer((_) async => const Success(null));

        when(() => delegateHigh.applyRemoteChanges(any())).thenAnswer(
          (_) async => const Failure(StorageFailure('Parse Error')),
        );

        await getOrchestrator().performSync();

        expect(getState(), isA<SyncError>());

        verifyNever(() => mockSyncStorage.saveSyncCursor(any()));
      },
    );
  });
}
