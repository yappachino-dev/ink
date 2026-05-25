import 'package:flutter_test/flutter_test.dart';
import 'package:ink/features/vault/data/daos/key_slots_dao.dart';
import 'package:ink/features/vault/data/mappers/key_slot_local_mapper.dart';
import 'package:ink/features/vault/data/sources/vault_local_data_source.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/vault_fixtures.dart';
import '../../../../helpers/test_helpers.dart';

class MockKeySlotsDao extends Mock implements KeySlotsDao {}

void main() {
  setUpAll(registerTestFallbacks);

  late MockKeySlotsDao mockDao;
  late VaultLocalDataSource dataSource;

  setUp(() {
    mockDao = MockKeySlotsDao();
    dataSource = VaultLocalDataSource(keySlotsDao: mockDao);
  });

  group('VaultLocalDataSource', () {
    test('saveKeySlot delegates to KeySlotsDao', () async {
      when(() => mockDao.saveKeySlot(any())).thenAnswer((_) async {});

      final companion = VaultFixtures.buildKeySlot().toCompanion();

      await dataSource.saveKeySlot(companion);

      verify(() => mockDao.saveKeySlot(companion)).called(1);
    });
  });
}
