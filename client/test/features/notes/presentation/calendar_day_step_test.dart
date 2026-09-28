// Stepping a day with `DateTime.add(Duration(days: 1))` adds exactly 24 hours,
// which is not one day across a daylight-saving boundary.
//
// The provider is seeded from `DateTime.now()`, so the value carries a real
// time of day and the drift is reachable: in America/New_York, 00:30 on 1 Nov
// 2026 (a 25-hour day) plus 24 hours is 23:30 on the *same* day, so the button
// did nothing at all; and 23:30 on 7 Mar 2026 (a 23-hour day) plus 24 hours is
// 00:30 on the 9th, so it skipped a day.
//
// Both instants behave correctly under UTC, which is why a UTC test runner
// never saw the bug. These assertions hold in any zone, and running the file
// under a DST zone is what makes them bite:
//
//   TZ=America/New_York flutter test test/features/notes/presentation/\//     calendar_day_step_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/day_header.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

/// The instants the two failures live on, in a zone that observes DST:
/// the 25-hour day and the 23-hour day.
/// A calendar-day ordinal that DST cannot perturb.
///
/// `DateTime.difference` between two *local* midnights returns 25 hours
/// across a fall-back and 23 across a spring-forward, so asserting a one-day
/// difference is itself a DST bug - it fails on correct code. Both sides are
/// re-read in UTC, where no day is ever 23 or 25 hours long, and what is left
/// is a plain whole-day count.
int _dayOrdinal(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

const _fallBackDay = [2026, 11, 1, 0, 30];
const _springForwardDay = [2026, 3, 7, 23, 30];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<DateTime> stepFrom(
    WidgetTester tester,
    DateTime start,
    int days,
  ) async {
    final container = ProviderContainer(
      overrides: [currentDateProvider.overrideWithValue(start)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppTheme.light(InkPalette.forest),
            home: const Scaffold(body: DayHeader()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byTooltip(days > 0 ? t.calendar.nextDay : t.calendar.previousDay),
    );
    await tester.pumpAndSettle();

    return container.read(calendarSelectedDateProvider);
  }

  // One instant per test body: pumping the tree twice in a single body leaves
  // the first tree's timers pending, which the binding fails on.
  Future<void> assertStepsForward(WidgetTester tester, DateTime start) async {
    final after = await stepFrom(tester, start, 1);

    expect(
      _dayOrdinal(after) - _dayOrdinal(start),
      1,
      reason:
          'the date must advance by exactly one calendar day, not by '
          '24 hours',
    );
    // The state also becomes date-only, which is the better outcome: the
    // value is consumed as a day everywhere (`isSameDay` in the journal query,
    // `.day` in the header and the grid), so a canonical midnight makes it
    // comparable with `==` and stops a drifting time-of-day from mattering.
    expect(
      after.hour == 0 && after.minute == 0,
      isTrue,
      reason: 'the selected day should be stored as a canonical date',
    );
  }

  testWidgets('next clears the 25-hour fall-back day', (tester) async {
    await assertStepsForward(
      tester,
      DateTime(
        _fallBackDay[0],
        _fallBackDay[1],
        _fallBackDay[2],
        _fallBackDay[3],
        _fallBackDay[4],
      ),
    );
  });

  testWidgets('next does not skip the 23-hour spring-forward day', (
    tester,
  ) async {
    await assertStepsForward(
      tester,
      DateTime(
        _springForwardDay[0],
        _springForwardDay[1],
        _springForwardDay[2],
        _springForwardDay[3],
        _springForwardDay[4],
      ),
    );
  });

  testWidgets('previous lands on the previous calendar day', (tester) async {
    final start = DateTime(2026, 11, 1, 0, 30);
    final after = await stepFrom(tester, start, -1);

    expect(
      _dayOrdinal(after) - _dayOrdinal(start),
      -1,
      reason:
          'stepping back across the 25-hour day must still go back one '
          'calendar day, not stay put',
    );
  });
}
