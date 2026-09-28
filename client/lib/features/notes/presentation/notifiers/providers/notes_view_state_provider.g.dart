// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_view_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notesViewState)
final notesViewStateProvider = NotesViewStateProvider._();

final class NotesViewStateProvider
    extends $FunctionalProvider<NotesViewState, NotesViewState, NotesViewState>
    with $Provider<NotesViewState> {
  NotesViewStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notesViewStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notesViewStateHash();

  @$internal
  @override
  $ProviderElement<NotesViewState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotesViewState create(Ref ref) {
    return notesViewState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotesViewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotesViewState>(value),
    );
  }
}

String _$notesViewStateHash() => r'0dc108bc2901da6011bb80659f9dff54693c24e3';
