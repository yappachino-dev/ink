import 'dart:ui' as ui;

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

/// The editor's bottom chrome is one surface, all the way to the screen edge.
///
/// The body used to be wrapped in `SafeArea(top: false)`, so the bottom inset
/// was applied around the *whole column*. The toolbar painted
/// `colorScheme.surface` and the strip underneath it showed the scaffold's
/// `ink.surface` - the same colour in light, two different colours in dark. So
/// closing the keyboard left a second, darker band under the toolbar. The
/// toolbar now owns the inset and paints its background through it.
class _Svc extends Mock implements NotesService {}

class _AllSelected extends SelectedProjectId {
  @override
  String build() => allProjectsId;
}

const _screenHeight = 800.0;

Future<_Svc> _service() async {
  final svc = _Svc();
  when(svc.getAllNotes).thenAnswer(
    (_) async => Success<List<Note>, NotesFailure>([
      Note(
        id: 'n1',
        title: 'Review architecture',
        content: [
          {'insert': 'Review architecture\nbody text\n'},
        ],
        localVersion: 1,
        lastSyncedVersion: 1,
        syncStatus: SyncStatus.synced,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        projectId: 'p1',
        priority: TaskPriority.medium,
      ),
    ]),
  );
  when(
    svc.getAllProjects,
  ).thenAnswer((_) async => const Success<List<Project>, NotesFailure>([]));
  return svc;
}

void main() {
  Future<void> pumpEditor(
    WidgetTester tester,
    _Svc svc, {
    required Brightness brightness,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const ui.Size(400, _screenHeight);
    // A phone with a home indicator.
    tester.view.padding = const FakeViewPadding(bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesServiceProvider.overrideWithValue(svc),
          selectedProjectIdProvider.overrideWith(_AllSelected.new),
        ],
        child: TranslationProvider(
          child: MaterialApp(
            theme: brightness == Brightness.dark
                ? AppTheme.dark(InkPalette.forest)
                : AppTheme.light(InkPalette.forest),
            localizationsDelegates: const [FlutterQuillLocalizations.delegate],
            home: const NoteEditorScreen(noteId: 'n1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final brightness in [Brightness.dark, Brightness.light]) {
    testWidgets('the toolbar bar reaches the bottom edge in $brightness', (
      tester,
    ) async {
      await pumpEditor(tester, await _service(), brightness: brightness);

      final toolbar = find.byType(QuillSimpleToolbar);
      expect(toolbar, findsOneWidget);

      // The coloured bar around the toolbar must extend to the bottom of the
      // screen. If it stopped at the inset, the pixels below it were painted
      // by the scaffold and read as a second band.
      final bar = tester.getRect(
        find.ancestor(of: toolbar, matching: find.byType(Container)).first,
      );
      expect(
        bar.bottom,
        closeTo(_screenHeight, 1),
        reason: 'the toolbar bar stops above the bottom inset',
      );
    });
  }
}
