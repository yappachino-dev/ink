import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/notes/notes_view_state.dart';
import 'package:ink/features/notes/presentation/widgets/notes/task_list_view.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

/// Renders exactly one of the [NotesViewState] cases.
class NotesView extends ConsumerWidget {
  const NotesView({required this.state, this.onRetry, super.key});

  final NotesViewState state;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (state) {
      NotesViewLoading() => const NotesSkeleton(),
      NotesViewEmpty() => _Message(
        icon: Icons.edit_note,
        title: context.t.notes.emptyTitle,
        body: context.t.notes.emptyBody,
      ),
      NotesViewEmptyByFilter() => _Message(
        icon: Icons.filter_alt_off_outlined,
        title: context.t.notes.emptyByFilterTitle,
        body: context.t.notes.emptyByFilterBody,
      ),
      NotesViewError(:final error) => _ErrorView(
        error: error,
        onRetry: onRetry ?? () => ref.invalidate(notesProvider),
      ),
      NotesViewContent() => TaskListView(
        key: ValueKey('list-${ref.watch(selectedNotebookIdProvider)}'),
        title: ref.watch(selectedNotebookTitleProvider),
      ),
    };
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _Message(
      icon: Icons.error_outline,
      title: context.t.notes.errorTitle,
      body: context.t.notes.errorBody,
      action: context.t.notes.retry,
      onAction: onRetry,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onAction, child: Text(action!)),
          ],
        ],
      ),
    );
  }
}

/// Placeholder rows shaped like the list that replaces it, so the transition
/// to content does not jump.
class NotesSkeleton extends StatelessWidget {
  const NotesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => Opacity(
        opacity: 0.4 - (index * 0.05),
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            color: context.ink.container,
            borderRadius: AppRadius.lgRadius,
            border: Border.all(color: context.colorScheme.outlineVariant),
          ),
        ),
      ),
    );
  }
}
