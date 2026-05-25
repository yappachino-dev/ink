// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncStorage)
final syncStorageProvider = SyncStorageProvider._();

final class SyncStorageProvider
    extends $FunctionalProvider<SyncStorage, SyncStorage, SyncStorage>
    with $Provider<SyncStorage> {
  SyncStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStorageHash();

  @$internal
  @override
  $ProviderElement<SyncStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncStorage create(Ref ref) {
    return syncStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncStorage>(value),
    );
  }
}

String _$syncStorageHash() => r'e492e2006aa7b8bb0074c9c25da61ce0b985d076';
