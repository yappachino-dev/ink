import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/features/vault/data/ports/vault_local_store.dart';
import 'package:ink/features/vault/data/sources/vault_remote_data_source.dart';
import 'package:ink/features/vault/data/unified_vault_repository.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';
import 'package:ink/features/vault/domain/vault_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/vault_fixtures.dart';
import '../../../helpers/test_helpers.dart';

class MockVaultLocalDataSource extends Mock implements VaultLocalStore {}

class MockVaultRemoteDataSource extends Mock implements VaultRemoteDataSource {}

void main() {
  setUpAll(registerTestFallbacks);

  late MockVaultLocalDataSource mockLocal;
  late MockVaultRemoteDataSource mockRemote;
  late VaultRepository repository;

  setUp(() {
    mockLocal = MockVaultLocalDataSource();
    mockRemote = MockVaultRemoteDataSource();
    repository = UnifiedVaultRepository(
      local: mockLocal,
      remote: mockRemote,
      canSync: () => true,
    );
  });

  group('push conflict', () {
    setUp(() {
      when(() => mockLocal.getAllKeySlotRecords()).thenAnswer(
        (_) async => [VaultFixtures.buildKeySlot()],
      );
      when(() => mockLocal.getPendingKeySlotRecords()).thenAnswer(
        (_) async => [VaultFixtures.buildKeySlot()],
      );
      // syncKeys pulls before it pushes; the pull yields nothing so the
      // pending local slot is what reaches the server.
      when(() => mockRemote.getKeySlots()).thenAnswer((_) async => []);
    });

    test('a refused push surfaces as a vault key conflict', () async {
      when(() => mockRemote.saveKeySlots(any())).thenAnswer(
        (_) async => throw const GrpcError.alreadyExists(
          'key slot pin conflicts with the stored slot for this account',
        ),
      );

      final result = await repository.syncKeys();

      final failure = result as Failure<void, VaultFailure>;
      expect(failure.error, isA<VaultKeyConflict>());
    });

    test('an unrelated failure stays a core failure', () async {
      when(() => mockRemote.saveKeySlots(any())).thenAnswer(
        (_) async => throw const GrpcError.unavailable('offline'),
      );

      final result = await repository.syncKeys();

      final failure = result as Failure<void, VaultFailure>;
      expect(failure.error, isA<VaultCoreFailure>());
      expect(failure.error, isNot(isA<VaultKeyConflict>()));
    });
  });

  group('VaultRepository', () {
    test('saveKeySlot calls all necessary data sources', () async {
      when(() => mockLocal.saveKeySlotRecord(any())).thenAnswer((_) async {});

      final slot = VaultFixtures.buildKeySlot();

      await repository.saveKeySlot(slot);

      verify(() => mockLocal.saveKeySlotRecord(slot)).called(1);
    });

    test('getKeySlotByType calls correct data sources', () async {
      final slot = VaultFixtures.buildKeySlot();

      when(() => mockLocal.getKeySlotRecord(any())).thenAnswer((_) async {
        return slot;
      });

      await repository.getKeySlotByType(slot.type);

      verify(() => mockLocal.getKeySlotRecord(slot.type)).called(1);
    });
  });
}
