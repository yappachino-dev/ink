import 'package:flutter_test/flutter_test.dart';
import 'package:ink/features/notes/domain/notes_lens.dart';

/// The lens replaced two reserved strings that used to travel inside the
/// notebook id: `'__all__'` meaning "no filter" and `'__today__'` meaning a
/// lens. Both were invisible to the compiler, so a stale value read as a
/// notebook that did not exist.
void main() {
  group('NotesLens.id', () {
    test('every lens has its own key', () {
      // The key is the widget identity of the notes list and the value
      // persisted in preferences, so two lenses sharing one would leak scroll
      // position and collapse two selections into one.
      final ids = [
        const NotesLens.all().id,
        const NotesLens.today().id,
        const NotesLens.notebook('notebook-1').id,
        const NotesLens.notebook('notebook-2').id,
      ];

      expect(ids.toSet(), hasLength(ids.length));
    });

    test('a notebook lens keeps its own id verbatim', () {
      // A notebook may be named anything now, including what used to be a
      // reserved word. There is no longer a sentinel to collide with.
      expect(const NotesLens.notebook('__all__').id, '__all__');
      expect(const NotesLens.notebook('__today__').id, '__today__');
    });
  });

  group('isNotebook', () {
    test('matches only the named notebook', () {
      // The drawer asks this in three places. Freezed value equality makes
      // comparing against a reconstructed lens correct, so this is about
      // reading as a question rather than about correctness.
      expect(const NotesLens.notebook('n1').isNotebook('n1'), isTrue);
      expect(const NotesLens.notebook('n1').isNotebook('n2'), isFalse);
      expect(const NotesLens.all().isNotebook('n1'), isFalse);
      expect(const NotesLens.today().isNotebook('n1'), isFalse);
    });
  });

  group('isContentForward', () {
    test('only All notes is content-forward', () {
      // All notes answers "what do I have", so it renders flat with no
      // completion or priority affordances. Today and each notebook answer
      // "what is left to do" and keep task-shaped rows.
      expect(const NotesLens.all().isContentForward, isTrue);
      expect(const NotesLens.today().isContentForward, isFalse);
      expect(const NotesLens.notebook('notebook-1').isContentForward, isFalse);
    });
  });
}
