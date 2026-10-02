// Step 9a follow-up: the notebook you opened, and the way back out of it.
//
// The drawer listed Today and the notebooks but never "All notes", so selecting
// a notebook left no route back to the default view except switching tabs,
// which happened to reset the shared lens as a side effect. The selection was
// also never stored, so the app reopened on All notes no matter where you
// left it.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_lens.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      await first
          .read(notesLensSelectionProvider.notifier)
          .select(const NotesLens.notebook('notebook-1'));
      first.dispose();

      // A fresh container is a fresh app start: only storage carries over.
      final second = await container(
        stored: const {'selectedNotebook': 'notebook-1'},
      );

      expect(
        second.read(notesLensSelectionProvider),
        const NotesLens.notebook('notebook-1'),
      );
    });

    test('a lens stored under an old sentinel still restores', () async {
      // Before NotesLens, both built-in lenses persisted as reserved strings.
      // Reading only the new key would decode either as a notebook id no note
      // carries: the title would fall back to All notes while the list came
      // back empty, which reads as every note having disappeared.
      final legacy = {
        '__today__': const NotesLens.today(),
        '__all__': const NotesLens.all(),
      };

      for (final entry in legacy.entries) {
        final c = await container(stored: {'selectedNotebook': entry.key});

        expect(
          c.read(notesLensSelectionProvider),
          entry.value,
          reason: 'stored as ${entry.key}',
        );
      }
    });

    test('nothing stored means the default view', () async {
      final c = await container();

      expect(c.read(notesLensSelectionProvider), const NotesLens.all());
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
    test('each lens survives a round trip through storage', () async {
      for (final lens in [
        const NotesLens.all(),
        const NotesLens.today(),
        const NotesLens.notebook('notebook-1'),
      ]) {
        final c = await container();
        await c.read(notesLensSelectionProvider.notifier).select(lens);
        expect(c.read(notesLensSelectionProvider), lens);

        // `select` is awaitable precisely so the write is durable by the time
        // it returns. Reading it back needs no settling period.
        final stored = c.read(userPreferencesProvider).selectedNotebookId;

        // All notes is the absence of a filter, so it stores nothing rather
        // than a reserved word that the type exists to eliminate.
        expect(stored, lens is AllNotesLens ? null : lens.id);

        // A container seeded with exactly what select() wrote restores the same
        // lens. `mockUserConfig` resets the store on every call, so the second
        // container has to be seeded explicitly rather than inherit it.
        final restored = await container(stored: {'selectedNotebook': ?stored});
        expect(restored.read(notesLensSelectionProvider), lens);
        c.dispose();
      }
    });
  });

  group('the write is durable', () {
    // The original bug: `select` returned before the write landed, so a restart
    // inside that window reopened on the previous lens. These assert the
    // awaitable contract instead of waiting for a settling period.
    test('is persisted by the time select returns', () async {
      final c = await container();
      addTearDown(c.dispose);

      await c
          .read(notesLensSelectionProvider.notifier)
          .select(const NotesLens.today());

      // No pumpEventQueue. If the write were still in flight this would be
      // null, and the round trip would restore All notes.
      expect(c.read(userPreferencesProvider).selectedNotebookId, 'today');
    });

    test('queues rapid selections so the last one wins', () async {
      // The first write is made slow on purpose. SharedPreferences resolves
      // fast enough that without a queue the writes land in order by luck,
      // so the test would pass against an implementation that still races.
      final prefs = await _failingPreferencesBase();
      final c = ProviderContainer(
        overrides: [
          userPreferencesProvider.overrideWithValue(
            _FailingPreferences(
              prefs,
              delayFor: (id) => id == 'first'
                  ? const Duration(milliseconds: 60)
                  : Duration.zero,
            ),
          ),
        ],
      );
      addTearDown(c.dispose);
      final notifier = c.read(notesLensSelectionProvider.notifier);

      // Unawaited on purpose: this is the tap-twice-fast case. Without
      // serialization the slow first write lands last, so the file ends up
      // describing a notebook the user already moved away from.
      unawaited(notifier.select(const NotesLens.notebook('first')));
      unawaited(notifier.select(const NotesLens.notebook('second')));
      await notifier.select(const NotesLens.notebook('third'));

      // Awaiting the third select is not enough: the slow first write is
      // still in flight and lands after it. The assertion has to happen once
      // every write has settled, or the race stays invisible.
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(c.read(userPreferencesProvider).selectedNotebookId, 'third');
      expect(
        c.read(notesLensSelectionProvider),
        const NotesLens.notebook('third'),
      );
    });

    test('a failed write rolls back and reports the failure', () async {
      final prefs = await _failingPreferencesBase();
      var shouldFail = false;
      final c = ProviderContainer(
        overrides: [
          userPreferencesProvider.overrideWithValue(
            _FailingPreferences(prefs, shouldFail: (_) => shouldFail),
          ),
        ],
      );
      addTearDown(c.dispose);

      await c
          .read(notesLensSelectionProvider.notifier)
          .select(const NotesLens.notebook('kept'));
      shouldFail = true;

      await expectLater(
        c
            .read(notesLensSelectionProvider.notifier)
            .select(const NotesLens.notebook('never-lands')),
        throwsA(isA<Exception>()),
      );

      // The app must not show a selection it failed to record.
      expect(
        c.read(notesLensSelectionProvider),
        const NotesLens.notebook('kept'),
      );
    });

    test('a failed write does not undo a selection made after it', () async {
      // The failing write is the one queued first, but the user has already
      // moved on by the time it lands. Undoing it would drag the list back to
      // a lens the user has left, which is worse than the failed write.
      final prefs = await _failingPreferencesBase();
      final c = ProviderContainer(
        overrides: [
          userPreferencesProvider.overrideWithValue(
            _FailingPreferences(
              prefs,
              // Keyed on the id, not a shared flag: the queue defers the write,
              // so a flag flipped straight after the call would already be
              // false by the time the failing write actually runs.
              shouldFail: (id) => id == 'doomed',
              delayFor: (id) => id == 'doomed'
                  ? const Duration(milliseconds: 40)
                  : Duration.zero,
            ),
          ),
        ],
      );
      addTearDown(c.dispose);
      // The rollback is guarded on `ref.mounted`, which is only true while
      // something is watching. In the app the list always is, so the listener
      // here has to exist or the guard can never be exercised.
      final sub = c.listen(notesLensSelectionProvider, (_, _) {});
      addTearDown(sub.close);
      final notifier = c.read(notesLensSelectionProvider.notifier);

      unawaited(notifier.select(const NotesLens.notebook('doomed')));
      await notifier.select(const NotesLens.notebook('kept'));
      await Future<void>.delayed(const Duration(milliseconds: 150));

      expect(
        c.read(notesLensSelectionProvider),
        const NotesLens.notebook('kept'),
      );
      expect(c.read(userPreferencesProvider).selectedNotebookId, 'kept');
    });

    test('a failed write does not poison later selections', () async {
      final prefs = await _failingPreferencesBase();
      var shouldFail = false;
      final c = ProviderContainer(
        overrides: [
          userPreferencesProvider.overrideWithValue(
            _FailingPreferences(prefs, shouldFail: (_) => shouldFail),
          ),
        ],
      );
      addTearDown(c.dispose);
      final notifier = c.read(notesLensSelectionProvider.notifier);

      shouldFail = true;
      await expectLater(
        notifier.select(const NotesLens.notebook('rejected')),
        throwsA(isA<Exception>()),
      );

      shouldFail = false;
      await notifier.select(const NotesLens.notebook('accepted'));

      expect(c.read(userPreferencesProvider).selectedNotebookId, 'accepted');
    });
  });
}

/// Fails or delays writes on demand so the rollback and queueing paths are
/// reachable from a test.
class _FailingPreferences extends UserConfig {
  // The super parameter is private to UserConfig, so a super parameter is not
  // available here and the lint's suggestion cannot compile.
  // ignore: use_super_parameters
  _FailingPreferences(
    SharedPreferences prefs, {
    bool Function(String? id)? shouldFail,
    Duration Function(String? id)? delayFor,
  }) : _shouldFail = shouldFail ?? _never,
       _delayFor = delayFor ?? _noDelay,
       super(prefs);

  final bool Function(String? id) _shouldFail;
  final Duration Function(String? id) _delayFor;

  @override
  Future<void> setSelectedNotebookId(String? id) async {
    if (_shouldFail(id)) throw Exception('disk full');
    await Future<void>.delayed(_delayFor(id));
    return super.setSelectedNotebookId(id);
  }
}

bool _never(String? _) => false;
Duration _noDelay(String? _) => Duration.zero;

Future<SharedPreferences> _failingPreferencesBase() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}
