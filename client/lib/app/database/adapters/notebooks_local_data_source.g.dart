// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notebooks_local_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notebooksLocalDataSource)
final notebooksLocalDataSourceProvider = NotebooksLocalDataSourceProvider._();

final class NotebooksLocalDataSourceProvider
    extends
        $FunctionalProvider<
          NotebooksLocalDataSource,
          NotebooksLocalDataSource,
          NotebooksLocalDataSource
        >
    with $Provider<NotebooksLocalDataSource> {
  NotebooksLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notebooksLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notebooksLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<NotebooksLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotebooksLocalDataSource create(Ref ref) {
    return notebooksLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotebooksLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotebooksLocalDataSource>(value),
    );
  }
}

String _$notebooksLocalDataSourceHash() =>
    r'376d4a4b6c353418a3a918d3d40a883c26ab4830';
