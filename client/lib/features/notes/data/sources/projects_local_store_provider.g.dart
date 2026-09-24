// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projects_local_store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(projectsLocalStore)
final projectsLocalStoreProvider = ProjectsLocalStoreProvider._();

final class ProjectsLocalStoreProvider
    extends
        $FunctionalProvider<
          ProjectsLocalStore,
          ProjectsLocalStore,
          ProjectsLocalStore
        >
    with $Provider<ProjectsLocalStore> {
  ProjectsLocalStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectsLocalStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectsLocalStoreHash();

  @$internal
  @override
  $ProviderElement<ProjectsLocalStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProjectsLocalStore create(Ref ref) {
    return projectsLocalStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProjectsLocalStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProjectsLocalStore>(value),
    );
  }
}

String _$projectsLocalStoreHash() =>
    r'd9580ee13f872ac858ec8c23425002a88c640940';
