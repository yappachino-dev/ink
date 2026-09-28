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

String _$noteFormNotifierHash() => r'757f8c5fa4d5e17c3f02cc31957043b7d2dc6dc7';

abstract class _$NoteFormNotifier extends $Notifier<NoteDraftState> {
  NoteDraftState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NoteDraftState, NoteDraftState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NoteDraftState, NoteDraftState>,
              NoteDraftState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
