// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_local_store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notesLocalStore)
final notesLocalStoreProvider = NotesLocalStoreProvider._();

final class NotesLocalStoreProvider
    extends
        $FunctionalProvider<NotesLocalStore, NotesLocalStore, NotesLocalStore>
    with $Provider<NotesLocalStore> {
  NotesLocalStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notesLocalStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notesLocalStoreHash();

  @$internal
  @override
  $ProviderElement<NotesLocalStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotesLocalStore create(Ref ref) {
    return notesLocalStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotesLocalStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotesLocalStore>(value),
    );
  }
}

String _$notesLocalStoreHash() => r'058b43d0267a757a62304ca44dc4fc474d75e29d';
