import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:bip39/bip39.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';
import 'package:ink/features/vault/domain/vault_providers.dart';
import 'package:ink/features/vault/domain/vault_service.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_setup_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'build creates a valid recovery phrase and three sorted word indices',
    () {
      final container = ProviderContainer(
        overrides: [
          vaultRandomServiceProvider.overrideWithValue(_FixedRandomService()),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(vaultSetupProvider);

      expect(state.generatedRecoveryPhrase, hasLength(12));
      expect(validateMnemonic(state.generatedRecoveryPhrase.join(' ')), isTrue);
      expect(state.verifyIndices, hasLength(3));
      expect(state.verifyIndices.toSet(), hasLength(3));
      expect(
        state.verifyIndices,
        orderedEquals([...state.verifyIndices]..sort()),
      );
      expect(
        state.verifyIndices.every((index) => index >= 0 && index < 12),
        isTrue,
      );
    },
  );

  test('setup methods select a key type and store the temporary secret', () {
    final container = ProviderContainer(
      overrides: [
        vaultRandomServiceProvider.overrideWithValue(_FixedRandomService()),
      ],
    );
    addTearDown(container.dispose);
    container.listen(vaultSetupProvider, (_, _) {});
    final notifier = container.read(vaultSetupProvider.notifier)
      ..setupPin('1234');
    var state = container.read(vaultSetupProvider);
    expect(state.selectedType, KeyType.pin);
    expect(state.temporarySecret, '1234');

    notifier.setupPattern([0, 1, 3, 6]);
    state = container.read(vaultSetupProvider);
    expect(state.selectedType, KeyType.pattern);
    expect(state.temporarySecret, '0136');
  });

  test('phrase verification trims and normalizes user input', () {
    final container = ProviderContainer(
      overrides: [
        vaultRandomServiceProvider.overrideWithValue(_FixedRandomService()),
      ],
    );
    addTearDown(container.dispose);
    container.listen(vaultSetupProvider, (_, _) {});
    final notifier = container.read(vaultSetupProvider.notifier);
    final state = container.read(vaultSetupProvider);
    final inputs = [
      for (final index in state.verifyIndices)
        state.generatedRecoveryPhrase[index].toUpperCase(),
    ];

    expect(
      notifier.verifyPhrase(inputs.map((word) => ' $word ').toList()),
      isTrue,
    );
    inputs[0] = 'wrong';
    expect(notifier.verifyPhrase(inputs), isFalse);
  });

  test(
    'commit guards duplicate submissions and passes both vault secrets',
    () async {
      final service = _FakeVaultService();
      final container = ProviderContainer(
        overrides: [
          vaultServiceProvider.overrideWithValue(service),
          vaultRandomServiceProvider.overrideWithValue(_FixedRandomService()),
        ],
      );
      addTearDown(container.dispose);
      container.listen(vaultSetupProvider, (_, _) {});
      final notifier = container.read(vaultSetupProvider.notifier)
        ..setupPin('1234');

      final firstCommit = notifier.commitSetup();
      expect(container.read(vaultSetupProvider).isSubmitting, isTrue);
      await notifier.commitSetup();
      expect(service.initializeCalls, 1);

      final expectedPhrase = container
          .read(vaultSetupProvider)
          .generatedRecoveryPhrase
          .join();
      service.complete(const Success(null));
      await firstCommit;
      expect(service.lastSecrets, {
        KeyType.pin: '1234',
        KeyType.recoveryPhrase: expectedPhrase,
      });
    },
  );

  test('commit exposes failure and allows a clean retry', () async {
    final service = _FakeVaultService();
    final container = ProviderContainer(
      overrides: [
        vaultServiceProvider.overrideWithValue(service),
        vaultRandomServiceProvider.overrideWithValue(_FixedRandomService()),
      ],
    );
    addTearDown(container.dispose);
    container.listen(vaultSetupProvider, (_, _) {});
    final notifier = container.read(vaultSetupProvider.notifier)
      ..setupPattern([0, 1, 3, 6]);

    final firstCommit = notifier.commitSetup();
    service.complete(const Failure(VaultNotInitialized()));
    await firstCommit;

    var state = container.read(vaultSetupProvider);
    expect(state.isSubmitting, isFalse);
    expect(state.failure, const VaultNotInitialized());

    notifier.setupPattern([0, 2, 4, 7]);
    state = container.read(vaultSetupProvider);
    expect(state.failure, isNull);

    final retry = notifier.commitSetup();
    service.complete(const Success(null));
    await retry;
    expect(service.initializeCalls, 2);
  });
}

class _FixedRandomService implements VaultRandomService {
  @override
  Uint8List generateBytes(int length) => Uint8List(length);
}

class _FakeVaultService implements VaultService {
  final _pendingInitializations =
      Queue<Completer<Result<void, VaultFailure>>>();

  int initializeCalls = 0;
  Map<KeyType, String>? lastSecrets;

  void complete(Result<void, VaultFailure> result) {
    _pendingInitializations.removeFirst().complete(result);
  }

  @override
  Future<Result<void, VaultFailure>> intializeNewVault(
    Map<KeyType, String> initialSecrets,
  ) {
    final completer = Completer<Result<void, VaultFailure>>();
    _pendingInitializations.add(completer);
    initializeCalls++;
    lastSecrets = Map.of(initialSecrets);
    return completer.future;
  }

  @override
  Future<Result<List<KeyType>, VaultFailure>> getUnlockMethods() async =>
      const Success([]);

  @override
  Future<Result<void, VaultFailure>> pullKeys() async => const Success(null);

  @override
  Future<Result<void, VaultFailure>> pushKeys() async => const Success(null);

  @override
  Future<Result<void, VaultFailure>> unlock(
    KeyType type,
    String secret,
  ) async => const Success(null);
}
