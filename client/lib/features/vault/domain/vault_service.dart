import 'package:ink/core/domain/result.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';

abstract class VaultService {
  Future<Result<void, VaultFailure>> intializeNewVault(
    Map<KeyType, String> initialSecrets,
  );
  Future<Result<List<KeyType>, VaultFailure>> getUnlockMethods();
  Future<Result<void, VaultFailure>> unlock(KeyType type, String secret);
  Future<Result<void, VaultFailure>> pushKeys();
}
