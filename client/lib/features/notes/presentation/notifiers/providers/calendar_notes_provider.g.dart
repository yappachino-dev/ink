// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The notes written on the selected calendar day.
///
/// The calendar is a date index: it answers "what did I write on this day", so it
/// keys on `createdAt` and on nothing else. It deliberately does not key on
/// `dueDate`: the due-date axis belongs to the Today and Overdue views, and
/// marking a day for both would make one dot ambiguous between "written here"
/// and "due here".
///
/// Notebook scope is not a second axis here. Filtering by notebook made the
/// journal a filtered copy of Notes under different chrome, and forced the
/// navigation shell to clear the selection on tab entry. Notebooks stay a Notes
/// lens, reachable from its drawer.
///
/// Back-dating is not supported. A note written today lands on today; if that
/// changes, the key becomes a user-assignable entry-date column.

@ProviderFor(calendarNotes)
final calendarNotesProvider = CalendarNotesProvider._();

/// The notes written on the selected calendar day.
///
/// The calendar is a date index: it answers "what did I write on this day", so it
/// keys on `createdAt` and on nothing else. It deliberately does not key on
/// `dueDate`: the due-date axis belongs to the Today and Overdue views, and
/// marking a day for both would make one dot ambiguous between "written here"
/// and "due here".
///
/// Notebook scope is not a second axis here. Filtering by notebook made the
/// journal a filtered copy of Notes under different chrome, and forced the
/// navigation shell to clear the selection on tab entry. Notebooks stay a Notes
/// lens, reachable from its drawer.
///
/// Back-dating is not supported. A note written today lands on today; if that
/// changes, the key becomes a user-assignable entry-date column.

final class CalendarNotesProvider
    extends $FunctionalProvider<List<Note>, List<Note>, List<Note>>
    with $Provider<List<Note>> {
  /// The notes written on the selected calendar day.
  ///
  /// The calendar is a date index: it answers "what did I write on this day", so it
  /// keys on `createdAt` and on nothing else. It deliberately does not key on
  /// `dueDate`: the due-date axis belongs to the Today and Overdue views, and
  /// marking a day for both would make one dot ambiguous between "written here"
  /// and "due here".
  ///
  /// Notebook scope is not a second axis here. Filtering by notebook made the
  /// journal a filtered copy of Notes under different chrome, and forced the
  /// navigation shell to clear the selection on tab entry. Notebooks stay a Notes
  /// lens, reachable from its drawer.
  ///
  /// Back-dating is not supported. A note written today lands on today; if that
  /// changes, the key becomes a user-assignable entry-date column.
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

String _$calendarNotesHash() => r'f655b657f78c2d0097c2645190a32a0b033fffc3';

/// Days in the visible range that hold at least one entry.
///
/// Precomputed per range rather than filtering the whole note set for each cell
/// the grid paints, which `TableCalendar` asks for on every visible day.
///
/// Keys are `DateUtils.dateOnly` of the stored timestamp, which reads the
/// recorded year/month/day and returns local midnight. `DateTime.==` compares the
/// instant *and* the `isUtc` flag, so a raw lookup would miss whenever the two
/// sides disagreed on either.
///
/// Deliberately **not** `.toLocal()`. Converting to the device zone first would
/// re-date an entry whenever the stored time sits near midnight, so the same
/// note would land on different days on different devices, and would move days
/// if the user travelled. A journal records the day as written.

@ProviderFor(journalEntryCounts)
final journalEntryCountsProvider = JournalEntryCountsProvider._();

/// Days in the visible range that hold at least one entry.
///
/// Precomputed per range rather than filtering the whole note set for each cell
/// the grid paints, which `TableCalendar` asks for on every visible day.
///
/// Keys are `DateUtils.dateOnly` of the stored timestamp, which reads the
/// recorded year/month/day and returns local midnight. `DateTime.==` compares the
/// instant *and* the `isUtc` flag, so a raw lookup would miss whenever the two
/// sides disagreed on either.
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
  /// Precomputed per range rather than filtering the whole note set for each cell
  /// the grid paints, which `TableCalendar` asks for on every visible day.
  ///
  /// Keys are `DateUtils.dateOnly` of the stored timestamp, which reads the
  /// recorded year/month/day and returns local midnight. `DateTime.==` compares the
  /// instant *and* the `isUtc` flag, so a raw lookup would miss whenever the two
  /// sides disagreed on either.
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
    r'8ab086da999b67609b117f4a98e259a1d7e30271';
