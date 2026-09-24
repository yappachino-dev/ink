import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/vault/domain/vault_service.dart';

/// Source of cryptographically secure random bytes used during vault setup.
// ignore: one_member_abstracts
abstract interface class VaultRandomService {
  Uint8List generateBytes(int length);
}

/// Read-only session state needed by the vault presentation layer.
abstract interface class VaultSessionStatus {
  bool get isLoaded;
  bool get hasAccessToken;
  bool get hasMasterKey;
}

/// Recovery operation for the fatal vault state.
// ignore: one_member_abstracts
abstract interface class VaultRecovery {
  Future<void> reset();
}

/// Domain-facing vault service dependency.
///
/// The concrete service is wired by the application composition root in
/// `app/init.dart`; presentation code only depends on this contract.
final vaultServiceProvider = Provider<VaultService>(
  (ref) => throw StateError(
    'vaultServiceProvider must be overridden at the app root',
  ),
);

/// Domain-facing random source dependency used to create recovery phrases.
///
/// The concrete CSPRNG is wired by the application composition root.
final vaultRandomServiceProvider = Provider<VaultRandomService>(
  (ref) => throw StateError(
    'vaultRandomServiceProvider must be overridden at the app root',
  ),
);

/// Domain-facing session state for the vault notifier.
final vaultSessionStatusProvider = Provider<VaultSessionStatus>(
  (ref) => throw StateError(
    'vaultSessionStatusProvider must be overridden at the app root',
  ),
);

/// Domain-facing recovery operation for the fatal vault screen.
final vaultRecoveryProvider = Provider<VaultRecovery>(
  (ref) => throw StateError(
    'vaultRecoveryProvider must be overridden at the app root',
  ),
);
