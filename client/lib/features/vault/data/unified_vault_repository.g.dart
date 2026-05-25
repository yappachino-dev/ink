// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_vault_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(vaultRepository)
final vaultRepositoryProvider = VaultRepositoryProvider._();

final class VaultRepositoryProvider
    extends
        $FunctionalProvider<VaultRepository, VaultRepository, VaultRepository>
    with $Provider<VaultRepository> {
  VaultRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vaultRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vaultRepositoryHash();

  @$internal
  @override
  $ProviderElement<VaultRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VaultRepository create(Ref ref) {
    return vaultRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VaultRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VaultRepository>(value),
    );
  }
}

String _$vaultRepositoryHash() => r'1bca5f9b52c4f033575473c4187060af5d220b49';
