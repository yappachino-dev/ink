import 'package:ink/app/database/daos/key_slots_dao.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/app/database/mappers/key_slot_local_mapper.dart';
import 'package:ink/features/vault/data/ports/vault_local_store.dart';
import 'package:ink/features/vault/domain/entities/key_slot.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vault_local_data_source.g.dart';

class VaultLocalDataSource implements VaultLocalStore {
  VaultLocalDataSource({required KeySlotsDao keySlotsDao})
    : _keySlotsDao = keySlotsDao;

  final KeySlotsDao _keySlotsDao;

  Future<void> saveKeySlot(KeySlotsCompanion slot) async {
    await _keySlotsDao.saveKeySlot(slot);
  }

  Future<void> saveKeySlots(List<KeySlotsCompanion> slots) async {
    await _keySlotsDao.saveKeySlots(slots);
  }

  Future<List<KeySlotModel>> getAll() {
    return _keySlotsDao.getAllKeySlots();
  }

  Future<KeySlotModel?> getKeySlotByType(KeyType type) {
    return _keySlotsDao.getKeySlotByType(type);
  }

  Future<List<KeySlotModel>> getPending() {
    return _keySlotsDao.getPendingKeySlots();
  }

  @override
  Future<void> saveKeySlotRecord(KeySlot slot) =>
      _keySlotsDao.saveKeySlot(slot.toCompanion());

  @override
  Future<void> saveKeySlotRecords(List<KeySlot> slots) => _keySlotsDao
      .saveKeySlots(slots.map((slot) => slot.toCompanion()).toList());

  @override
  Future<List<KeySlot>> getAllKeySlotRecords() async =>
      (await _keySlotsDao.getAllKeySlots())
          .map((model) => model.toDomain())
          .toList();

  @override
  Future<KeySlot?> getKeySlotRecord(KeyType type) async =>
      (await _keySlotsDao.getKeySlotByType(type))?.toDomain();

  @override
  Future<List<KeySlot>> getPendingKeySlotRecords() async =>
      (await _keySlotsDao.getPendingKeySlots())
          .map((model) => model.toDomain())
          .toList();
}

@Riverpod(keepAlive: true)
VaultLocalDataSource vaultLocalDataSource(Ref ref) => throw StateError(
  'vaultLocalStoreProvider must be overridden at the app root',
);
