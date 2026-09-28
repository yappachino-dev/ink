import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_animations.dart';
import 'package:ink/core/presentation/theme/contrast.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/domain/models/project_creation_payload.dart';
import 'package:ink/features/notes/presentation/constants/project_constants.dart';
import 'package:ink/features/notes/presentation/notifiers/projects_notifier.dart';
import 'package:ink/features/notes/presentation/widgets/projects/project_icon_view.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class CreateProjectSheet extends ConsumerStatefulWidget {
  const CreateProjectSheet({this.initialProject, super.key});

  final Project? initialProject;

  @override
  ConsumerState<CreateProjectSheet> createState() => _CreateListSheetState();
}

class _CreateListSheetState extends ConsumerState<CreateProjectSheet> {
  late final TextEditingController _nameController;
  final _nameFocus = FocusNode();

  late Color _selectedColor;
  late String _selectedEmoji;

  bool get _isEditing => widget.initialProject != null;
  @override
  void initState() {
    super.initState();

    final initial = widget.initialProject;

    _nameController = TextEditingController(text: initial?.title ?? '');

    _selectedEmoji = initial?.emoji ?? ProjectIcon.book.key;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _nameFocus.requestFocus(),
    );
  }

  bool _isColorInitialized = false;

  /// Whether the colour is one of the eight fixed swatches rather than the
  /// theme default, which the two rows previously compared inconsistently.
  bool get _isPaletteColor => projectColors.contains(_selectedColor);

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

    {
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
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.cancel_outlined, size: AppSize.iconLarge),
            color: context.theme.hintColor,
            tooltip: context.t.common.cancel,
            visualDensity: VisualDensity.compact,
          ),

          Expanded(
            child: Text(
              _isEditing ? context.t.project.edit : context.t.project.create,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineMedium,
            ),
          ),

          IconButton(
            onPressed: _confirm,
            icon: const Icon(Icons.check, size: AppSize.iconLarge),
            color: context.colorScheme.primary,
            tooltip: context.t.common.confirm,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      children: [
        TextField(
          controller: _nameController,
          style: context.textTheme.bodyLarge,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.sm,
              ),
              // The live preview used to print the stored value straight into
              // the field, so a new notebook showed the word "book" in front of
              // its name.
              child: ProjectIconView(
                value: _selectedEmoji,
                size: 18,
                color: _selectedColor,
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
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            isDense: true,
          ),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
        ),

        const SizedBox(height: AppSpacing.lg),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
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

              const SizedBox(height: AppSpacing.md),

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
                          color: _isPaletteColor
                              ? context.theme.dividerColor
                              : context.colorScheme.onSurface,
                          width: _isPaletteColor ? 1 : 2,
                        ),
                      ),
                      child: Icon(
                        Icons.format_color_reset_outlined,
                        size: AppSize.iconMedium,
                        color: _isPaletteColor
                            ? context.theme.hintColor
                            : context.colorScheme.onSurface,
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
                        // The swatch was painted with the surface colour and
                        // never with the colour it stood for, so the whole row
                        // rendered as identical empty circles.
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? context.colorScheme.onSurface
                                : context.theme.dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: AppSize.iconSmall,
                                color: readableInkOn(color, dimAlpha: 0.87),
                              )
                            : null,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
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

              const SizedBox(height: AppSpacing.md),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ...projectIcons.map((candidate) {
                    final isSelected = _selectedEmoji == candidate.key;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedEmoji = candidate.key),
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withValues(alpha: AppAlpha.soft)
                              : context.colorScheme.surfaceContainer,
                          borderRadius: AppRadius.xsRadius,
                          border: isSelected
                              ? Border.all(color: _selectedColor, width: 1.5)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          isSelected ? candidate.selectedIcon : candidate.icon,
                          size: AppSize.iconMedium,
                          color: isSelected
                              ? _selectedColor
                              : context.colorScheme.onSurfaceVariant,
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
