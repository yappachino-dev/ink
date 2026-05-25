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

String _$projectsNotifierHash() => r'9ba2bd7036a28db853523f9736a4e49d0dbd88c1';

abstract class _$ProjectsNotifier extends $AsyncNotifier<List<Project>> {
  FutureOr<List<Project>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Project>>, List<Project>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Project>>, List<Project>>,
              AsyncValue<List<Project>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
