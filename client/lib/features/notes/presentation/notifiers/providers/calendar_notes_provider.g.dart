// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The notes written on the selected calendar day.
///
/// The calendar is a journal: it answers "what did I write on this day", so it
/// keys on `createdAt`. It deliberately does not key on `dueDate`: the due-date
/// axis belongs to the Today and Overdue views, and marking a day for both
/// would make one dot ambiguous between "written here" and "due here".
///
/// Back-dating is not supported yet. A note written today lands on today.
/// If that turns out to matter, the key becomes a user-assignable entry-date
/// column rather than a change of approach, which is why the date should be
/// readable as a column and not hardcoded to the entity.

@ProviderFor(calendarNotes)
final calendarNotesProvider = CalendarNotesProvider._();

/// The notes written on the selected calendar day.
///
/// The calendar is a journal: it answers "what did I write on this day", so it
/// keys on `createdAt`. It deliberately does not key on `dueDate`: the due-date
/// axis belongs to the Today and Overdue views, and marking a day for both
/// would make one dot ambiguous between "written here" and "due here".
///
/// Back-dating is not supported yet. A note written today lands on today.
/// If that turns out to matter, the key becomes a user-assignable entry-date
/// column rather than a change of approach, which is why the date should be
/// readable as a column and not hardcoded to the entity.

final class CalendarNotesProvider
    extends $FunctionalProvider<List<Note>, List<Note>, List<Note>>
    with $Provider<List<Note>> {
  /// The notes written on the selected calendar day.
  ///
  /// The calendar is a journal: it answers "what did I write on this day", so it
  /// keys on `createdAt`. It deliberately does not key on `dueDate`: the due-date
  /// axis belongs to the Today and Overdue views, and marking a day for both
  /// would make one dot ambiguous between "written here" and "due here".
  ///
  /// Back-dating is not supported yet. A note written today lands on today.
  /// If that turns out to matter, the key becomes a user-assignable entry-date
  /// column rather than a change of approach, which is why the date should be
  /// readable as a column and not hardcoded to the entity.
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

String _$calendarNotesHash() => r'23405dc47a040a9910ade2724479c52526247544';

/// Days in the visible range that hold at least one entry.
///
/// Precomputed per range rather than filtering the whole note set for each
/// cell the grid paints, which `TableCalendar` asks for on every visible day.
///
/// Keys are `DateUtils.dateOnly` of the stored timestamp, which reads the
/// recorded year/month/day and returns local midnight. `DateTime.==` compares
/// the instant *and* the `isUtc` flag, so a raw lookup would miss whenever the
/// two sides disagreed on either. Normalizing both sides to a local midnight
/// makes the comparison exact.
///
/// Deliberately **not** `.toLocal()`. Converting to the device zone first would
/// re-date an entry whenever the stored time sits near midnight, so the same
/// note would land on different days on different devices, and would move days
/// if the user travelled. A journal records the day as written.

@ProviderFor(journalEntryCounts)
final journalEntryCountsProvider = JournalEntryCountsProvider._();

/// Days in the visible range that hold at least one entry.
///
/// Precomputed per range rather than filtering the whole note set for each
/// cell the grid paints, which `TableCalendar` asks for on every visible day.
///
/// Keys are `DateUtils.dateOnly` of the stored timestamp, which reads the
/// recorded year/month/day and returns local midnight. `DateTime.==` compares
/// the instant *and* the `isUtc` flag, so a raw lookup would miss whenever the
/// two sides disagreed on either. Normalizing both sides to a local midnight
/// makes the comparison exact.
///
/// Deliberately **not** `.toLocal()`. Converting to the device zone first would
/// re-date an entry whenever the stored time sits near midnight, so the same
/// note would land on different days on different devices, and would move days
/// if the user travelled. A journal records the day as written.

final class JournalEntryCountsProvider
    extends
        $FunctionalProvider<
          Map<DateTime, int>,
          Map<DateTime, int>,
          Map<DateTime, int>
        >
    with $Provider<Map<DateTime, int>> {
  /// Days in the visible range that hold at least one entry.
  ///
  /// Precomputed per range rather than filtering the whole note set for each
  /// cell the grid paints, which `TableCalendar` asks for on every visible day.
  ///
  /// Keys are `DateUtils.dateOnly` of the stored timestamp, which reads the
  /// recorded year/month/day and returns local midnight. `DateTime.==` compares
  /// the instant *and* the `isUtc` flag, so a raw lookup would miss whenever the
  /// two sides disagreed on either. Normalizing both sides to a local midnight
  /// makes the comparison exact.
  ///
  /// Deliberately **not** `.toLocal()`. Converting to the device zone first would
  /// re-date an entry whenever the stored time sits near midnight, so the same
  /// note would land on different days on different devices, and would move days
  /// if the user travelled. A journal records the day as written.
  JournalEntryCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'journalEntryCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$journalEntryCountsHash();

  @$internal
  @override
  $ProviderElement<Map<DateTime, int>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<DateTime, int> create(Ref ref) {
    return journalEntryCounts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<DateTime, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<DateTime, int>>(value),
    );
  }
}

String _$journalEntryCountsHash() =>
    r'2be75cb1f041cbc16d72d4050a7719117c9081c1';
