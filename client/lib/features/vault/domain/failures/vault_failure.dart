import 'package:ink/core/domain/core_failure.dart';

sealed class VaultFailure {
  const VaultFailure();
}

class VaultLocked extends VaultFailure {
  const VaultLocked();
}

class VaultNotInitialized extends VaultFailure {
  const VaultNotInitialized();
}

class InvalidSecret extends VaultFailure {
  const InvalidSecret();
}

class VaultCoreFailure extends VaultFailure {
  const VaultCoreFailure(this.core);

  final CoreFailure core;
}

/// The account already holds a different slot for this unlock type, so this
/// device's key material was refused. Not retryable: it means the account was
/// set up somewhere else first.
class VaultKeyConflict extends VaultFailure {
  const VaultKeyConflict();
}
