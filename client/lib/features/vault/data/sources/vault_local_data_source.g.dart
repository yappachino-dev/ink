// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_local_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(vaultLocalDataSource)
final vaultLocalDataSourceProvider = VaultLocalDataSourceProvider._();

final class VaultLocalDataSourceProvider
    extends
        $FunctionalProvider<
          VaultLocalDataSource,
          VaultLocalDataSource,
          VaultLocalDataSource
        >
    with $Provider<VaultLocalDataSource> {
  VaultLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vaultLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vaultLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<VaultLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VaultLocalDataSource create(Ref ref) {
    return vaultLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VaultLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VaultLocalDataSource>(value),
    );
  }
}

String _$vaultLocalDataSourceHash() =>
    r'dbe9a186e45317544e352788274f2e1412466128';
