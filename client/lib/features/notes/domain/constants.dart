// Neither is a real notebook id. All notes means "no filter" and Today is a
// lens, but both ride in a `String` alongside genuine ids, so every reader has
// to know about them. The fix is a nullable filter plus a typed lens.
const String allNotebooksId = '__all__';
const String todayNotebookId = '__today__';

/// Whether [notebookId] names the All notes lens.
///
/// All notes answers "what do I have", so it renders flat and content-forward.
/// Today and each notebook answer "what is left to do" and keep task-shaped
/// rows.
bool isContentForwardLens(String notebookId) => notebookId == allNotebooksId;
