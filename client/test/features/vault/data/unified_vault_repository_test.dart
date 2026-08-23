import 'package:flutter_test/flutter_test.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/features/vault/data/mappers/key_slot_local_mapper.dart';
import 'package:ink/features/vault/data/sources/vault_local_data_source.dart';
import 'package:ink/features/vault/data/sources/vault_remote_data_source.dart';
import 'package:ink/features/vault/data/unified_vault_repository.dart';
import 'package:ink/features/vault/domain/vault_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/vault_fixtures.dart';
import '../../../helpers/test_helpers.dart';

class MockVaultLocalDataSource extends Mock implements VaultLocalDataSource {}

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

  group('VaultRepository', () {
    test('saveKeySlot calls all necessary data sources', () async {
      when(() => mockLocal.saveKeySlot(any())).thenAnswer((_) async {});

      final slot = VaultFixtures.buildKeySlot();

      await repository.saveKeySlot(slot);

      verify(() => mockLocal.saveKeySlot(slot.toCompanion())).called(1);
    });

    test('getKeySlotByType calls correct data sources', () async {
      final slot = VaultFixtures.buildKeySlot();

      final model = KeySlotModel(
        type: slot.type,
        salt: slot.salt,
        wrappedMasterKey: slot.wrappedMasterKey,
        updatedAt: slot.updatedAt,
        syncStatus: SyncStatus.synced,
      );

      when(() => mockLocal.getKeySlotByType(any())).thenAnswer((_) async {
        return model;
      });

      await repository.getKeySlotByType(slot.type);

      verify(() => mockLocal.getKeySlotByType(slot.type)).called(1);
    });
  });
}
