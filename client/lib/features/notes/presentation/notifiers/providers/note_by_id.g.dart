// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_by_id.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(noteById)
final noteByIdProvider = NoteByIdFamily._();

final class NoteByIdProvider extends $FunctionalProvider<Note?, Note?, Note?>
    with $Provider<Note?> {
  NoteByIdProvider._({
    required NoteByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'noteByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$noteByIdHash();

  @override
  String toString() {
    return r'noteByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Note?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Note? create(Ref ref) {
    final argument = this.argument as String;
    return noteById(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Note? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Note?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NoteByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$noteByIdHash() => r'8da31929184dacc1533f8ca386adb3bc0a40cf2e';

final class NoteByIdFamily extends $Family
    with $FunctionalFamilyOverride<Note?, String> {
  NoteByIdFamily._()
    : super(
        retry: null,
        name: r'noteByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NoteByIdProvider call(String id) =>
      NoteByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'noteByIdProvider';
}
