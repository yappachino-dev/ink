// `const`, not `var`. These are read by nearly every screen, so a stray
// assignment would silently redefine the meaning of "all" and "today" app-wide
// with nothing to catch it - there is no compiler error and no analyzer rule
// for writing to someone else's top-level variable from another file.
//
// The cost is that neither is a real notebook id. All notes means "no filter",
// and Today is a lens, but both are carried in a `String` alongside genuine
// notebook ids, so every reader has to know about the sentinels. The honest
// fix is a nullable filter plus a typed lens, not these two strings.
const String allNotebooksId = '__all__';
const String todayNotebookId = '__today__';

/// Whether [notebookId] names the All notes lens.
///
/// All notes answers "what do I have", so it is rendered flat and
/// content-forward: no completion state, no priority, no due date as the
/// primary axis. Every other lens - Today, and each notebook - is task-forward
/// and keeps task-shaped rows.
///
/// This predicate exists so the distinction has one definition. It previously
/// did not exist, which is why `allNotebooksId` was only meaningful to the
/// calendar's notebook filter.
bool isContentForwardLens(String notebookId) => notebookId == allNotebooksId;
