import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/features/notes/domain/quill_delta.dart';

part 'note_metadata.freezed.dart';

/// Bumped whenever the derivation changes meaning, so rows written by an older
/// build can be told apart from current ones and repaired.
const int noteMetadataVersion = 1;

/// How long a preview keeps. Cards render a single ellipsized line, so this is
/// generous; the point is to bound the column, not to fit a screen.
const int notePreviewMaxLength = 300;

/// Plaintext, locally derived, never synced.
///
/// The server is zero-knowledge: it stores and returns ciphertext and cannot
/// sort or filter on anything about a note's contents. That left every list
/// view decrypting the entire database on every read (F-03/F-03b), and left
/// `dueDate` and friends unqueryable on the client too, because they live
/// inside the encrypted payload rather than in a column.
///
/// These four columns are a local cache of facts already inside that payload.
/// They exist to make SQL filtering and previewing possible. They are not a
/// second source of truth, and nothing that needs the real note may read them
/// in its place.
@freezed
sealed class NoteMetadata with _$NoteMetadata {
  const factory NoteMetadata({
    @Default('') String titlePreview,
    @Default('') String bodyPreview,
    @Default(false) bool hasUncompletedTasks,
    DateTime? dueDateDay,
    @Default(noteMetadataVersion) int version,
  }) = _NoteMetadata;

  const NoteMetadata._();

  /// Whether the row was derived by a build with the current rules.
  bool get isCurrent => version == noteMetadataVersion;
}

/// Metadata for a note whose derivation was deferred because the vault was
/// locked when it arrived. The ciphertext is stored intact and the row is
/// tagged stale, so the backfill derives it on the first read after unlock.
///
/// Version 0 is the whole point, and it is easy to get wrong in the other
/// direction: `const NoteMetadata()` defaults to the *current* version, so
/// writing that would mark the row as derived and the backfill would skip it
/// forever, leaving a permanently blank preview. Use this constant instead of
/// spelling out `version: 0` at a call site.
const NoteMetadata deferredNoteMetadata = NoteMetadata(version: 0);

/// Derives [NoteMetadata] from a note's plaintext fields.
abstract final class NoteMetadataDerivation {
  /// Builds the cache for a note.
  ///
  /// `bodyPreview` is capped and lossy by design. It is display text, never the
  /// note body, and must not be used to detect edits — compare the delta.
  static NoteMetadata derive({
    required String title,
    required List<dynamic> content,
    DateTime? dueDate,
  }) => NoteMetadata(
    titlePreview: title.trim(),
    bodyPreview: notePreviewText(content),
    hasUncompletedTasks: _hasUncheckedChecklistItem(content),
    dueDateDay: _toDay(dueDate),
  );

  /// Metadata for content that could not be decrypted or parsed.
  ///
  /// A note whose body is unreadable still needs a usable row: dropping it
  /// would make the note disappear from filtered views rather than merely
  /// render without a preview.
  static NoteMetadata unreadable({required String title}) =>
      NoteMetadata(titlePreview: title.trim());

  /// Whether any operation is an unchecked checklist item.
  ///
  /// Quill marks list items through `attributes.list`; `checked` and
  /// `unchecked` are the two task-shaped values, distinct from `bullet` and
  /// `ordered`.
  ///
  /// The checked value is the string `'unchecked'`.
  ///
  /// Always false for current data: the editor has no checklist support, so no
  /// body can yet contain one. The column follows the D-1 decision — a task is
  /// a projection over a note's checklist items, not a third entity — and
  /// becomes meaningful the moment the editor can write one. Until then it
  /// filters nothing, and must not be read as "this note is an unfinished
  /// task": that is `!isCompleted`, a different question, and not stored here.
  static bool _hasUncheckedChecklistItem(List<dynamic>? content) {
    for (final op in usableNoteOps(content)) {
      final attributes = op['attributes'];
      if (attributes is! Map) continue;
      if (attributes['list'] == 'unchecked') return true;
    }
    return false;
  }

  /// Local midnight of the recorded day, or null.
  ///
  /// Truncated from the stored value's own fields and never `.toLocal()`-ed,
  /// matching the journal calendar's rule: a date must not be re-dated by the
  /// device timezone.
  static DateTime? _toDay(DateTime? value) {
    if (value == null) return null;
    return DateTime(value.year, value.month, value.day);
  }
}
