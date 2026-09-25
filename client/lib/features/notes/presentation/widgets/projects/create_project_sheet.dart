import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_animations.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/domain/models/project_creation_payload.dart';
import 'package:ink/features/notes/presentation/constants/project_constants.dart';
import 'package:ink/features/notes/presentation/notifiers/projects_notifier.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class CreateProjectSheet extends ConsumerStatefulWidget {
  const CreateProjectSheet({
    this.initialProject,
    this.colorOnly = false,
    super.key,
  });

  final Project? initialProject;
  final bool colorOnly;

  @override
  ConsumerState<CreateProjectSheet> createState() => _CreateListSheetState();
}

class _CreateListSheetState extends ConsumerState<CreateProjectSheet> {
  late final TextEditingController _nameController;
  final _nameFocus = FocusNode();

  late Color _selectedColor;
  late String _selectedEmoji;

  bool get _isEditing => widget.initialProject != null;
  bool get _colorOnly => widget.colorOnly;

  @override
  void initState() {
    super.initState();

    final initial = widget.initialProject;

    _nameController = TextEditingController(text: initial?.title ?? '');

    _selectedEmoji = initial?.emoji ?? '📋';

    if (!_colorOnly) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _nameFocus.requestFocus(),
      );
    }
  }

  bool _isColorInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isColorInitialized) {
      _selectedColor = widget.initialProject == null
          ? context.colorScheme.primary
          : Color(widget.initialProject!.colorValue);
      _isColorInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();

    super.dispose();
  }

  void _confirm() {
    final notifier = ref.read(projectsProvider.notifier);

    if (_colorOnly) {
      final project = widget.initialProject!.copyWith(
        colorValue: _selectedColor.toARGB32(),
      );

      unawaited(notifier.saveProject(project));
    } else {
      final name = _nameController.text.trim();
      if (name.isEmpty) return;

      if (_isEditing) {
        final project = widget.initialProject!.copyWith(
          title: name,
          emoji: _selectedEmoji,
          colorValue: _selectedColor.toARGB32(),
        );

        unawaited(notifier.saveProject(project));
      } else {
        final payload = ProjectCreationPayload(
          title: name,
          emoji: _selectedEmoji,
          colorValue: _selectedColor.toARGB32(),
        );

        unawaited(notifier.createProject(payload));
      }
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const borderStyle = OutlineInputBorder(
      borderRadius: AppRadius.lgRadius,
      borderSide: BorderSide.none,
    );

    return BottomSheetLayout(
      padForKeyboard: true,
      header: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.cancel_outlined,
              size: sizes.iconLarge,
              color: context.theme.hintColor,
            ),
          ),

          Expanded(
            child: Text(
              _colorOnly
                  ? context.t.project.form.color
                  : _isEditing
                  ? context.t.project.edit
                  : context.t.project.create,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineMedium,
            ),
          ),

          GestureDetector(
            onTap: _confirm,
            child: Icon(
              Icons.check,
              size: sizes.iconLarge,
              color: context.colorScheme.primary,
            ),
          ),
        ],
      ),
      children: [
        if (!_colorOnly) ...[
          TextField(
            controller: _nameController,
            style: context.textTheme.bodyLarge,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 10),
                child: Text(
                  _selectedEmoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(),

              hintText: context.t.project.form.name,
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
          ),

          const SizedBox(height: 16),
        ],

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.ink.container,
            borderRadius: AppRadius.lgRadius,
          ),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  context.t.project.form.color,
                  style: context.textTheme.titleMedium,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  GestureDetector(
                    onTap: () => setState(
                      () => _selectedColor = context.colorScheme.primary,
                    ),
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: context.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == context.colorScheme.primary
                              ? context.colorScheme.onSurface
                              : context.theme.dividerColor,
                          width: _selectedColor == context.colorScheme.primary
                              ? 1.5
                              : 1.0,
                        ),
                      ),
                      child: Icon(
                        Icons.format_color_reset_outlined,
                        size: sizes.iconMedium,
                        color: _selectedColor == context.colorScheme.primary
                            ? context.colorScheme.onSurface
                            : context.theme.hintColor,
                      ),
                    ),
                  ),

                  ...projectColors.map((color) {
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.ink.surface,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: context.colorScheme.primary,
                                  width: 1.5,
                                )
                              : null,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        if (!_colorOnly)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.ink.container,
              borderRadius: AppRadius.lgRadius,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    context.t.project.form.icon,
                    style: context.textTheme.titleMedium,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ...projectEmojis.map((emoji) {
                      final isSelected = _selectedEmoji == emoji;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedEmoji = emoji),
                        child: AnimatedContainer(
                          duration: AppDurations.fast,
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _selectedColor.withValues(
                                    alpha: AppAlpha.soft,
                                  )
                                : context.colorScheme.surfaceContainer,
                            borderRadius: AppRadius.xsRadius,
                            border: isSelected
                                ? Border.all(
                                    color: _selectedColor,
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
