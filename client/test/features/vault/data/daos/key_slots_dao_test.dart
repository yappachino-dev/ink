import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/app/database/daos/key_slots_dao.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/app/database/mappers/key_slot_local_mapper.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';

import '../../../../fixtures/vault_fixtures.dart';

void main() {
  late AppDatabase db;
  late KeySlotsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.keySlotsDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('KeySlotsDao', () {
    final pinSlot = VaultFixtures.buildKeySlot(type: KeyType.pin);
    final graphSlot = VaultFixtures.buildKeySlot(type: KeyType.pattern);
    final newPinSlot = VaultFixtures.buildKeySlot(
      wmk: VaultFixtures.generateBytes(32, 99),
    );

    test('getKeySlotByType return null when db is empty', () async {
      final result = await dao.getKeySlotByType(KeyType.pin);
      expect(result, isNull);
    });

    test('saveKeySlot saves the slot which can be retrieved', () async {
      await dao.saveKeySlot(pinSlot.toCompanion());
      final result = await dao.getKeySlotByType(pinSlot.type);

      expect(result, isNotNull);
      expect(result!.type, equals(pinSlot.type));
      expect(result.salt, equals(pinSlot.salt));
    });

    test(
      'saveKeySlots saves all slots correctly',
      () async {
        final slots = [pinSlot.toCompanion(), graphSlot.toCompanion()];
        await dao.saveKeySlots(slots);

        final savedSlots = await dao.getAllKeySlots();
        expect(savedSlots.length, 2);

        final types = savedSlots.map((slot) => slot.toDomain().type);
        expect(types, containsAll([KeyType.pin, KeyType.pattern]));
      },
    );

    test('saveKeySlot replaces existing slot', () async {
      await dao.saveKeySlot(pinSlot.toCompanion());
      await dao.saveKeySlot(newPinSlot.toCompanion());

      final allSlots = await dao.getAllKeySlots();
      expect(allSlots.length, 1);

      final result = await dao.getKeySlotByType(KeyType.pin);
      expect(result!.salt, equals(newPinSlot.salt));
      expect(result.wrappedMasterKey, equals(newPinSlot.wrappedMasterKey));
    });
  });
}
