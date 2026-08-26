import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/features/vault/data/secure_vault_service.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';
import 'package:ink/features/vault/domain/vault_service.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_unlock_notifier.dart';

class _FakeVaultService implements VaultService {
  _FakeVaultService() : failWith = const InvalidSecret();

  final VaultFailure failWith;
  int unlockCalls = 0;

  @override
  Future<Result<void, VaultFailure>> unlock(KeyType type, String secret) async {
    unlockCalls++;
    return Failure(failWith);
  }

  @override
  Future<Result<void, VaultFailure>> intializeNewVault(
    Map<KeyType, String> initialSecrets,
  ) async => const Success(null);

  @override
  Future<Result<List<KeyType>, VaultFailure>> getUnlockMethods() async =>
      const Success([]);

  @override
  Future<Result<void, VaultFailure>> pullKeys() async => const Success(null);

  @override
  Future<Result<void, VaultFailure>> pushKeys() async => const Success(null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('unlockLockoutFor escalates exponentially and caps at 5 minutes', () {
    expect(unlockLockoutFor(1), const Duration(seconds: 2));
    expect(unlockLockoutFor(2), const Duration(seconds: 4));
    expect(unlockLockoutFor(3), const Duration(seconds: 8));
    expect(unlockLockoutFor(9), const Duration(minutes: 5));
    expect(unlockLockoutFor(50), const Duration(minutes: 5));
  });

  test('failed unlock schedules a lockout', () async {
    final svc = _FakeVaultService();
    final container = ProviderContainer(
      overrides: [vaultServiceProvider.overrideWithValue(svc)],
    );
    addTearDown(container.dispose);

    await container.read(vaultUnlockProvider.notifier).unlockWithPin('1234');

    final state = container.read(vaultUnlockProvider);
    expect(state.failureStreak, 1);
    expect(state.lockedUntil, isNotNull);
    final until = state.lockedUntil;
    expect(until != null && DateTime.now().isBefore(until), isTrue);
  });

  test('attempts made while locked never reach the vault service', () async {
    final svc = _FakeVaultService();
    final container = ProviderContainer(
      overrides: [vaultServiceProvider.overrideWithValue(svc)],
    );
    addTearDown(container.dispose);
    // Keep the auto-dispose provider alive for the whole test.
    container.listen(vaultUnlockProvider, (_, _) {});
    final notifier = container.read(vaultUnlockProvider.notifier);

    await notifier.unlockWithPin('1234');
    expect(svc.unlockCalls, 1);

    // Still inside the lockout window from the first failure.
    await notifier.unlockWithPin('0000');
    expect(svc.unlockCalls, 1);
    expect(
      container.read(vaultUnlockProvider).failureStreak,
      1,
      reason: 'blocked attempts must not escalate the lockout',
    );

    // Once the lockout has elapsed the attempt goes through again.
    await Future<void>.delayed(unlockLockoutFor(1));
    await notifier.unlockWithPin('0000');
    expect(svc.unlockCalls, 2);
    expect(container.read(vaultUnlockProvider).failureStreak, 2);
  });
}
