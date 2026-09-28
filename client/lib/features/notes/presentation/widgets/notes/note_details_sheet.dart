import 'dart:async';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/quill_delta.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/presentation/extensions/task_priority_ui_extension.dart';
import 'package:ink/features/notes/presentation/helpers.dart';
import 'package:ink/features/notes/presentation/navigation/notes_routes.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/note_by_id.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/quill_document.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class NoteDetailsSheet extends ConsumerStatefulWidget {
  const NoteDetailsSheet({required this.note, super.key});

  final Note note;

  @override
  ConsumerState<NoteDetailsSheet> createState() => _NoteDetailsSheetState();
}

class _NoteDetailsSheetState extends ConsumerState<NoteDetailsSheet> {
  QuillController? _readOnlyController;

  @override
  void initState() {
    super.initState();

    _initQuillController(widget.note);
  }

  @override
  void dispose() {
    _readOnlyController?.dispose();

    super.dispose();
  }

  void _initQuillController(Note note) {
    if (!hasNoteContent(note.content)) {
      _readOnlyController = null;
      return;
    }

    _readOnlyController = QuillController(
      document: parseQuillDocument(note.content),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  Future<void> _openEditSheet(Note currentNote) =>
      NoteEditRoute(noteId: currentNote.id).push<void>(context);

  Future<void> _confirmAndDelete(Note currentNote) async {
    final confirmed = await confirmDeletion(
      context,
      context.t.note.delete.title,
      context.t.note.delete.message,
    );

    if (confirmed && mounted) {
      Navigator.of(context).pop();
      unawaited(ref.read(notesProvider.notifier).deleteNote(currentNote));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentNote =
        ref.watch(noteByIdProvider(widget.note.id)) ?? widget.note;

    ref.listen(notesProvider, (prev, next) {
      final oldNote = prev?.value?[widget.note.id] ?? widget.note;
      final newNote = next.value?[widget.note.id] ?? widget.note;

      // Compare the delta, not the derived preview: the preview is capped, so
      // an edit past the cap would go unnoticed, and a formatting-only change
      // produces identical text and would never rebuild.
      if (!listEquals(oldNote.content, newNote.content)) {
        final oldController = _readOnlyController;
        _initQuillController(newNote);
        oldController?.dispose();
      }
    });

    final projectName = ref.watch(selectedProjectTitleProvider);

    return BottomSheetLayout(
      showDivider: true,
      header: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: currentNote.isCompleted,
              onChanged: (_) =>
                  ref.read(notesProvider.notifier).toggleNote(currentNote),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: context.colorScheme.primary,
              side: BorderSide(color: context.colorScheme.primary, width: 1.5),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.xsRadius,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Text(
              currentNote.title,
              style: context.textTheme.titleLarge?.copyWith(
                decoration: currentNote.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: currentNote.isCompleted
                    ? context.theme.hintColor
                    : context.colorScheme.onSurface,
              ),
            ),
          ),

          IconButton(
            onPressed: () => _openEditSheet(currentNote),
            icon: Icon(
              Icons.edit_outlined,
              size: AppSize.iconLarge,
              color: context.colorScheme.primary,
            ),
            tooltip: context.t.note.edit,
            visualDensity: VisualDensity.compact,
          ),

          IconButton(
            onPressed: () => _confirmAndDelete(currentNote),
            icon: Icon(
              Icons.delete_outline,
              size: AppSize.iconLarge,
              color: context.colorScheme.error,
            ),
            tooltip: context.t.note.delete.tooltip,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      children: [
        if (hasNoteContent(currentNote.content) &&
            _readOnlyController != null) ...[
          _DetailSection(
            icon: Icons.notes_outlined,
            child: AbsorbPointer(
              child: QuillEditor.basic(
                controller: _readOnlyController!,
                config: QuillEditorConfig(
                  showCursor: false,
                  customStyles: DefaultStyles(
                    paragraph: DefaultTextBlockStyle(
                      context.textTheme.bodyLarge!,
                      HorizontalSpacing.zero,
                      VerticalSpacing.zero,
                      VerticalSpacing.zero,
                      null,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),
        ],

        if (currentNote.dueDate != null) ...[
          _DetailSection(
            icon: Icons.calendar_today_outlined,
            child: Text(
              formatDateTime(currentNote.dueDate!, currentNote.dueTime, t),
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),
        ],

        if (projectName.isNotEmpty) ...[
          _DetailSection(
            icon: Icons.folder_outlined,
            child: Text(
              projectName,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),
        ],

        if (currentNote.priority != TaskPriority.none) ...[
          _DetailSection(
            icon: Icons.flag_outlined,
            iconColor: currentNote.priority.color,
            child: Text(
              currentNote.priority.label(t),
              style: context.textTheme.bodyLarge?.copyWith(
                color: currentNote.priority.color,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),
        ],

        if (currentNote.reminderMinutesBefore != null) ...[
          _DetailSection(
            icon: Icons.notifications_outlined,
            child: Text(
              reminderLabel(currentNote.reminderMinutesBefore!, t),
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.child,
    this.iconColor,
  });

  final IconData icon;
  final Widget child;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: AppSize.iconMedium,
          color: iconColor ?? context.theme.hintColor,
        ),

        const SizedBox(width: AppSpacing.md),

        Expanded(child: child),
      ],
    );
  }
}
