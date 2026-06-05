import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/domain/models/note_creation_payload.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/presentation/helpers.dart';
import 'package:ink/features/notes/presentation/notifiers/note_form_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/projects_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/notes/editor/meta_icon_button.dart';
import 'package:ink/features/notes/presentation/widgets/pickers/priority_picker_sheet.dart';
import 'package:ink/features/notes/presentation/widgets/pickers/project_picker_sheet.dart';
import 'package:ink/features/notes/presentation/widgets/pickers/reminder_picker_sheet.dart';
import 'package:ink/i18n/strings.g.dart';

class NoteEditorSheet extends ConsumerStatefulWidget {
  const NoteEditorSheet({
    this.existingNote,
    super.key,
  });

  final Note? existingNote;

  bool get isEditing => existingNote != null;

  @override
  ConsumerState<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends ConsumerState<NoteEditorSheet> {
  late final TextEditingController _titleController;
  late final QuillController _quillController;

  @override
  void initState() {
    super.initState();

    if (!widget.isEditing) {
      _titleController = TextEditingController();
      _quillController = QuillController.basic();

      final selectedProjectId = ref.read(selectedProjectIdProvider);
      final projectId = switch (selectedProjectId) {
        _ when selectedProjectId == allProjectsId => null,
        _ when selectedProjectId == todayProjectId => null,
        _ when selectedProjectId == inboxProjectId => null,
        _ => selectedProjectId,
      };

      unawaited(
        Future.microtask(() {
          if (mounted) {
            ref
                .read(noteFormProvider.notifier)
                .initWith(projectId: projectId, dueDate: DateTime.now());
          }
        }),
      );
    } else {
      final init = widget.existingNote!;

      _titleController = TextEditingController(text: init.title);
      _quillController = QuillController(
        document: Document.fromDelta(init.content.toDelta()),
        selection: const TextSelection.collapsed(offset: 0),
      );

      unawaited(
        Future.microtask(() {
          if (mounted) {
            ref.read(noteFormProvider.notifier).initWithExisting(init);
          }
        }),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();

    super.dispose();
  }

  void _onConfirm() {
    final title = _titleController.text.trim();

    if (title.isEmpty) return;

    final state = ref.read(noteFormProvider);

    if (widget.isEditing) {
      final updated = widget.existingNote!.copyWith(
        title: title,
        content: _quillController.document,
        projectId: state.projectId,
        dueDate: state.dueDate,
        dueTime: state.dueTime,
        priority: state.priority,
        reminderMinutesBefore: state.reminderMinutes,
      );

      unawaited(ref.read(notesProvider.notifier).saveNote(updated));
    } else {
      final payload = NoteCreationPayload(
        title: title,
        content: _quillController.document,
        projectId: state.projectId,
        dueDate: state.dueDate,
        dueTime: state.dueTime,
        priority: state.priority,
        reminderMinutesBefore: state.reminderMinutes,
      );

      unawaited(ref.read(notesProvider.notifier).createNote(payload));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetLayout(
      padForKeyboard: true,
      header: _HeaderRow(
        isEditing: widget.isEditing,
        onCancel: () => Navigator.of(context).pop(),
        onConfirm: _onConfirm,
      ),
      children: [
        _TitleTextField(textController: _titleController),

        const SizedBox(height: 8),

        _NoteContentField(quillController: _quillController),

        const SizedBox(height: 8),

        _QuillToolbar(quillController: _quillController),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.isEditing,
    required this.onCancel,
    required this.onConfirm,
  });

  final bool isEditing;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onCancel,
          child: Icon(
            Icons.cancel_outlined,
            size: sizes.iconLarge,
            color: context.theme.hintColor,
          ),
        ),

        Expanded(
          child: Text(
            isEditing ? context.t.note.edit : context.t.note.create,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineMedium,
          ),
        ),

        GestureDetector(
          onTap: onConfirm,
          child: Icon(
            Icons.check,
            size: sizes.iconLarge,
            color: context.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _TitleTextField extends StatelessWidget {
  const _TitleTextField({
    required this.textController,
  });

  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    );

    return TextField(
      controller: textController,
      style: context.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: context.t.note.whatToDo,
        hintStyle: context.textTheme.bodyLarge?.copyWith(
          color: context.theme.hintColor,
        ),
        filled: true,
        fillColor: context.colorScheme.surfaceBright,
        border: borderStyle,
        enabledBorder: borderStyle,
        focusedBorder: borderStyle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        isDense: true,
      ),
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => FocusScope.of(context).nextFocus(),
    );
  }
}

class _NoteContentField extends StatelessWidget {
  const _NoteContentField({required this.quillController});

  final QuillController quillController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _QuillEditorField(quillController: quillController),

          Divider(height: 16, color: context.theme.dividerColor),

          const _MetaActionBar(),
        ],
      ),
    );
  }
}

class _QuillEditorField extends StatelessWidget {
  const _QuillEditorField({required this.quillController});

