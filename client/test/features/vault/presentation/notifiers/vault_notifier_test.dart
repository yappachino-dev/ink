import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/features/vault/domain/vault_providers.dart';
import 'package:ink/features/vault/domain/vault_service.dart';
import 'package:ink/features/vault/domain/vault_state.dart';
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
