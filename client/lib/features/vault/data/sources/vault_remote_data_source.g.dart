// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(vaultRemoteDataSource)
final vaultRemoteDataSourceProvider = VaultRemoteDataSourceProvider._();

final class VaultRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          VaultRemoteDataSource,
          VaultRemoteDataSource,
          VaultRemoteDataSource
        >
    with $Provider<VaultRemoteDataSource> {
  VaultRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vaultRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vaultRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<VaultRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VaultRemoteDataSource create(Ref ref) {
    return vaultRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VaultRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VaultRemoteDataSource>(value),
    );
  }
}

String _$vaultRemoteDataSourceHash() =>
    r'b7d91af5ab5db1f9522401155c7dae5125ae3348';
