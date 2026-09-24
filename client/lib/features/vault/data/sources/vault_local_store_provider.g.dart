// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_local_store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(vaultLocalStore)
final vaultLocalStoreProvider = VaultLocalStoreProvider._();

final class VaultLocalStoreProvider
    extends
        $FunctionalProvider<VaultLocalStore, VaultLocalStore, VaultLocalStore>
    with $Provider<VaultLocalStore> {
  VaultLocalStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vaultLocalStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vaultLocalStoreHash();

  @$internal
  @override
  $ProviderElement<VaultLocalStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VaultLocalStore create(Ref ref) {
    return vaultLocalStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VaultLocalStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VaultLocalStore>(value),
    );
  }
}

String _$vaultLocalStoreHash() => r'7e98807ec938398ee918e1f0a69c47a5b5149619';
