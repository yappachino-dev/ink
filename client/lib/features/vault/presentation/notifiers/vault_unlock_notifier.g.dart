// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_unlock_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VaultUnlock)
final vaultUnlockProvider = VaultUnlockProvider._();

final class VaultUnlockProvider
    extends $NotifierProvider<VaultUnlock, VaultUnlockData> {
  VaultUnlockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vaultUnlockProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vaultUnlockHash();

  @$internal
  @override
  VaultUnlock create() => VaultUnlock();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VaultUnlockData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VaultUnlockData>(value),
    );
  }
}

String _$vaultUnlockHash() => r'a98d859f3e216e3f8fbdffa266fbf71907eb81e5';

abstract class _$VaultUnlock extends $Notifier<VaultUnlockData> {
  VaultUnlockData build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VaultUnlockData, VaultUnlockData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VaultUnlockData, VaultUnlockData>,
              VaultUnlockData,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
