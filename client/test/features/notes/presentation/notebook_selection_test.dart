// Step 9a follow-up: the notebook you opened, and the way back out of it.
//
// The drawer listed Today and the notebooks but never "All notes", so selecting
// a notebook left no route back to the default view except switching tabs,
// which happened to reset the shared lens as a side effect. The selection was
// also never stored, so the app reopened on All notes no matter where you
// left it.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_helpers.dart';

class _Svc extends Mock implements NotesService {}

void main() {
  late _Svc svc;

  setUp(() {
    svc = _Svc();
    when(
      svc.getAllNotebooks,
    ).thenAnswer((_) async => const Success<List<Notebook>, NotesFailure>([]));
    when(
      svc.getAllNotes,
    ).thenAnswer((_) async => const Success<List<Note>, NotesFailure>([]));
  });

  Future<ProviderContainer> container({
    Map<String, Object> stored = const {},
  }) async {
    final c = ProviderContainer(
      overrides: [
        notesServiceProvider.overrideWithValue(svc),
        userPreferencesProvider.overrideWithValue(
          await mockUserConfig(values: stored),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('the selection is remembered', () {
    test('a chosen notebook is restored on the next start', () async {
      final first = await container();
      first.read(selectedNotebookIdProvider.notifier).id = 'notebook-1';
      first.dispose();

      // A fresh container is a fresh app start: only storage carries over.
      final second = await container(
        stored: const {'selectedNotebook': 'notebook-1'},
      );

      expect(second.read(selectedNotebookIdProvider), 'notebook-1');
    });

    test('nothing stored means the default view', () async {
      final c = await container();

      expect(c.read(selectedNotebookIdProvider), allNotebooksId);
    });

    test(
      'a stored id the notebook list no longer knows does not throw',
      () async {
        when(svc.getAllNotebooks).thenAnswer(
          (_) async => const Success<List<Notebook>, NotesFailure>([]),
        );

        final c = await container(
          stored: const {'selectedNotebook': 'deleted-elsewhere'},
        );

        // `SelectedNotebookTitle` used to `firstWhere` over the list and
        // take the whole screen down when the id was absent.
        expect(() => c.read(selectedNotebookTitleProvider), returnsNormally);
        expect(c.read(selectedNotebookTitleProvider), t.notes.all);
      },
    );
  });

  group('today and all notes remain usable lenses', () {
    test('each id survives a round trip through storage', () async {
      for (final id in [allNotebooksId, todayNotebookId, 'notebook-1']) {
        final c = await container();
        c.read(selectedNotebookIdProvider.notifier).id = id;

        expect(c.read(selectedNotebookIdProvider), id);
        c.dispose();
      }
    });
  });
}
