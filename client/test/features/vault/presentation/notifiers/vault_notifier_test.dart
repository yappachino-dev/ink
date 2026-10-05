import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';
import 'package:ink/features/vault/domain/vault_providers.dart';
import 'package:ink/features/vault/domain/vault_service.dart';
import 'package:ink/features/vault/domain/vault_state.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_conflict_notifier.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_notifier.dart';
import 'package:mocktail/mocktail.dart';

class _MockVaultService extends Mock implements VaultService {}

class _FakeSessionStatus implements VaultSessionStatus {
  const _FakeSessionStatus({
    required this.isLoaded,
    this.hasLoadError = false,
    this.hasMasterKey = false,
  });

  @override
  final bool isLoaded;

  @override
  final bool hasLoadError;

  @override
  final bool hasMasterKey;

  @override
  bool get hasAccessToken => false;
}

void main() {
  ProviderContainer containerWith(VaultSessionStatus status) {
    final container = ProviderContainer(
      overrides: [
        vaultSessionStatusProvider.overrideWithValue(status),
        vaultServiceProvider.overrideWithValue(_MockVaultService()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('VaultNotifier.forcePushKeys', () {
    ProviderContainer containerFor(Result<void, VaultFailure> result) {
      final service = _MockVaultService();
      when(service.pushKeys).thenAnswer((_) async => result);
      final container = ProviderContainer(
        overrides: [
          vaultSessionStatusProvider.overrideWithValue(
            const _FakeSessionStatus(isLoaded: true, hasMasterKey: true),
          ),
          vaultServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('a refused push is reported on the conflict channel', () async {
      final container = containerFor(const Failure(VaultKeyConflict()));

      await container.read(vaultProvider.notifier).forcePushKeys();

      expect(container.read(vaultConflictProvider), isA<VaultKeyConflict>());
    });

    test('a refused push leaves the vault unlocked', () async {
      // The push runs while the vault works locally. Folding a sync warning
      // into the lifecycle state took the device out of VaultUnlocked and left
      // it there, since nothing rebuilds that state afterwards.
      final container = containerFor(const Failure(VaultKeyConflict()));

      await container.read(vaultProvider.notifier).forcePushKeys();

      expect(container.read(vaultProvider), isA<VaultUnlocked>());
    });

    test('a transient failure is not reported', () async {
      final container = containerFor(
        const Failure(VaultCoreFailure(NetworkFailure())),
      );

      await container.read(vaultProvider.notifier).forcePushKeys();

      expect(container.read(vaultConflictProvider), isNull);
      expect(container.read(vaultProvider), isA<VaultUnlocked>());
    });
  });

  group('VaultNotifier session gating', () {
    test('stays initializing until the session finishes loading', () {
      final container = containerWith(
        const _FakeSessionStatus(isLoaded: false),
      );

      expect(container.read(vaultProvider), isA<VaultInitializing>());
    });

    test('surfaces a failed token read instead of falling through', () {
      final container = containerWith(
        const _FakeSessionStatus(isLoaded: true, hasLoadError: true),
      );

      expect(container.read(vaultProvider), isA<VaultSessionLoadFailed>());
    });

    test('a load failure does not report an unlocked vault', () {
      final container = containerWith(
        const _FakeSessionStatus(
          isLoaded: true,
          hasLoadError: true,
          hasMasterKey: true,
        ),
      );

      expect(container.read(vaultProvider), isA<VaultSessionLoadFailed>());
    });
  });
}
