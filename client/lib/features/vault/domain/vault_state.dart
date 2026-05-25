import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';

sealed class VaultState {
  const VaultState();
}

class VaultInitializing extends VaultState {
  const VaultInitializing();
}

class VaultNotInitialized extends VaultState {
  const VaultNotInitialized();
}

class VaultLocked extends VaultState {
  const VaultLocked({required this.unlockMethods});

  final List<KeyType> unlockMethods;
}

class VaultUnlocked extends VaultState {
  const VaultUnlocked();
}

class VaultError extends VaultState {
  const VaultError(this.failure);

  final VaultFailure failure;
}

class VaultFatal extends VaultState {
  const VaultFatal();
}
