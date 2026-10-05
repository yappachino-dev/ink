import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';
import 'package:ink/i18n/strings.g.dart';

extension VaultFailureUiMessage on VaultFailure {
  String message(Translations strings) {
    return switch (this) {
      VaultKeyConflict() => strings.vault.errors.keyConflict,
      VaultLocked() => strings.common.errors.unknown,
      VaultNotInitialized() => strings.common.errors.unknown,
      InvalidSecret() => strings.common.errors.unknown,
      VaultCoreFailure(:final core) => _coreMessage(core, strings),
    };
  }

  static String _coreMessage(CoreFailure core, Translations strings) {
    if (core is NetworkFailure) return strings.common.errors.network;
    if (core is TimeoutFailure) return strings.common.errors.timeout;
    return strings.common.errors.unknown;
  }
}
