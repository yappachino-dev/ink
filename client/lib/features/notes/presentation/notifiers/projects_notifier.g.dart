// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projects_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProjectsNotifier)
final projectsProvider = ProjectsNotifierProvider._();

final class ProjectsNotifierProvider
    extends $AsyncNotifierProvider<ProjectsNotifier, List<Project>> {
  ProjectsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectsNotifierHash();

  @$internal
  @override
  ProjectsNotifier create() => ProjectsNotifier();
}

String _$projectsNotifierHash() => r'f1382c0662b9c64c9c0ba75f0039bbcc182b2bea';

abstract class _$ProjectsNotifier extends $AsyncNotifier<List<Project>> {
  FutureOr<List<Project>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Project>>, List<Project>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Project>>, List<Project>>,
              AsyncValue<List<Project>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
