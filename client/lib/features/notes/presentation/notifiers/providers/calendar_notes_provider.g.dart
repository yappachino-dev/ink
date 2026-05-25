// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(calendarNotes)
final calendarNotesProvider = CalendarNotesProvider._();

final class CalendarNotesProvider
    extends $FunctionalProvider<List<Note>, List<Note>, List<Note>>
    with $Provider<List<Note>> {
  CalendarNotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarNotesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarNotesHash();

  @$internal
  @override
  $ProviderElement<List<Note>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Note> create(Ref ref) {
    return calendarNotes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Note> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Note>>(value),
    );
  }
}

String _$calendarNotesHash() => r'68b004693fd4f9c807a25bf2c512d4636442415b';

@ProviderFor(activeCalendarNotes)
final activeCalendarNotesProvider = ActiveCalendarNotesProvider._();

final class ActiveCalendarNotesProvider
    extends $FunctionalProvider<List<Note>, List<Note>, List<Note>>
    with $Provider<List<Note>> {
  ActiveCalendarNotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeCalendarNotesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeCalendarNotesHash();

  @$internal
  @override
  $ProviderElement<List<Note>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Note> create(Ref ref) {
    return activeCalendarNotes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Note> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Note>>(value),
    );
  }
}

String _$activeCalendarNotesHash() =>
    r'ad0a3844848cf1e2b0009ea63d32565ef613af1b';

@ProviderFor(completedCalendarNotes)
final completedCalendarNotesProvider = CompletedCalendarNotesProvider._();

final class CompletedCalendarNotesProvider
    extends $FunctionalProvider<List<Note>, List<Note>, List<Note>>
    with $Provider<List<Note>> {
  CompletedCalendarNotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completedCalendarNotesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completedCalendarNotesHash();

  @$internal
  @override
  $ProviderElement<List<Note>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Note> create(Ref ref) {
    return completedCalendarNotes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Note> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Note>>(value),
    );
  }
}

String _$completedCalendarNotesHash() =>
    r'92bc9458f03a32918088f9d93134f3c445013405';
