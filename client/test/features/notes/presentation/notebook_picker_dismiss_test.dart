// The notebook picker is single-select with instant apply, so it has to close
// on selection. It did not: the write happened on tap, the check mark moved,
// and on a phone the only evidence of that was below the fold of a sheet
// covering most of the screen.
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
import 'package:ink/features/notes/presentation/widgets/calendar/list_filter_sheet.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_helpers.dart';

class _Svc extends Mock implements NotesService {}

final _day = DateTime(2026, 3, 14);

const _work = 'nb_work';
const _personal = 'nb_personal';

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
  // `allNotebooksId` is a mutable top-level, so it cannot be a default value.
  Future<ProviderContainer> pumpSheet(
    WidgetTester tester, {
    String? initial,
  }) async {
    final svc = _Svc();
    when(
      svc.getAllNotes,
    ).thenAnswer((_) async => const Success<List<Note>, NotesFailure>([]));
    when(svc.getAllNotebooks).thenAnswer(
      (_) async => Success<List<Notebook>, NotesFailure>([
        _notebook(_work, 'Work'),
        _notebook(_personal, 'Personal'),
      ]),
    );

    final container = ProviderContainer(
      overrides: [
        notesServiceProvider.overrideWithValue(svc),
        userPreferencesProvider.overrideWithValue(await mockUserConfig()),
        currentDateProvider.overrideWithValue(_day),
      ],
    );
    addTearDown(container.dispose);
    container.read(selectedNotebookIdProvider.notifier).id =
        initial ?? allNotebooksId;
    await container.read(notesProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppTheme.light(InkPalette.forest),
            home: const Scaffold(body: ListFilterSheet()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('selecting a notebook applies it and closes the sheet', (
    tester,
  ) async {
    final container = await pumpSheet(tester);

    expect(find.text('Work'), findsOneWidget);

    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();

    expect(
      container.read(selectedNotebookIdProvider),
      _work,
      reason: 'the pick must still be applied',
    );
    expect(
      find.byType(ListFilterSheet),
      findsNothing,
      reason: 'a single-select picker dismisses once the value is applied',
    );
  });

  testWidgets('All notebooks behaves the same as any other row', (
    tester,
  ) async {
    // Opened with a filter already applied, so clearing it is the action under
    // test. A picker that closes for some rows and not others is worse than
    // either behaviour, so "All notes" has to dismiss too.
    final container = await pumpSheet(tester, initial: _work);

    await tester.tap(find.text('All notebooks'));
    await tester.pumpAndSettle();

    expect(container.read(selectedNotebookIdProvider), allNotebooksId);
    expect(find.byType(ListFilterSheet), findsNothing);
  });
}
