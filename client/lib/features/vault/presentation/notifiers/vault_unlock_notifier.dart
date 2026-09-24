import 'dart:async';
import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/core/domain/sync_events.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';
import 'package:ink/features/vault/domain/vault_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vault_unlock_notifier.g.dart';
part 'vault_unlock_notifier.freezed.dart';

@freezed
sealed class VaultUnlockData with _$VaultUnlockData {
  const factory VaultUnlockData({
    @Default(false) bool isUnlocking,
    VaultFailure? failure,
    @Default(0) int failureStreak,
    DateTime? lockedUntil,
  }) = _VaultUnlockData;
}

/// Progressive backoff after failed unlock attempts: 2s, 4s, 8s … capped at
/// 5 minutes. Slows offline brute-force of PIN/pattern beyond Argon2 cost.
Duration unlockLockoutFor(int failureStreak) {
  final exp = math.min(failureStreak - 1, 8);
  return Duration(seconds: math.min(2 << math.max(exp, 0), 300));
}

@riverpod
class VaultUnlock extends _$VaultUnlock {
  @override
  VaultUnlockData build() => const VaultUnlockData();

  bool get _isLocked {
    final until = state.lockedUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  void _registerFailure() {
    final streak = state.failureStreak + 1;
    state = state.copyWith(
      failureStreak: streak,
      lockedUntil: DateTime.now().add(unlockLockoutFor(streak)),
    );
  }

  Future<void> unlockWithPin(String secret) async {
    if (state.isUnlocking || _isLocked) return;

    state = state.copyWith(isUnlocking: true, failure: null);

    final result = await ref
        .read(vaultServiceProvider)
        .unlock(KeyType.pin, secret);

    if (!ref.mounted) return;

    result.fold(
      (_) => state = state.copyWith(
        isUnlocking: false,
        failureStreak: 0,
        lockedUntil: null,
      ),
      (failure) {
        _registerFailure();
        state = state.copyWith(isUnlocking: false, failure: failure);
      },
    );
  }

  Future<void> unlockWithPattern(List<int> secret) async {
    if (state.isUnlocking || _isLocked) return;

    state = state.copyWith(isUnlocking: true, failure: null);

    final result = await ref
        .read(vaultServiceProvider)
        .unlock(KeyType.pattern, secret.join());

    if (!ref.mounted) return;

    unawaited(ref.read(syncControllerProvider).performSync());

    result.fold(
      (_) => state = state.copyWith(
        isUnlocking: false,
        failureStreak: 0,
        lockedUntil: null,
      ),
      (failure) {
        _registerFailure();
        state = state.copyWith(isUnlocking: false, failure: failure);
      },
    );
  }

  Future<void> unlockWithPhrase(List<String> secret) async {
    if (state.isUnlocking || _isLocked) return;

    state = state.copyWith(isUnlocking: true, failure: null);

    final result = await ref
        .read(vaultServiceProvider)
        .unlock(KeyType.recoveryPhrase, secret.join());

    if (!ref.mounted) return;

    unawaited(ref.read(syncControllerProvider).performSync());

    result.fold(
      (_) => state = state.copyWith(
        isUnlocking: false,
        failureStreak: 0,
        lockedUntil: null,
      ),
      (failure) {
        _registerFailure();
        state = state.copyWith(isUnlocking: false, failure: failure);
      },
    );
  }
}
