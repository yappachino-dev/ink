import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/presentation/notifiers/projects_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/calendar_notes_provider.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/empty_state_view.dart';
import 'package:ink/features/notes/presentation/widgets/notes/note_details_sheet.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

/// The entries written on the selected calendar day.
///
/// This replaced a task list that split the day into active and completed
/// sections and led every row with a checkbox. A journalled day is a record of
/// what was written, not a schedule, so the list is flat, chronological, and
/// carries no completion or priority affordances.
class JournalDayList extends ConsumerWidget {
  const JournalDayList({super.key});

  /// Unfiled notes have no notebook to name, so the label is omitted for them
  /// rather than standing in a placeholder.
  String? _notebookLabel(List<Project> notebooks, Note note) {
    final id = note.projectId;
    if (id == null) return null;

    return notebooks.where((n) => n.id == id).firstOrNull?.title;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notebooks = ref.watch(projectsProvider).value ?? [];
    final notes = ref.watch(calendarNotesProvider);

    if (notes.isEmpty) {
      return EmptyStateView(
        key: const ValueKey('journal-empty'),
        title: context.t.calendar.noNotes,
      );
    }

    return CustomScrollView(
      slivers: [
        SliverList.builder(
          itemCount: notes.length,
          itemBuilder: (ctx, index) {
            final note = notes[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _JournalEntry(
                key: ValueKey(note.id),
                note: note,
                notebookName: _notebookLabel(notebooks, note),
                onTap: () => context.showAppBottomSheetLayout<void>(
                  child: NoteDetailsSheet(note: note),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _JournalEntry extends StatelessWidget {
  const _JournalEntry({
    required this.note,
    required this.onTap,
    this.notebookName,
    super.key,
  });

  final Note note;
  final VoidCallback onTap;
  final String? notebookName;

  @override
  Widget build(BuildContext context) {
    // Material + InkWell rather than a bare GestureDetector: the audit (F-15)
    // flags tappable surfaces with no press feedback and no focus. Material
    // supplies the ink splash, the focus/hover states, and the button semantics
    // a screen reader needs.
    return Material(
      color: context.ink.container,
      borderRadius: AppRadius.lgRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgRadius,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgRadius,
            border: Border.all(color: context.colorScheme.outlineVariant),
          ),
          child: NoteCard(
            note: note,
            projectName: notebookName,
            showCompletion: false,
            showPriority: false,
          ),
        ),
      ),
    );
  }
}
