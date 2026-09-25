import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/presentation/navigation/app_destinations.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/screens/calendar_screen.dart';
import 'package:ink/features/notes/presentation/screens/home_screen.dart';
import 'package:ink/features/notes/presentation/widgets/notes/editor/note_editor_sheet.dart';
import 'package:ink/features/vault/presentation/screens/setup_pin_screen.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;

    final materialIcons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await materialIcons.load();
  });

  testWidgets('home screen light and dark', (tester) async {
    await _pumpScreenPair(
      tester,
      filename: 'home.png',
      light: (service) => _notesApp(
        brightness: Brightness.light,
        service: service,
        location: AppDestinations.notes,
        screen: const HomeScreen(),
      ),
      dark: (service) => _notesApp(
        brightness: Brightness.dark,
        service: service,
        location: AppDestinations.notes,
        screen: const HomeScreen(),
      ),
    );
  });

  testWidgets('calendar screen light and dark', (tester) async {
    await _pumpScreenPair(
      tester,
      filename: 'calendar.png',
      light: (service) => _notesApp(
        brightness: Brightness.light,
        service: service,
        location: AppDestinations.calendar,
        screen: const CalendarScreen(),
      ),
      dark: (service) => _notesApp(
        brightness: Brightness.dark,
        service: service,
        location: AppDestinations.calendar,
        screen: const CalendarScreen(),
      ),
    );
  });

  testWidgets('note editor light and dark', (tester) async {
    await _pumpScreenPair(
      tester,
      filename: 'note-editor.png',
      light: (service) => _editorApp(
        brightness: Brightness.light,
        service: service,
      ),
      dark: (service) => _editorApp(
        brightness: Brightness.dark,
        service: service,
      ),
    );
  });

  testWidgets('vault setup light and dark', (tester) async {
    await _pumpScreenPair(
      tester,
      filename: 'vault-setup.png',
      light: (_) => _vaultApp(Brightness.light),
      dark: (_) => _vaultApp(Brightness.dark),
    );
  });
}

Future<void> _pumpScreenPair(
  WidgetTester tester, {
  required String filename,
  required _NotesScreenBuilder light,
  required _NotesScreenBuilder dark,
}) async {
  tester.view.physicalSize = const Size(1600, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final service = _NotesService();
  await tester.pumpWidget(
    TranslationProvider(
      child: _GoldenPair(
        light: light(service),
        dark: dark(service),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await expectLater(
    find.byType(_GoldenPair),
    matchesGoldenFile('goldens/$filename'),
  );
}

Widget _notesApp({
  required Brightness brightness,
  required _NotesService service,
  required String location,
  required Widget screen,
}) {
  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: AppDestinations.notes,
        builder: (_, _) => screen,
      ),
      GoRoute(
        path: AppDestinations.calendar,
        builder: (_, _) => screen,
      ),
      GoRoute(
        path: AppDestinations.profile,
        builder: (_, _) => const SizedBox.shrink(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      notesServiceProvider.overrideWithValue(service),
      currentDateProvider.overrideWithValue(goldenCalendarDate),
    ],
    child: MaterialApp.router(
      theme: _themeFor(brightness),
      localizationsDelegates: const [FlutterQuillLocalizations.delegate],
      routerConfig: router,
    ),
  );
}

Widget _editorApp({
  required Brightness brightness,
  required _NotesService service,
}) {
  return ProviderScope(
    overrides: [notesServiceProvider.overrideWithValue(service)],
    child: MaterialApp(
      theme: _themeFor(brightness),
      localizationsDelegates: const [FlutterQuillLocalizations.delegate],
      home: Scaffold(
        body: NoteEditorSheet(existingNote: goldenNote),
      ),
    ),
  );
}

Widget _vaultApp(Brightness brightness) {
  return ProviderScope(
    child: MaterialApp(
      theme: _themeFor(brightness),
      home: const SetupPinScreen(),
    ),
  );
}

ThemeData _themeFor(Brightness brightness) => brightness == Brightness.dark
    ? AppTheme.dark(InkPalette.forest)
    : AppTheme.light(InkPalette.forest);

class _GoldenPair extends StatelessWidget {
  const _GoldenPair({required this.light, required this.dark});

  final Widget light;
  final Widget dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Row(
          children: [
            Expanded(child: light),
            Expanded(child: dark),
          ],
        ),
      ),
    );
  }
}

typedef _NotesScreenBuilder = Widget Function(_NotesService service);

class _NotesService extends Mock implements NotesService {
  _NotesService() {
    when(getAllNotes).thenAnswer(_allNotes);
    when(getAllProjects).thenAnswer(_allProjects);
  }
}

Future<Result<List<Note>, NotesFailure>> _allNotes(Invocation _) async =>
    Success<List<Note>, NotesFailure>([goldenNote]);

Future<Result<List<Project>, NotesFailure>> _allProjects(Invocation _) async =>
    Success<List<Project>, NotesFailure>([goldenProject]);

final goldenCalendarDate = DateTime(2026, 1, 14);

final goldenNote = Note(
  id: 'golden-note',
  title: 'Review architecture',
  content: [
    {'insert': 'Review architecture\n'},
  ],
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: SyncStatus.synced,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  projectId: 'golden-project',
  dueDate: DateTime(2026, 1, 14),
  priority: TaskPriority.high,
);

final goldenProject = Project(
  id: 'golden-project',
  title: 'Work',
  emoji: '💼',
  colorValue: 0xFF5B9AA9,
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: SyncStatus.synced,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);
