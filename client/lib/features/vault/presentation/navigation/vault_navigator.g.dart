// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_navigator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(vaultNavigator)
final vaultNavigatorProvider = VaultNavigatorProvider._();

final class VaultNavigatorProvider
    extends $FunctionalProvider<VaultNavigator, VaultNavigator, VaultNavigator>
    with $Provider<VaultNavigator> {
  VaultNavigatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vaultNavigatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vaultNavigatorHash();

  @$internal
  @override
  $ProviderElement<VaultNavigator> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VaultNavigator create(Ref ref) {
    return vaultNavigator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VaultNavigator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VaultNavigator>(value),
    );
  }
}

String _$vaultNavigatorHash() => r'f980fb76321829f89f89642fcaa43b1f44450af9';
