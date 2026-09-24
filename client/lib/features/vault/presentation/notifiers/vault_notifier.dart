import 'dart:async';

import 'package:ink/core/domain/result.dart';
import 'package:ink/features/vault/domain/vault_providers.dart';
import 'package:ink/features/vault/domain/vault_service.dart';
import 'package:ink/features/vault/domain/vault_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vault_notifier.g.dart';

@Riverpod(keepAlive: true)
class VaultNotifier extends _$VaultNotifier {
  @override
  VaultState build() {
    final session = ref.watch(vaultSessionStatusProvider);
    if (!session.isLoaded) return const VaultInitializing();

    if (session.hasMasterKey) return const VaultUnlocked();

    final vaultService = ref.watch(vaultServiceProvider);

    unawaited(_checkInitalizationState(vaultService, session.hasAccessToken));
    return const VaultInitializing();
  }

  Future<void> forcePushKeys() async {
    final vaultService = ref.read(vaultServiceProvider);
    await vaultService.pushKeys();

    final session = ref.read(vaultSessionStatusProvider);
    if (!session.hasMasterKey) {
      unawaited(
        _checkInitalizationState(vaultService, session.hasAccessToken),
      );
    }
  }

  Future<void> _checkInitalizationState(
    VaultService vaultService,
    bool hasAccesssToken,
  ) async {
    if (hasAccesssToken) {
      final pullResult = await vaultService.pullKeys();
      if (pullResult case Failure(error: final e)) {
        state = VaultError(e);
      }
    }

    final result = await vaultService.getUnlockMethods();

    if (ref.read(vaultSessionStatusProvider).hasMasterKey) return;

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
