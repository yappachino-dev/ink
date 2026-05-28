// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncClient)
final syncClientProvider = SyncClientProvider._();

final class SyncClientProvider
    extends $FunctionalProvider<SyncClient, SyncClient, SyncClient>
    with $Provider<SyncClient> {
  SyncClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncClientHash();

  @$internal
  @override
  $ProviderElement<SyncClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncClient create(Ref ref) {
    return syncClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncClient>(value),
    );
  }
}

String _$syncClientHash() => r'25a94f1fe7e9c1155051e33f9ec421eedb0eff3f';
