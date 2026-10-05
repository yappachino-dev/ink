// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_conflict_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Carries a vault conflict as a one-shot report rather than as [VaultState].
///
/// A refused key-slot push happens while the vault is unlocked and working, so
/// folding it into the lifecycle state would drop an unlocked device into
/// `VaultError` and leave it there. This holds the report on its own, which
/// the shell reads and clears.

@ProviderFor(VaultConflictNotifier)
final vaultConflictProvider = VaultConflictNotifierProvider._();

/// Carries a vault conflict as a one-shot report rather than as [VaultState].
///
/// A refused key-slot push happens while the vault is unlocked and working, so
/// folding it into the lifecycle state would drop an unlocked device into
/// `VaultError` and leave it there. This holds the report on its own, which
/// the shell reads and clears.
final class VaultConflictNotifierProvider
    extends $NotifierProvider<VaultConflictNotifier, VaultFailure?> {
  /// Carries a vault conflict as a one-shot report rather than as [VaultState].
  ///
  /// A refused key-slot push happens while the vault is unlocked and working, so
  /// folding it into the lifecycle state would drop an unlocked device into
  /// `VaultError` and leave it there. This holds the report on its own, which
  /// the shell reads and clears.
  VaultConflictNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vaultConflictProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vaultConflictNotifierHash();

  @$internal
  @override
  VaultConflictNotifier create() => VaultConflictNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VaultFailure? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VaultFailure?>(value),
    );
  }
}

String _$vaultConflictNotifierHash() =>
    r'3424d157bd1cba327ceb1c568312263600e16a7e';

/// Carries a vault conflict as a one-shot report rather than as [VaultState].
///
/// A refused key-slot push happens while the vault is unlocked and working, so
/// folding it into the lifecycle state would drop an unlocked device into
/// `VaultError` and leave it there. This holds the report on its own, which
/// the shell reads and clears.

abstract class _$VaultConflictNotifier extends $Notifier<VaultFailure?> {
  VaultFailure? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VaultFailure?, VaultFailure?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VaultFailure?, VaultFailure?>,
              VaultFailure?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
