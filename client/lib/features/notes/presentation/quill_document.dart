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
/// data. Unreadable bytes are left untouched in storage; saving from the editor
/// rewrites the body as valid content, which is the only way to recover a note
/// that was already partly unreadable.
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
