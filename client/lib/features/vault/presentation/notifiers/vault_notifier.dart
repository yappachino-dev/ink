import 'dart:async';

import 'package:ink/core/services/session/session_manager.dart';
import 'package:ink/features/vault/data/secure_vault_service.dart';
import 'package:ink/features/vault/domain/vault_service.dart';
import 'package:ink/features/vault/domain/vault_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vault_notifier.g.dart';

@Riverpod(keepAlive: true)
class VaultNotifier extends _$VaultNotifier {
  @override
  VaultState build() {
    final hasAccessToken = ref.watch(isAccessTokenPresentProvider);
    final hasMasterKey = ref.watch(isMasterKeyPresentProvider);

    if (hasMasterKey) return const VaultUnlocked();

    final vaultService = ref.watch(vaultServiceProvider);

    unawaited(_checkInitalizationState(vaultService, hasAccessToken));
    return const VaultInitializing();
  }

  Future<void> forcePushKeys() async {
    final vaultService = ref.read(vaultServiceProvider);
    await vaultService.pushKeys();

    if (!ref.read(isMasterKeyPresentProvider)) {
      unawaited(
        _checkInitalizationState(
          vaultService,
          ref.read(isAccessTokenPresentProvider),
        ),
      );
    }
  }

  Future<void> _checkInitalizationState(
    VaultService vaultService,
    bool hasAccesssToken,
  ) async {
    final result = await vaultService.getUnlockMethods();

    if (ref.read(isMasterKeyPresentProvider)) return;

    state = result.fold(
      (keys) => keys.isNotEmpty
          ? VaultLocked(unlockMethods: keys)
          : hasAccesssToken
          ? const VaultFatal()
          : const VaultNotInitialized(),
      VaultError.new,
    );
  }
}
