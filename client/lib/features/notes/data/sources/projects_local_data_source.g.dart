// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projects_local_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(projectsLocalDataSource)
final projectsLocalDataSourceProvider = ProjectsLocalDataSourceProvider._();

final class ProjectsLocalDataSourceProvider
    extends
        $FunctionalProvider<
          ProjectsLocalDataSource,
          ProjectsLocalDataSource,
          ProjectsLocalDataSource
        >
    with $Provider<ProjectsLocalDataSource> {
  ProjectsLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectsLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectsLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<ProjectsLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProjectsLocalDataSource create(Ref ref) {
    return projectsLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProjectsLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProjectsLocalDataSource>(value),
    );
  }
}

String _$projectsLocalDataSourceHash() =>
    r'048e7233c82223863edbdd2ef133c6eaf740c3cc';
