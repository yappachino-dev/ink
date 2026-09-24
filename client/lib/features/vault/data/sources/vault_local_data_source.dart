import 'package:ink/app/database/database.dart';
import 'package:ink/features/vault/data/daos/key_slots_dao.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vault_local_data_source.g.dart';

class VaultLocalDataSource {
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
}

@Riverpod(keepAlive: true)
VaultLocalDataSource vaultLocalDataSource(Ref ref) => throw StateError(
  'vaultLocalDataSourceProvider must be overridden at the app root',
);
