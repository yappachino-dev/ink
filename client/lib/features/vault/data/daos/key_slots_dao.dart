import 'package:drift/drift.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/features/vault/data/tables/key_slots.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';

part 'key_slots_dao.g.dart';

@DriftAccessor(tables: [KeySlots])
class KeySlotsDao extends DatabaseAccessor<AppDatabase>
    with _$KeySlotsDaoMixin {
  KeySlotsDao(super.attachedDatabase);

  Future<void> saveKeySlot(KeySlotsCompanion slot) =>
      into(keySlots).insert(slot, mode: InsertMode.insertOrReplace);

  Future<void> saveKeySlots(List<KeySlotsCompanion> slots) => batch((batch) {
    batch.insertAll(keySlots, slots, mode: InsertMode.insertOrReplace);
  });

  Future<List<KeySlotModel>> getAllKeySlots() => select(keySlots).get();

  Future<KeySlotModel?> getKeySlotByType(KeyType type) => (select(
    keySlots,
  )..where((tbl) => tbl.type.equals(type.index))).getSingleOrNull();

  Future<List<KeySlotModel>> getPendingKeySlots() => (select(
    keySlots,
  )..where((tbl) => tbl.syncStatus.equals(SyncStatus.modified.index))).get();

  Future<void> deleteKeySlot(KeyType type) => (delete(
    keySlots,
  )..where((tbl) => tbl.type.equals(type.index))).go();
}
