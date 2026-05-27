// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_vault_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(vaultService)
final vaultServiceProvider = VaultServiceProvider._();

final class VaultServiceProvider
    extends $FunctionalProvider<VaultService, VaultService, VaultService>
    with $Provider<VaultService> {
  VaultServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vaultServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vaultServiceHash();

  @$internal
  @override
  $ProviderElement<VaultService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VaultService create(Ref ref) {
    return vaultService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VaultService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VaultService>(value),
    );
  }
}

String _$vaultServiceHash() => r'44054d0f4a6854f9e6d0a41220809368c8f56d67';
