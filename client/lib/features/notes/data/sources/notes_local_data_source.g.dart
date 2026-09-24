// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_local_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notesLocalDataSource)
final notesLocalDataSourceProvider = NotesLocalDataSourceProvider._();

final class NotesLocalDataSourceProvider
    extends
        $FunctionalProvider<
          NotesLocalDataSource,
          NotesLocalDataSource,
          NotesLocalDataSource
        >
    with $Provider<NotesLocalDataSource> {
  NotesLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notesLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notesLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<NotesLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotesLocalDataSource create(Ref ref) {
    return notesLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotesLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotesLocalDataSource>(value),
    );
  }
}

String _$notesLocalDataSourceHash() =>
    r'f207b09e8f2c43681c5a77ed6110d5bbe8a3f634';
