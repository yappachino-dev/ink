// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notebooks_local_store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notebooksLocalStore)
final notebooksLocalStoreProvider = NotebooksLocalStoreProvider._();

final class NotebooksLocalStoreProvider
    extends
        $FunctionalProvider<
          NotebooksLocalStore,
          NotebooksLocalStore,
          NotebooksLocalStore
        >
    with $Provider<NotebooksLocalStore> {
  NotebooksLocalStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notebooksLocalStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notebooksLocalStoreHash();

  @$internal
  @override
  $ProviderElement<NotebooksLocalStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotebooksLocalStore create(Ref ref) {
    return notebooksLocalStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotebooksLocalStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotebooksLocalStore>(value),
    );
  }
}

String _$notebooksLocalStoreHash() =>
    r'c9c7f1ba39aea0f8c7f4c295b0d8901a7046060e';
