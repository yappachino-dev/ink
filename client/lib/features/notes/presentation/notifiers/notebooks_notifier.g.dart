// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notebooks_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotebooksNotifier)
final notebooksProvider = NotebooksNotifierProvider._();

final class NotebooksNotifierProvider
    extends $AsyncNotifierProvider<NotebooksNotifier, List<Notebook>> {
  NotebooksNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notebooksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notebooksNotifierHash();

  @$internal
  @override
  NotebooksNotifier create() => NotebooksNotifier();
}

String _$notebooksNotifierHash() => r'10aea73fc0a834490cdab1dc4ffa44a759fc599d';

abstract class _$NotebooksNotifier extends $AsyncNotifier<List<Notebook>> {
  FutureOr<List<Notebook>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Notebook>>, List<Notebook>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Notebook>>, List<Notebook>>,
              AsyncValue<List<Notebook>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
