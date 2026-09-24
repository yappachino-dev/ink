import 'package:ink/features/vault/domain/entities/key_slot.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';

abstract interface class VaultLocalStore {
  Future<void> saveKeySlotRecord(KeySlot slot);
  Future<void> saveKeySlotRecords(List<KeySlot> slots);
  Future<List<KeySlot>> getAllKeySlotRecords();
  Future<KeySlot?> getKeySlotRecord(KeyType type);
  Future<List<KeySlot>> getPendingKeySlotRecords();
}
