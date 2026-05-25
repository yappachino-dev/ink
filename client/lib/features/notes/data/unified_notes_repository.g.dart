// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_notes_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notesRepository)
final notesRepositoryProvider = NotesRepositoryProvider._();

final class NotesRepositoryProvider
    extends
        $FunctionalProvider<NotesRepository, NotesRepository, NotesRepository>
    with $Provider<NotesRepository> {
  NotesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notesRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotesRepository create(Ref ref) {
    return notesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotesRepository>(value),
    );
  }
}

String _$notesRepositoryHash() => r'b913ae592f752bdc86ed7e5d7e25c1b2398a0351';

@ProviderFor(unifiedNotesRepository)
final unifiedNotesRepositoryProvider = UnifiedNotesRepositoryProvider._();

final class UnifiedNotesRepositoryProvider
    extends
        $FunctionalProvider<
          UnifiedNotesRepository,
          UnifiedNotesRepository,
          UnifiedNotesRepository
        >
    with $Provider<UnifiedNotesRepository> {
  UnifiedNotesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unifiedNotesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unifiedNotesRepositoryHash();

  @$internal
  @override
  $ProviderElement<UnifiedNotesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UnifiedNotesRepository create(Ref ref) {
    return unifiedNotesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnifiedNotesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnifiedNotesRepository>(value),
    );
  }
}

String _$unifiedNotesRepositoryHash() =>
    r'b0954a5208e7d4bd30ae77f16fad97c0ef68c57f';
