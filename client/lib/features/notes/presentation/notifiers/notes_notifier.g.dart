// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotesNotifier)
final notesProvider = NotesNotifierProvider._();

final class NotesNotifierProvider
    extends $AsyncNotifierProvider<NotesNotifier, Map<String, Note>> {
  NotesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notesNotifierHash();

  @$internal
  @override
  NotesNotifier create() => NotesNotifier();
}

String _$notesNotifierHash() => r'6bd4069267c995dd70ac86ccafcef0e216279fee';

abstract class _$NotesNotifier extends $AsyncNotifier<Map<String, Note>> {
  FutureOr<Map<String, Note>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Map<String, Note>>, Map<String, Note>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Map<String, Note>>, Map<String, Note>>,
              AsyncValue<Map<String, Note>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
