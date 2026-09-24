import 'package:flutter_test/flutter_test.dart';
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
