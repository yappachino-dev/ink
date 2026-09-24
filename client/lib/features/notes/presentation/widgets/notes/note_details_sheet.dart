import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/presentation/extensions/note_ui_extension.dart';
import 'package:ink/features/notes/presentation/extensions/task_priority_ui_extension.dart';
import 'package:ink/features/notes/presentation/helpers.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/note_by_id.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/notes/editor/note_editor_sheet.dart';
import 'package:ink/i18n/strings.g.dart';

class NoteDetailsSheet extends ConsumerStatefulWidget {
  const NoteDetailsSheet({
    required this.note,
    super.key,
  });

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
    if (note.subtitle.isEmpty) {
      _readOnlyController = null;
      return;
    }

    _readOnlyController = QuillController(
      document: Document.fromJson(note.content),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  Future<void> _openEditSheet(Note currentNote) async {
    await context.showAppBottomSheetLayout<void>(
      child: NoteEditorSheet(existingNote: currentNote),
    );
  }

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

      if (oldNote.subtitle != newNote.subtitle) {
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
              side: BorderSide(
                color: context.colorScheme.primary,
                width: 1.5,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.xsRadius,
              ),
            ),
          ),

          const SizedBox(width: 12),

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
              size: sizes.iconLarge,
              color: context.colorScheme.primary,
            ),
            tooltip: context.t.note.edit,
            visualDensity: VisualDensity.compact,
          ),

          IconButton(
            onPressed: () => _confirmAndDelete(currentNote),
            icon: Icon(
              Icons.delete_outline,
              size: sizes.iconLarge,
              color: context.colorScheme.error,
            ),
            tooltip: context.t.note.delete.tooltip,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      children: [
        if (currentNote.subtitle.isNotEmpty && _readOnlyController != null) ...[
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

          const SizedBox(height: 12),
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

          const SizedBox(height: 12),
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

          const SizedBox(height: 12),
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

          const SizedBox(height: 12),
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
          size: sizes.iconMedium,
          color: iconColor ?? context.theme.hintColor,
        ),

        const SizedBox(width: 12),

        Expanded(child: child),
      ],
    );
  }
}
