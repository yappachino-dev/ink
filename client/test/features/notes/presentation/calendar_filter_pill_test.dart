// The filter pill's "x" used to be an Icon inside the same InkWell as the
// label, so tapping it opened the notebook picker instead of clearing the
// filter - the opposite of what an x means on a chip anywhere else. It was
// also inside `excludeSemantics`, so a screen reader never learned the two
// regions differed.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/screens/calendar_screen.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/list_filter_sheet.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_helpers.dart';

class _Svc extends Mock implements NotesService {}

final _day = DateTime(2026, 3, 14);
const _work = 'nb_work';

Notebook _notebook(String id, String title) => Notebook(
  id: id,
  title: title,
  emoji: 'book',
  colorValue: 0,
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: SyncStatus.synced,
  createdAt: _day,
  updatedAt: _day,
);

void main() {
  Future<ProviderContainer> pumpCalendar(
    WidgetTester tester, {
    required String initial,
  }) async {
    final svc = _Svc();
    when(
      svc.getAllNotes,
    ).thenAnswer((_) async => const Success<List<Note>, NotesFailure>([]));
    when(svc.getAllNotebooks).thenAnswer(
      (_) async =>
          Success<List<Notebook>, NotesFailure>([_notebook(_work, 'Work')]),
    );

    final container = ProviderContainer(
      overrides: [
        notesServiceProvider.overrideWithValue(svc),
        userPreferencesProvider.overrideWithValue(await mockUserConfig()),
        currentDateProvider.overrideWithValue(_day),
      ],
    );
    addTearDown(container.dispose);
    container.read(selectedNotebookIdProvider.notifier).id = initial;
    await container.read(notesProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppTheme.light(InkPalette.forest),
            home: const Scaffold(body: CalendarScreen()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('the x clears the filter instead of opening the picker', (
    tester,
  ) async {
    final container = await pumpCalendar(tester, initial: _work);

    expect(container.read(selectedNotebookIdProvider), _work);
    expect(find.byType(ListFilterSheet), findsNothing);

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();

    expect(
      container.read(selectedNotebookIdProvider),
      allNotebooksId,
      reason: 'the x means stop filtering',
    );
    expect(
      find.byType(ListFilterSheet),
      findsNothing,
      reason: 'clearing must not open the picker - that was the defect',
    );
  });

  testWidgets('the label still opens the picker', (tester) async {
    final container = await pumpCalendar(tester, initial: _work);

    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();

    expect(container.read(selectedNotebookIdProvider), _work);
    expect(find.byType(ListFilterSheet), findsOneWidget);
  });

  testWidgets('there is no x to tap when nothing is filtered', (tester) async {
    await pumpCalendar(tester, initial: allNotebooksId);

    // The label still reads, so the pill stays reachable, but there is nothing
    // to clear and so nothing to offer. The unfiltered label is
    // `calendar.filter`, not a notebook name.
    expect(find.text('Filter'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('the x and the label are separate nodes to a screen reader', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpCalendar(tester, initial: _work);

    expect(
      find.bySemanticsLabel('Clear notebook filter'),
      findsOneWidget,
      reason:
          'the x has to be announced as its own action, or the two '
          'regions are indistinguishable',
    );

    handle.dispose();
  });

  testWidgets('the x is a full-size touch target', (tester) async {
    await pumpCalendar(tester, initial: _work);

    final size = tester.getSize(find.bySemanticsLabel('Clear notebook filter'));

    // 48 is Material's floor and Apple's is 44. A 14dp icon in 6dp of padding
    // is about 28, which is both below the floor and narrow enough that a miss
    // lands on the label and opens the picker - the exact defect this replaced,
    // so a regression here is a regression to a broken control.
    expect(size.width, greaterThanOrEqualTo(44));
    expect(size.height, greaterThanOrEqualTo(44));
  });

  testWidgets('the pill clips its ink to the rounded corners', (tester) async {
    await pumpCalendar(tester, initial: _work);

    // A `BorderRadius` on a decoration does not clip: the ripple from the
    // label, and from the x on the right edge where the rounding is most
    // visible, runs square over the corners unless something clips it.
    final material = tester.widget<Material>(
      find
          .ancestor(
            of: find.bySemanticsLabel('Clear notebook filter'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.clipBehavior, Clip.antiAlias);
  });
}
