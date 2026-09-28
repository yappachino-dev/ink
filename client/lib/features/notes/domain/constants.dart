String allNotebooksId = '__all__';
String todayNotebookId = '__today__';

/// Whether [notebookId] names the All notes lens.
///
/// All notes answers "what do I have", so it is rendered flat and
/// content-forward: no completion state, no priority, no due date as the
/// primary axis. Every other lens — Today, and each notebook — is task-forward
/// and keeps task-shaped rows.
///
/// This predicate exists so the distinction has one definition. It previously
/// did not exist, which is why `allNotebooksId` was only meaningful to the
/// calendar's notebook filter and had to be coerced back to Today whenever the
/// user returned to Home.
bool isContentForwardLens(String notebookId) => notebookId == allNotebooksId;
