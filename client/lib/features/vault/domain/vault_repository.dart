import 'package:ink/core/domain/result.dart';
import 'package:ink/features/vault/domain/entities/key_slot.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';

abstract class VaultRepository {
  Future<Result<void, VaultFailure>> saveKeySlot(KeySlot slot);
  Future<Result<void, VaultFailure>> saveKeySlots(List<KeySlot> slots);
  Future<Result<List<KeySlot>, VaultFailure>> getAll();
  Future<Result<KeySlot?, VaultFailure>> getKeySlotByType(KeyType type);
  Future<Result<void, VaultFailure>> pushKeys();
  Future<Result<void, VaultFailure>> syncKeys();
}
