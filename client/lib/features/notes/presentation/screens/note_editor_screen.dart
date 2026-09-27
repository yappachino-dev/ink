import 'dart:async';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/domain/models/note_creation_payload.dart';
import 'package:ink/features/notes/domain/quill_delta.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/presentation/extensions/note_time_ui_extension.dart';
import 'package:ink/features/notes/presentation/extensions/task_priority_ui_extension.dart';
import 'package:ink/features/notes/presentation/helpers.dart';
import 'package:ink/features/notes/presentation/notifiers/note_form_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/projects_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/note_by_id.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/quill_document.dart';
import 'package:ink/features/notes/presentation/widgets/notes/editor/meta_icon_button.dart';
import 'package:ink/features/notes/presentation/widgets/pickers/priority_picker_sheet.dart';
import 'package:ink/features/notes/presentation/widgets/pickers/project_picker_sheet.dart';
import 'package:ink/features/notes/presentation/widgets/pickers/reminder_picker_sheet.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

/// Writing happens somewhere you go, not in a sheet.
///
/// A bottom sheet loses the navigation stack, so there is no back gesture and
/// no addressable URL, and it fights the keyboard for the little viewport it
/// has. The document owns the vertical scroll here; the formatting toolbar is
/// pinned to the bottom, because a writing toolbar that scrolls away is useless
/// precisely when you are using it.
class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({this.noteId, super.key});

  /// Resolved from the provider rather than passed in, so the route is a real
  /// deep link: `/notes/<id>` opens that note with no widget in memory holding
  /// it.
  final String? noteId;

  bool get isEditing => noteId != null;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late QuillController _quillController;
  late final FocusNode _editorFocus;
  String? _seededId;
  bool _formSeeded = false;

  @override
  void initState() {
    super.initState();

    _editorFocus = FocusNode();
    _quillController = QuillController.basic();

    if (widget.noteId == null) {
      final selectedProjectId = ref.read(selectedProjectIdProvider);
      final projectId = switch (selectedProjectId) {
        _ when isContentForwardLens(selectedProjectId) => null,
        _ when selectedProjectId == todayProjectId => null,
        _ => selectedProjectId,
      };
      _seedForm(
        () =>
            ref.read(noteFormProvider.notifier).initWith(projectId: projectId),
      );
    }
  }

  void _seedForm(void Function() seed) {
    if (_formSeeded) return;
    _formSeeded = true;
    unawaited(
      Future.microtask(() {
        if (mounted) seed();
      }),
    );
  }

  /// Loads [note] into the editor once, when it first arrives.
  ///
  /// A route can be deep-linked, so the note is not necessarily in memory when
  /// this screen is built. Reading it once in `initState` and treating a miss
  /// as "new note" would silently create a duplicate on save.
  void _seedFrom(Note note) {
    if (_seededId == note.id) return;
    _seededId = note.id;

    final wasEmpty = _quillController.document.length == 0;
    _quillController.dispose();
    _quillController = QuillController(
      document: parseQuillDocument(note.content),
      selection: const TextSelection.collapsed(offset: 0),
    );
    if (wasEmpty) {
      _seedForm(
        () => ref.read(noteFormProvider.notifier).initWithExisting(note),
      );
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    _editorFocus.dispose();
    super.dispose();
  }

  void _save() {
    final content = _quillController.document.toDelta().toJson();

    // D-2: there is no separate title field. The first line of the document is
    // the title, and a note with no text cannot be saved rather than being
    // given a placeholder.
    final title = noteTitleFromContent(content);
    if (title.isEmpty) return;

    final state = ref.read(noteFormProvider);
    final existing = widget.noteId == null
        ? null
        : ref.read(noteByIdProvider(widget.noteId!));

    if (existing != null) {
      unawaited(
        ref
            .read(notesProvider.notifier)
            .saveNote(
              existing.copyWith(
                title: title,
                content: content,
                projectId: state.projectId,
                dueDate: state.dueDate,
                dueTime: state.dueTime?.toNoteTime(),
                priority: state.priority,
                reminderMinutesBefore: state.reminderMinutes,
              ),
            ),
      );
    } else {
      unawaited(
        ref
            .read(notesProvider.notifier)
            .createNote(
              NoteCreationPayload(
                title: title,
                content: content,
                projectId: state.projectId,
                dueDate: state.dueDate,
                dueTime: state.dueTime?.toNoteTime(),
                priority: state.priority,
                reminderMinutesBefore: state.reminderMinutes,
              ),
            ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final noteId = widget.noteId;

    if (noteId != null) {
      final notesAsync = ref.watch(notesProvider);
      final note = ref.watch(noteByIdProvider(noteId));

      if (note != null) {
        _seedFrom(note);
      } else if (!notesAsync.isLoading) {
        // The id resolved to nothing. Editing it as if it were a new note
        // would duplicate rather than edit, so say so instead.
        return _MissingNote(noteId: noteId);
      }
    }

    return Scaffold(
      backgroundColor: context.ink.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.theme.hintColor),
          tooltip: context.t.note.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isEditing ? context.t.note.edit : context.t.note.create,
          textAlign: TextAlign.center,
          style: context.textTheme.titleMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: context.colorScheme.primary),
            tooltip: context.t.note.save,
            onPressed: _save,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: _EditorSurface(
                quillController: _quillController,
                focusNode: _editorFocus,
              ),
            ),
            // Pinned: a formatting toolbar that scrolls away is useless while
            // you are formatting.
            _QuillToolbar(quillController: _quillController),
          ],
        ),
      ),
    );
  }
}

class _EditorSurface extends StatelessWidget {
  const _EditorSurface({
    required this.quillController,
    required this.focusNode,
  });

  final QuillController quillController;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final fontFamily = context.textTheme.bodyLarge?.fontFamily;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: QuillEditor.basic(
              controller: quillController,
              focusNode: focusNode,
              config: QuillEditorConfig(
                placeholder: context.t.note.whatToDo,
                // The document is the scrollable, not a list wrapping it.
                expands: true,
                autoFocus: true,
                customStyles: DefaultStyles(
                  placeHolder: DefaultTextBlockStyle(
                    TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
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
                      fontSize: 16,
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
            ),
          ),
        ),
        Divider(height: AppSpacing.xxl, color: context.theme.dividerColor),
        const _MetaActionBar(),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _MetaActionBar extends ConsumerWidget {
  const _MetaActionBar();

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final now = ref.read(currentDateProvider);

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
                ? formatDateTime(state.dueDate!, state.dueTime?.toNoteTime(), t)
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
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          top: BorderSide(color: context.colorScheme.outlineVariant),
        ),
      ),
      child: QuillSimpleToolbar(
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
      ),
    );
  }
}

/// Shown when a deep link names a note that is not there.
///
/// The alternative — opening an empty editor and saving — creates a second copy
/// of a note the user meant to edit.
class _MissingNote extends StatelessWidget {
  const _MissingNote({required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ink.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.theme.hintColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            context.t.note.notFound,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
