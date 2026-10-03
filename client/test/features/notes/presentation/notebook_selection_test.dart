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
      final prefs = _ControllablePrefs(
        delay: (id) =>
            id == 'first' ? const Duration(milliseconds: 60) : Duration.zero,
      );
      final c = ProviderContainer(
        overrides: [
          userPreferencesProvider.overrideWithValue(UserConfig(prefs)),
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

      expect(prefs.selectedNotebookId, 'third');
      expect(
        c.read(notesLensSelectionProvider),
        const NotesLens.notebook('third'),
      );
    });

    test('an in-flight write survives the provider being disposed', () async {
      // The queue used to live on the notifier, which is auto-disposed. Once
      // the last listener went away the queue reset, so a write still in
      // flight from the dead instance could land after a write from its
      // replacement and win. The queue belongs to UserConfig, which is
      // keep-alive, so the ordering holds across the lifecycle.
      final prefs = _ControllablePrefs(
        delay: (id) =>
            id == 'first' ? const Duration(milliseconds: 60) : Duration.zero,
      );
      final config = UserConfig(prefs);
      final c = ProviderContainer(
        overrides: [userPreferencesProvider.overrideWithValue(config)],
      );
      addTearDown(c.dispose);

      // Nothing listens, so this instance is disposed as soon as the write is
      // queued rather than when it finishes.
      unawaited(
        c
            .read(notesLensSelectionProvider.notifier)
            .select(const NotesLens.notebook('first')),
      );
      c.invalidate(notesLensSelectionProvider);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // A fresh instance, as a screen transition would produce.
      await c
          .read(notesLensSelectionProvider.notifier)
          .select(const NotesLens.notebook('second'));
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(prefs.selectedNotebookId, 'second');
    });

    test('a failed write rolls back and reports the failure', () async {
      var shouldFail = false;
      final prefs = _ControllablePrefs(fail: (_) => shouldFail);
      final c = ProviderContainer(
        overrides: [
          userPreferencesProvider.overrideWithValue(UserConfig(prefs)),
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

    test('re-selecting a lens supersedes its own failed write', () async {
      // Tap A, then B, then A again, and let the first A fail. The state is A
      // when that failure lands, so a guard comparing state to the written lens
      // cannot tell the stale A apart from the newest one and rolls back a
      // selection the user has just re-made. B and the second A are still
      // queued, so the rollback also discards the taps that came after it.
      var doomedWrites = 0;
      final prefs = _ControllablePrefs(
        fail: (id) => id == 'doomed' && doomedWrites++ == 0,
        delay: (id) =>
            id == 'doomed' ? const Duration(milliseconds: 40) : Duration.zero,
      );
      final c = ProviderContainer(
        overrides: [
          userPreferencesProvider.overrideWithValue(UserConfig(prefs)),
        ],
      );
      addTearDown(c.dispose);
      final sub = c.listen(notesLensSelectionProvider, (_, _) {});
      addTearDown(sub.close);
      final notifier = c.read(notesLensSelectionProvider.notifier);

      unawaited(
        notifier
            .select(const NotesLens.notebook('doomed'))
            .catchError((Object _) {}),
      );
      unawaited(notifier.select(const NotesLens.notebook('middle')));
      unawaited(notifier.select(const NotesLens.notebook('doomed')));
      await Future<void>.delayed(const Duration(milliseconds: 250));

      // Storage ends on 'doomed' from the third tap, so the list must too.
      expect(prefs.selectedNotebookId, 'doomed');
      expect(
        c.read(notesLensSelectionProvider),
        const NotesLens.notebook('doomed'),
      );
    });

    test('a failed All notes write rolls back too', () async {
      // All notes clears the key instead of writing it, so this goes through
      // remove() rather than setString(). The test double has to stall and fail
      // there as well, or this case would quietly pass against a broken
      // implementation.
      var shouldFail = false;
      final prefs = _ControllablePrefs(fail: (id) => id == null && shouldFail);
      final c = ProviderContainer(
        overrides: [
          userPreferencesProvider.overrideWithValue(UserConfig(prefs)),
        ],
      );
      addTearDown(c.dispose);
      final notifier = c.read(notesLensSelectionProvider.notifier);

      await notifier.select(const NotesLens.notebook('kept'));
      shouldFail = true;

      await expectLater(
        notifier.select(const NotesLens.all()),
        throwsA(isA<Exception>()),
      );

      expect(
        c.read(notesLensSelectionProvider),
        const NotesLens.notebook('kept'),
      );
      expect(prefs.selectedNotebookId, 'kept');
    });

    test('a failed write does not undo a later selection', () async {
      // The failing write is the one queued first, but the user has already
      // moved on by the time it lands. Undoing it would drag the list back to
      // a lens the user has left, which is worse than the failed write.
      // Keyed on the id, not a shared flag: the queue defers the write, so a
      // flag flipped straight after the call would already be false by the time
      // the failing write actually runs.
      final prefs = _ControllablePrefs(
        fail: (id) => id == 'doomed',
        delay: (id) =>
            id == 'doomed' ? const Duration(milliseconds: 40) : Duration.zero,
      );
      final c = ProviderContainer(
        overrides: [
          userPreferencesProvider.overrideWithValue(UserConfig(prefs)),
        ],
      );
      addTearDown(c.dispose);
      // The rollback is guarded on `ref.mounted`, which is only true while
      // something is watching. In the app the list always is, so the listener
      // here has to exist or the guard can never be exercised.
      final sub = c.listen(notesLensSelectionProvider, (_, _) {});
      addTearDown(sub.close);
      final notifier = c.read(notesLensSelectionProvider.notifier);

      // The failure is expected and deliberately not awaited, so its rejection
      // needs a handler or it surfaces as an unhandled async error.
      unawaited(
        notifier
            .select(const NotesLens.notebook('doomed'))
            .catchError((Object _) {}),
      );
      await notifier.select(const NotesLens.notebook('kept'));
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(
        c.read(notesLensSelectionProvider),
        const NotesLens.notebook('kept'),
      );
      expect(prefs.selectedNotebookId, 'kept');
    });

    test('two failures roll back to the last persisted lens', () async {
      // The case a per-tap `previous` gets wrong. Both writes fail, so neither
      // 'first' nor 'second' reaches storage. Rolling back to the state that
      // was current when 'second' was queued would restore 'first', which is
      // exactly the value that failed to write.
      final prefs = _ControllablePrefs(fail: (_) => true);
      final c = ProviderContainer(
        overrides: [
          userPreferencesProvider.overrideWithValue(UserConfig(prefs)),
        ],
      );
      addTearDown(c.dispose);
      // The rollback is guarded on `ref.mounted`; keep the provider alive.
      final sub = c.listen(notesLensSelectionProvider, (_, _) {});
      addTearDown(sub.close);
      final notifier = c.read(notesLensSelectionProvider.notifier);

      await expectLater(
        notifier.select(const NotesLens.notebook('first')),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        notifier.select(const NotesLens.notebook('second')),
        throwsA(isA<Exception>()),
      );

      // Nothing was ever persisted, so the only honest state is the one the
      // app opened with.
      expect(c.read(notesLensSelectionProvider), const NotesLens.all());
      expect(prefs.selectedNotebookId, isNull);
    });

    test('a failed write does not poison later selections', () async {
      var shouldFail = false;
      final prefs = _ControllablePrefs(fail: (_) => shouldFail);
      final c = ProviderContainer(
        overrides: [
          userPreferencesProvider.overrideWithValue(UserConfig(prefs)),
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

      expect(prefs.selectedNotebookId, 'accepted');
    });
  });
}

/// In-memory SharedPreferences that can fail or stall a single key on demand.
///
/// The real `UserConfig` runs on top of this, so the serialization queue and
/// the rollback logic under test are the production ones rather than a fake
/// that reimplements them.
class _ControllablePrefs extends Mock implements SharedPreferences {
  _ControllablePrefs({
    bool Function(String? value)? fail,
    Duration Function(String? value)? delay,
  }) : failWhen = fail,
       delayWhen = delay;

  final _store = <String, Object?>{};

  final bool Function(String? value)? failWhen;
  final Duration Function(String? value)? delayWhen;

  String? get selectedNotebookId => getString('selectedNotebook');

  @override
  String? getString(String key) => _store[key] as String?;

  @override
  Future<bool> setString(String key, String value) async {
    await _stall(value);
    _store[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    // All notes clears the key rather than writing it, so the hooks have to
    // run here too. Otherwise a test that fails or stalls the All notes write
    // would silently succeed and pass against a broken implementation.
    await _stall(null);
    _store.remove(key);
    return true;
  }

  Future<void> _stall(String? value) async {
    final delay = delayWhen?.call(value);
    if (delay != null) await Future<void>.delayed(delay);
    if (failWhen?.call(value) ?? false) throw Exception('disk full');
  }
}
