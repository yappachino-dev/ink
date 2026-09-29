import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ink/app/navigation/widgets/app_shell.dart';
import 'package:ink/app/presentation/screens/welcome_screen.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/infrastructure/storage/shared_prefs.dart';
import 'package:ink/core/presentation/navigation/app_destinations.dart';
import 'package:ink/core/presentation/providers/status_providers.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/screens/calendar_screen.dart';
import 'package:ink/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:ink/features/notes/presentation/screens/notes_screen.dart';
import 'package:ink/features/profile/presentation/screens/profile_screen.dart';
import 'package:ink/features/vault/presentation/screens/setup_pin_screen.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences _prefs;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;

    final materialIcons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await materialIcons.load();

    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
  });

  testWidgets('home screen light and dark', (tester) async {
    await _pumpScreenPair(
      tester,
      filename: 'home.png',
      light: (service) => _notesApp(
        brightness: Brightness.light,
        service: service,
        location: AppDestinations.notes,
        screen: const NotesScreen(),
      ),
      dark: (service) => _notesApp(
        brightness: Brightness.dark,
        service: service,
        location: AppDestinations.notes,
        screen: const NotesScreen(),
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

  testWidgets('calendar journal day light and dark', (tester) async {
    await _pumpScreenPair(
      tester,
      filename: 'calendar-journal.png',
      notes: [journalFirstNote, journalSecondNote],
      light: (service) => _notesApp(
        brightness: Brightness.light,
        service: service,
        location: AppDestinations.calendar,
        screen: const CalendarScreen(),
        selectAllNotebooks: true,
      ),
      dark: (service) => _notesApp(
        brightness: Brightness.dark,
        service: service,
        location: AppDestinations.calendar,
        screen: const CalendarScreen(),
        selectAllNotebooks: true,
      ),
    );
  });

  testWidgets('note editor light and dark', (tester) async {
    await _pumpScreenPair(
      tester,
      filename: 'note-editor.png',
      light: (service) =>
          _editorApp(brightness: Brightness.light, service: service),
      dark: (service) =>
          _editorApp(brightness: Brightness.dark, service: service),
    );
  });

  testWidgets('welcome screen light and dark', (tester) async {
    await _pumpScreenPair(
      tester,
      filename: 'welcome.png',
      light: (_) => _welcomeApp(Brightness.light),
      dark: (_) => _welcomeApp(Brightness.dark),
    );
  });

  // §11.1 recorded profile as an uncovered surface. Step 9b rewrote it, so it
  // needs a baseline like every other screen it changes.
  testWidgets('profile light and dark', (tester) async {
    await _pumpScreenPair(
      tester,
      filename: 'profile.png',
      light: (_) => _profileApp(Brightness.light),
      dark: (_) => _profileApp(Brightness.dark),
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
  List<Note>? notes,
}) async {
  tester.view.physicalSize = const Size(1600, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final service = _NotesService(notes ?? [goldenNote]);
  await tester.pumpWidget(
    TranslationProvider(
      child: _GoldenPair(light: light(service), dark: dark(service)),
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
  bool selectAllNotebooks = false,
}) {
  // The real [AppShell] is used rather than a bare screen, so the golden shows
  // the navigation bar the user actually sees. F-09 changed that bar; a golden
  // that omitted it would not have caught the change.
  final router = GoRouter(
    initialLocation: location,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppDestinations.notes, builder: (_, _) => screen),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppDestinations.calendar,
                builder: (_, _) => screen,
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppDestinations.profile,
                builder: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      notesServiceProvider.overrideWithValue(service),
      currentDateProvider.overrideWithValue(goldenCalendarDate),
      // Connectivity has no meaning in a golden; record the connected state so
      // the baseline is not permanently an offline banner.
      isOfflineProvider.overrideWithValue(false),
      // `sharedPreferencesProvider` throws unless main() overrides it, and the
      // trust indicator reads the free/sync gate out of it.
      sharedPreferencesProvider.overrideWithValue(_prefs),
      if (selectAllNotebooks)
        selectedNotebookIdProvider.overrideWith(_AllNotebooksSelected.new),
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
      home: const NoteEditorScreen(noteId: 'golden-note'),
    ),
  );
}

Widget _welcomeApp(Brightness brightness) {
  return ProviderScope(
    child: MaterialApp(
      theme: _themeFor(brightness),
      home: const WelcomeScreen(),
    ),
  );
}

Widget _profileApp(Brightness brightness) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(_prefs),
      isOfflineProvider.overrideWithValue(false),
      syncActivityProvider.overrideWithValue(SyncActivity.idle),
    ],
    child: MaterialApp(
      theme: _themeFor(brightness),
      home: const ProfileScreen(),
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
  _NotesService([List<Note>? notes]) : notes = notes ?? [goldenNote] {
    when(getAllNotes).thenAnswer((_) async => _allNotes(this.notes));
    when(getAllNotebooks).thenAnswer(_allNotebooks);
  }

  final List<Note> notes;
}

Future<Result<List<Note>, NotesFailure>> _allNotes(List<Note> notes) async =>
    Success<List<Note>, NotesFailure>(notes);

/// Selects every notebook. The real provider defaults to `todayNotebookId`,
/// which is a sentinel and would filter every fixture note out of the journal.
class _AllNotebooksSelected extends SelectedNotebookId {
  @override
  String build() => allNotebooksId;
}

/// Journal fixtures are written on [goldenCalendarDate], the day the golden
/// selects. `goldenNote` is deliberately not reused here: it was created on the
/// 1st and is due on the 14th, so under journal semantics it must not appear on
/// the 14th.
final journalFirstNote = Note(
  id: 'journal-one',
  title: 'Review architecture',
  content: [
    {'insert': 'Review architecture\n'},
  ],
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: SyncStatus.synced,
  createdAt: goldenCalendarDate,
  updatedAt: goldenCalendarDate,
  notebookId: 'golden-notebook',
);

/// Completed and high priority, so the golden proves the journal renders no
/// completion checkbox and no priority flag even when the note carries them.
final journalSecondNote = Note(
  id: 'journal-two',
  title: 'Sketch the sync contract',
  content: [
    {'insert': 'Cursor semantics first, then the conflict policy.\n'},
  ],
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: SyncStatus.synced,
  createdAt: goldenCalendarDate,
  updatedAt: goldenCalendarDate,
  notebookId: 'golden-notebook',
  // Due later than the day it was written: the journal keys on neither, but a
  // future due-date view will need it.
  dueDate: DateTime(2026, 1, 20),
  priority: TaskPriority.high,
  isCompleted: true,
);

Future<Result<List<Notebook>, NotesFailure>> _allNotebooks(
  Invocation _,
) async => Success<List<Notebook>, NotesFailure>([goldenNotebook]);

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
  notebookId: 'golden-notebook',
  dueDate: DateTime(2026, 1, 14),
  priority: TaskPriority.high,
);

final goldenNotebook = Notebook(
  id: 'golden-notebook',
  title: 'Work',
  emoji: '💼',
  colorValue: 0xFF5B9AA9,
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: SyncStatus.synced,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);
