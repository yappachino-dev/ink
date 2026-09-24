import 'package:bip39/bip39.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';
import 'package:ink/features/vault/domain/vault_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vault_setup_notifier.g.dart';
part 'vault_setup_notifier.freezed.dart';

@freezed
sealed class VaultSetupData with _$VaultSetupData {
  const factory VaultSetupData({
    required List<String> generatedRecoveryPhrase,
    required List<int> verifyIndices,

    KeyType? selectedType,
    String? temporarySecret,

    @Default(false) bool isSubmitting,
    VaultFailure? failure,
  }) = _VaultSetupData;
}

@riverpod
class VaultSetup extends _$VaultSetup {
  KeepAliveLink? _link;

  @override
  VaultSetupData build() {
    _link = ref.keepAlive();

    final recoveryPhrase = generateMnemonic(
      randomBytes: ref.read(vaultRandomServiceProvider).generateBytes,
    );

    return VaultSetupData(
      generatedRecoveryPhrase: recoveryPhrase.split(' '),
      verifyIndices: _generateIndices(),
    );
  }

  List<int> _generateIndices() {
    final list = List<int>.generate(12, (i) => i)..shuffle();
    final indices = list.take(3).toList()..sort();

    return indices;
  }

  void abortFlow() {
    _link?.close();
    ref.invalidateSelf();
  }

  void setupPin(String secret) => state = state.copyWith(
    selectedType: KeyType.pin,
    temporarySecret: secret,
    failure: null,
  );

  void setupPattern(List<int> secret) => state = state.copyWith(
    selectedType: KeyType.pattern,
    temporarySecret: secret.join(),
    failure: null,
  );

  bool verifyPhrase(List<String> userInputs) {
    for (var i = 0; i < state.verifyIndices.length; i++) {
      final index = state.verifyIndices[i];
      if (userInputs[i].trim().toLowerCase() !=
          state.generatedRecoveryPhrase[index].toLowerCase()) {
        return false;
      }
    }

    return true;
  }

  Future<void> commitSetup() async {
    final type = state.selectedType;
    final secret = state.temporarySecret;
    final recoveryPhrase = state.generatedRecoveryPhrase;

    if (type == null || secret == null || state.isSubmitting) {
      return;
    }

    state = state.copyWith(isSubmitting: true, failure: null);

    final recoveryString = recoveryPhrase.join();
    final secrets = {type: secret, KeyType.recoveryPhrase: recoveryString};

    final result = await ref
        .read(vaultServiceProvider)
        .intializeNewVault(secrets);

    result.fold(
      (success) => _completeFlow(),
      (failure) =>
          state = state.copyWith(isSubmitting: false, failure: failure),
    );
  }

  void _completeFlow() {
    _link?.close();
    ref.invalidateSelf();
  }
}
