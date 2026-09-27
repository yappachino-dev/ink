/// The note body is a Quill delta: a JSON list of insert operations. It is the
/// note's domain representation, so everything in this file is plain Dart over
/// that JSON — no editor or widget library is imported here.
///
/// The delta is also **untrusted**. The server is zero-knowledge and never
/// inspects a payload, so whatever a peer client wrote — or a legacy build, or
/// a partial write — reaches this layer verbatim. Reading it is therefore an
/// untrusted-input boundary, not an internal invariant.
library;

/// A single insert operation carrying plain text.
const Map<String, String> _newlineOp = <String, String>{'insert': '\n'};

/// The delta Quill uses for an empty document.
const List<Map<String, String>> emptyNoteDelta = <Map<String, String>>[
  _newlineOp,
];

/// Yields the operations that Quill is able to load, discarding the rest.
///
/// A single unreadable operation is skipped rather than allowed to condemn the
/// whole note: the alternative is opening a 50-paragraph note as an empty
/// document in the editor, where one save overwrites all of it. Losing one
/// corrupt operation is recoverable; losing the note is not.
///
/// Non-`Map` entries, non-string keys, and operations whose `insert` is neither
/// text nor an embedded object are all dropped. The rest of the document is
/// preserved.
Iterable<Map<String, dynamic>> usableNoteOps(List<dynamic>? content) sync* {
  if (content is! List) return;

  for (final op in content) {
    if (op is! Map) continue;

    // JSON decodes to `Map<dynamic, dynamic>`; re-key so Quill sees string
    // keys. Every entry is copied so per-op `attributes` survive, which a
    // naive `{'insert': value}` rebuild would silently flatten.
    final typed = <String, dynamic>{};
    for (final entry in op.entries) {
      final key = entry.key;
      if (key is String) typed[key] = entry.value;
    }

    final insert = typed['insert'];
    if (insert is! String && insert is! Map) continue;

    yield typed;
  }
}

/// Whether a note holds any non-whitespace text.
///
/// This is the emptiness question callers actually want, and it deliberately
/// ignores length: a capped preview cannot answer it, because a note may open
/// with more whitespace than the cap.
bool hasNoteContent(List<dynamic>? content) {
  for (final op in usableNoteOps(content)) {
    final insert = op['insert'];
    if (insert is String && insert.trim().isNotEmpty) return true;
  }
  return false;
}

/// Plain-text preview of a note body, for cards and summaries.
///
/// Reads the delta directly instead of building a Quill document, so a long
/// note costs a string scan rather than a full AST of leaf, block, and line
/// nodes plus listeners. Never throws; unusable content yields an empty string.
///
/// The result is capped at [maxLength], so treat it as display text only. It is
/// not a faithful representation of the note and must not be used to detect
/// edits — compare [content] itself for that. Embedded objects contribute no
/// text here, matching what a reader would see.
String notePreviewText(List<dynamic>? content, {int maxLength = 300}) {
  final buffer = StringBuffer();

  for (final op in usableNoteOps(content)) {
    final insert = op['insert'];
    if (insert is! String) continue;

    buffer.write(insert);

    // Stop at the cap, but keep scanning while everything gathered so far is
    // whitespace. Otherwise a note opening with a long run of blank lines
    // would preview as empty and read as blank in the UI.
    if (buffer.length >= maxLength && buffer.toString().trim().isNotEmpty) {
      break;
    }
  }

  final text = buffer.toString().trim();
  if (text.length <= maxLength) return text;

  return text.substring(0, maxLength).trimRight();
}

/// Repairs a delta so a Quill editor can load it.
///
/// Two of Quill's `loadDocument` rules are routinely violated by untrusted
/// data: it throws `ArgumentError` on an empty delta, and it asserts that the
/// final insert ends with `\n`. The first fires on `[]`; the second fires in
/// debug **and** profile builds on anything as ordinary as
/// `[{"insert": "text"}]`, and mis-renders the final block in release.
///
/// Unreadable operations are dropped (see [usableNoteOps]); only a note whose
/// operations are *all* unusable collapses to [emptyNoteDelta].
List<Object?> normalizeNoteDelta(List<dynamic>? content) {
  final ops = usableNoteOps(content).toList();
  if (ops.isEmpty) return emptyNoteDelta;

  // Quill requires a newline-terminated text insert as the final operation.
  // Deltas that end mid-paragraph, or on an embedded object, trip that assert.
  final last = ops.last;
  if (last['insert'] is! String || !(last['insert'] as String).endsWith('\n')) {
    ops.add(_newlineOp);
  }

  return ops;
}

/// The note's title: the first line of the document (D-2).
///
/// A separate title field duplicates the first line and costs viewport above
/// the keyboard. Returns an empty string when there is no text, so callers can
/// decide their own fallback rather than having one imposed here.
String noteTitleFromContent(List<dynamic>? content) {
  for (final op in usableNoteOps(content)) {
    final insert = op['insert'];
    if (insert is! String) continue;

    final line = insert.split('\n').firstWhere(
      (candidate) => candidate.trim().isNotEmpty,
      orElse: () => '',
    );
    if (line.trim().isNotEmpty) return line.trim();
  }
  return '';
}
