// Steps 4 and 5: the notes surface stops lying about what it is showing.
//
// Before this, the whole surface was one ternary. A failed load, a slow load,
// and a genuinely empty vault were the same pixels, and no note ever said where
// it lived — which for an encrypted product is the central question.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/presentation/providers/status_providers.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/notes_view_state_provider.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/notes/notes_view.dart';
import 'package:ink/features/notes/presentation/widgets/notes/notes_view_state.dart';
import 'package:ink/features/notes/presentation/widgets/notes/offline_banner.dart';
import 'package:ink/features/notes/presentation/widgets/notes/sync_trust_indicator.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Svc extends Mock implements NotesService {}

class _Lens extends SelectedProjectId {
  _Lens(this.id);

  final String id;

  @override
  String build() => id;
}

Note _note(String id, {SyncStatus status = SyncStatus.synced}) => Note(
  id: id,
  title: 'title $id',
  content: [
    {'insert': 'body $id\n'},
  ],
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: status,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  projectId: 'p1',
  priority: TaskPriority.medium,
);

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    registerFallbackValue(_note('fallback'));
  });

  late _Svc svc;
  late SharedPreferences prefs;

  setUp(() async {
    svc = _Svc();
    prefs = await SharedPreferences.getInstance();
    when(
      svc.getAllProjects,
    ).thenAnswer((_) async => const Success<List<Project>, NotesFailure>([]));
  });

  Future<ProviderContainer> containerWith(
    List<Note> notes, {
    String? lens,
    bool localOnly = true,
    SyncActivity activity = SyncActivity.idle,
    bool offline = false,
  }) async {
    when(
      svc.getAllNotes,
    ).thenAnswer((_) async => Success<List<Note>, NotesFailure>(notes));

    // The free/sync gate is persisted, so it must be written before the
    // provider graph reads it. Defaulting to free is the safe direction: a
    // missed write shows the local-only message, not a sync promise.
    await UserConfig(prefs).setLocalOnly(local: localOnly);

    final container = ProviderContainer(
      overrides: [
        notesServiceProvider.overrideWithValue(svc),
        userPreferencesProvider.overrideWithValue(UserConfig(prefs)),
        currentDateProvider.overrideWithValue(DateTime(2026)),
        syncActivityProvider.overrideWithValue(activity),
        isOfflineProvider.overrideWithValue(offline),
        if (lens != null)
          selectedProjectIdProvider.overrideWith(() => _Lens(lens)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> pump(WidgetTester tester, Widget child, ProviderContainer c) {
    return tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppTheme.light(InkPalette.forest),
            home: Scaffold(body: child),
          ),
        ),
      ),
    );
  }

  group('view state', () {
    test('an empty vault is empty, not empty-by-filter', () async {
      final c = await containerWith([]);
      await c.read(notesProvider.future);

      expect(c.read(notesViewStateProvider), isA<NotesViewEmpty>());
    });

    test('a lens matching nothing is empty-by-filter', () async {
      // "You have nothing" and "you filtered your way to nothing" are
      // different situations and need different words.
      final c = await containerWith([_note('a')], lens: 'other-notebook');
      await c.read(notesProvider.future);

      expect(c.read(notesViewStateProvider), isA<NotesViewEmptyByFilter>());
    });

    test('a failed load is an error, not an empty vault', () async {
      // Failures are returned, not thrown: `NotesNotifier.build` rethrows the
      // failure it gets, which is what puts the provider into an error state.
      when(svc.getAllNotes).thenAnswer(
        (_) async => const Failure<List<Note>, NotesFailure>(SessionLocked()),
      );
      final c = ProviderContainer(
        overrides: [notesServiceProvider.overrideWithValue(svc)],
      );
      addTearDown(c.dispose);

      // Hold a subscription: an unreferenced async notifier is auto-disposed
      // mid-build and never reports a value at all. This is a plain test rather
      // than a widget test because the state settles on real async, not on the
      // fake clock `pump` drives.
      final sub = c.listen(notesProvider, (_, _) {});
      addTearDown(sub.close);

      expect(c.read(notesViewStateProvider), isA<NotesViewLoading>());

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(c.read(notesViewStateProvider), isA<NotesViewError>());
    });

    test('content carries the lens notes', () async {
      final c = await containerWith([_note('a'), _note('b')]);
      await c.read(notesProvider.future);

      final state = c.read(notesViewStateProvider);
      expect(state, isA<NotesViewContent>());
      expect((state as NotesViewContent).notes, hasLength(2));
    });

    testWidgets('each state renders its own thing', (tester) async {
      final c = await containerWith([_note('a')]);
      await c.read(notesProvider.future);

      await pump(tester, const NotesView(state: NotesViewEmpty()), c);
      await tester.pumpAndSettle();
      expect(find.text(t.notes.emptyTitle), findsOneWidget);

      await pump(tester, const NotesView(state: NotesViewEmptyByFilter()), c);
      await tester.pumpAndSettle();
      expect(find.text(t.notes.emptyByFilterTitle), findsOneWidget);

      await pump(
        tester,
        NotesView(state: NotesViewError(Exception('boom'))),
        c,
      );
      await tester.pumpAndSettle();
      expect(find.text(t.notes.errorTitle), findsOneWidget);

      await pump(tester, NotesView(state: NotesViewContent([_note('a')])), c);
      await tester.pumpAndSettle();
      expect(find.text('title a'), findsOneWidget);
    });

    testWidgets('retry re-reads the vault, and belongs to the error state', (
      tester,
    ) async {
      var calls = 0;
      final c = await containerWith([_note('a')]);
      // Install the counting stub after the helper, or the helper's own
      // stub overwrites this one.
      when(svc.getAllNotes).thenAnswer((_) async {
        calls++;
        return Success<List<Note>, NotesFailure>([_note('a')]);
      });
      // Keep the graph alive: invalidating an unwatched auto-dispose provider
      // is a no-op, so retry would appear broken.
      c.listen(notesProvider, (_, _) {});
      await c.read(notesProvider.future);
      final afterLoad = calls;

      await pump(tester, const NotesView(state: NotesViewEmpty()), c);
      await tester.pumpAndSettle();
      expect(find.text(t.notes.retry), findsNothing);

      await pump(
        tester,
        NotesView(state: NotesViewError(Exception('boom'))),
        c,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(t.notes.retry));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(calls, greaterThan(afterLoad));
    });
  });

  group('the trust indicator is gate-aware', () {
    testWidgets('a free user is never told syncing exists', (tester) async {
      final c = await containerWith([_note('a')]);
      await c.read(notesProvider.future);

      await pump(tester, const SyncTrustIndicator(), c);
      await tester.pumpAndSettle();

      expect(find.text(t.trust.onDevice), findsOneWidget);
      expect(find.text(t.trust.synced), findsNothing);
      expect(find.text(t.trust.queued), findsNothing);
    });

    testWidgets('a pro user is shown the sync state', (tester) async {
      final c = await containerWith([_note('a')], localOnly: false);
      await c.read(notesProvider.future);

      await pump(tester, const SyncTrustIndicator(), c);
      await tester.pumpAndSettle();

      expect(find.text(t.trust.synced), findsOneWidget);
      expect(find.text(t.trust.onDevice), findsNothing);
    });

    testWidgets('a pro user with an empty vault is not told to upgrade', (
      tester,
    ) async {
      // The on-device message is the free-tier branch. Showing it to a paying
      // user with nothing in the vault read as an upgrade prompt to someone who
      // had already paid.
      final c = await containerWith([], localOnly: false);

      await pump(tester, const SyncTrustIndicator(), c);
      await tester.pumpAndSettle();

      expect(find.text(t.trust.synced), findsOneWidget);
      expect(find.text(t.trust.onDevice), findsNothing);
    });

    testWidgets('the explanation is a tap away, not a long-press', (
      tester,
    ) async {
      final c = await containerWith([_note('a')]);
      await c.read(notesProvider.future);

      await pump(tester, const SyncTrustIndicator(), c);
      await tester.pumpAndSettle();

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(
        tooltip.triggerMode,
        TooltipTriggerMode.tap,
        reason: 'long-press is undiscoverable on a touch screen',
      );
      expect(tooltip.message, t.trust.onDeviceMessage);
    });

    testWidgets('a locally-modified note reads as pending', (tester) async {
      final c = await containerWith([
        _note('a', status: SyncStatus.modified),
      ], localOnly: false);
      await c.read(notesProvider.future);

      await pump(tester, const SyncTrustIndicator(), c);
      await tester.pumpAndSettle();

      expect(find.text(t.trust.queued), findsOneWidget);
    });

    testWidgets('a conflict is surfaced', (tester) async {
      final c = await containerWith([
        _note('a', status: SyncStatus.conflicted),
      ], localOnly: false);
      await c.read(notesProvider.future);

      await pump(tester, const SyncTrustIndicator(), c);
      await tester.pumpAndSettle();

      expect(find.text(t.trust.conflicted), findsOneWidget);
    });

    testWidgets('an in-flight sync wins over a stale note status', (
      tester,
    ) async {
      final c = await containerWith(
        [_note('a', status: SyncStatus.modified)],
        localOnly: false,
        activity: SyncActivity.syncing,
      );
      await c.read(notesProvider.future);

      await pump(tester, const SyncTrustIndicator(), c);
      await tester.pumpAndSettle();

      expect(find.text(t.trust.syncing), findsOneWidget);
    });
  });

  group('the offline banner', () {
    testWidgets('is hidden while connected', (tester) async {
      final c = await containerWith([_note('a')]);
      await pump(tester, const OfflineBanner(), c);
      await tester.pumpAndSettle();

      expect(find.text(t.notes.offline), findsNothing);
    });

    testWidgets('is shown while offline', (tester) async {
      // Offline never stands in for content: the notes are already on disk, so
      // this is context rather than a reason to hide them.
      final c = await containerWith([_note('a')], offline: true);
      await pump(tester, const OfflineBanner(), c);
      await tester.pumpAndSettle();

      expect(find.text(t.notes.offline), findsOneWidget);
    });
  });

  group('the gate itself', () {
    test('the All notes lens is still the default view', () async {
      final c = await containerWith([_note('a')]);
      expect(c.read(selectedProjectIdProvider), allProjectsId);
    });
  });
}
