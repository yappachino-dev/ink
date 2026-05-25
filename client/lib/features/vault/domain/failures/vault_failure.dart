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
