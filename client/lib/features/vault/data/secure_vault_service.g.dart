// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_vault_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(secureVaultService)
final secureVaultServiceProvider = SecureVaultServiceProvider._();

final class SecureVaultServiceProvider
    extends $FunctionalProvider<VaultService, VaultService, VaultService>
    with $Provider<VaultService> {
  SecureVaultServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureVaultServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureVaultServiceHash();

  @$internal
  @override
  $ProviderElement<VaultService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VaultService create(Ref ref) {
    return secureVaultService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VaultService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VaultService>(value),
    );
  }
}

String _$secureVaultServiceHash() =>
    r'0b388696731b5129f35c91a26e6f2b94a6fff184';