  final QuillController quillController;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 60,
        maxHeight: 120,
      ),
      child: Builder(
        builder: (context) {
          final fontFamily = Theme.of(
            context,
          ).textTheme.bodyLarge?.fontFamily;
          return QuillEditor.basic(
            controller: quillController,
            config: QuillEditorConfig(
              placeholder: context.t.note.addDetails,
              customStyles: DefaultStyles(
                placeHolder: DefaultTextBlockStyle(
                  TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: context.theme.hintColor,
                    height: 1.5,
                  ),
                  HorizontalSpacing.zero,
                  VerticalSpacing.zero,
                  VerticalSpacing.zero,
                  null,
                ),
                paragraph: DefaultTextBlockStyle(
                  TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: context.colorScheme.onSurface,
                    height: 1.5,
                  ),
                  HorizontalSpacing.zero,
                  VerticalSpacing.zero,
                  VerticalSpacing.zero,
                  null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MetaActionBar extends ConsumerWidget {
  const _MetaActionBar();

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();

    final initialState = ref.read(noteFormProvider);

    final dueDate = await showDatePicker(
      context: context,
      initialDate: initialState.dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (dueDate == null || !context.mounted) return;

    final dueTime = await showTimePicker(
      context: context,
      initialTime: initialState.dueTime ?? TimeOfDay.now(),
    );

    ref.read(noteFormProvider.notifier).updateDueFields(dueDate, dueTime);
  }

  Future<void> _pickProject(
    BuildContext context,
    WidgetRef ref,
    List<Project> projects,
  ) async {
    await context.showAppBottomSheetLayout<void>(
      child: ProjectPickerSheet(
        projects: projects,
        selectedProjectId: ref.read(noteFormProvider).projectId,
        onSelected: (projectId) {
          ref.read(noteFormProvider.notifier).updateProjectId(projectId);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _pickPriority(BuildContext context, WidgetRef ref) async {
    await context.showAppBottomSheetLayout<void>(
      child: PriorityPickerSheet(
        current: ref.read(noteFormProvider).priority,
        onSelected: (priority) {
          ref.read(noteFormProvider.notifier).updatePriority(priority);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _pickReminder(BuildContext context, WidgetRef ref) async {
    await context.showAppBottomSheetLayout<void>(
      child: ReminderPickerSheet(
        current: ref.read(noteFormProvider).reminderMinutes,
        onSelected: (minutes) {
          ref.read(noteFormProvider.notifier).updateReminder(minutes);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider).value ?? [];
    final state = ref.watch(noteFormProvider);

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          MetaIconButton(
            icon: Icons.calendar_today_outlined,
            label: state.dueDate != null
                ? formatDateTime(state.dueDate!, state.dueTime, t)
                : null,
            isActive: state.dueDate != null,
            onTap: () => _pickDate(context, ref),
            onClear: state.dueDate != null
                ? ref.read(noteFormProvider.notifier).nullDueFields
                : null,
          ),

          MetaIconButton(
            icon: Icons.folder_outlined,
            label: projectName(projects, state.projectId),
            isActive: state.projectId != null,
            onTap: () => _pickProject(context, ref, projects),
            onClear: state.projectId != null
                ? () =>
                      ref.read(noteFormProvider.notifier).updateProjectId(null)
                : null,
          ),

          MetaIconButton(
            icon: Icons.flag_outlined,
            label: state.priority != TaskPriority.none
                ? state.priority.label(t)
                : null,
            isActive: state.priority != TaskPriority.none,
            activeColor: state.priority.color,
            onTap: () => _pickPriority(context, ref),
            onClear: state.priority != TaskPriority.none
                ? () => ref
                      .read(noteFormProvider.notifier)
                      .updatePriority(TaskPriority.none)
                : null,
          ),

          MetaIconButton(
            icon: Icons.notifications_none_outlined,
            label: state.reminderMinutes != null
                ? reminderLabel(state.reminderMinutes!, t)
                : null,
            isActive: state.reminderMinutes != null,
            onTap: () => _pickReminder(context, ref),
            onClear: state.reminderMinutes != null
                ? () => ref.read(noteFormProvider.notifier).updateReminder(null)
                : null,
          ),
        ],
      ),
    );
  }
}

class _QuillToolbar extends StatelessWidget {
  const _QuillToolbar({required this.quillController});

  final QuillController quillController;

  @override
  Widget build(BuildContext context) {
    return QuillSimpleToolbar(
      controller: quillController,
      config: const QuillSimpleToolbarConfig(
        showStrikeThrough: false,
        showColorButton: false,
        showBackgroundColorButton: false,
        showClearFormat: false,
        showLink: false,
        showHeaderStyle: false,
        showCodeBlock: false,
        showQuote: false,
        showIndent: false,
        showSearchButton: false,
        showSubscript: false,
        showSuperscript: false,
        showDividers: false,
        multiRowsDisplay: false,
      ),
    );
  }
}
