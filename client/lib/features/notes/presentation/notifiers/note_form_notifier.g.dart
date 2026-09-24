// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_form_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NoteFormNotifier)
final noteFormProvider = NoteFormNotifierProvider._();

final class NoteFormNotifierProvider
    extends $NotifierProvider<NoteFormNotifier, NoteDraftState> {
  NoteFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteFormNotifierHash();

  @$internal
  @override
  NoteFormNotifier create() => NoteFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteDraftState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteDraftState>(value),
    );
  }
}

String _$noteFormNotifierHash() => r'8c103222528e8cb24a99bbd36f73f3e4982a648d';

abstract class _$NoteFormNotifier extends $Notifier<NoteDraftState> {
  NoteDraftState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NoteDraftState, NoteDraftState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NoteDraftState, NoteDraftState>,
              NoteDraftState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
