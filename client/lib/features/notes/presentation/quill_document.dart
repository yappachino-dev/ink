import 'package:flutter_quill/flutter_quill.dart';
import 'package:ink/features/notes/domain/quill_delta.dart';

/// Builds a Quill document from persisted note content.
///
/// The only place that needs the editor library, which is why it sits in
/// presentation: the delta format and its repair rules are domain concerns and
/// live in `domain/quill_delta.dart`, while the editor that renders a document
/// is not something the domain should depend on.
///
/// Never throws. Content Quill cannot load falls back to an empty document, so
/// a note is always openable and a list is never taken down by malformed synced
/// data. Unreadable bytes are left untouched in storage.
///
/// The repair is silent by itself and has to stay that way for a *list*: a card
/// cannot ask a question, and a malformed note must not blank the whole view.
/// The editor is the one caller that can, so it counts what was dropped with
/// [unreadableNoteOpCount] and tells the user before a save overwrites it.
/// Saving here does rewrite the body as valid content, which is the only way to
/// get a note back into a state that can be reopened - but it is destructive,
/// so it is the user's call, not a side effect of tapping Save.
Document parseQuillDocument(List<dynamic>? content) {
  try {
    return Document.fromJson(normalizeNoteDelta(content));
  } on Object {
    // Defence in depth. The normalizer already guarantees insert-only ops
    // ending in a newline, but an editor that cannot open is worse than a blank
    // one, so the last resort is always a usable document.
    return Document.fromJson(emptyNoteDelta);
  }
}
