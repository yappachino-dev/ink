import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

/// A note's metadata affordance: due date, notebook, priority, reminder.
///
/// Every one of these is icon-only until it is set, and an icon on its own has
/// no accessible name - a screen reader announced "button" four times in a row
/// in the editor's meta bar. [tooltip] is therefore required: it is the name,
/// and Material supplies focus, a ripple and the minimum tap target that a
/// bare [GestureDetector] did not.
class MetaIconButton extends StatelessWidget {
  const MetaIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.label,
    this.isActive = false,
    this.activeColor,
    this.onClear,
    super.key,
  });

  final IconData icon;

  /// The accessible name. Shown on hover and long-press, and announced.
  final String tooltip;

  final VoidCallback onTap;

  /// The current value, or null when the field is unset and the button is
  /// icon-only.
  final String? label;

  final bool isActive;
  final Color? activeColor;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isActive
        ? (activeColor ?? context.colorScheme.primary)
        : context.colorScheme.primary;

    final button = label == null
        ? IconButton(
            onPressed: onTap,
            icon: Icon(icon, size: AppSize.iconMedium),
            color: effectiveColor,
            tooltip: tooltip,
            // IconButton defaults to 48dp, which is taller than this bar; the
            // density keeps the row compact without going under the floor.
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(
              minWidth: AppSize.minTapTarget,
              minHeight: AppSize.minTapTarget,
            ),
          )
        : Tooltip(
            message: tooltip,
            child: InkWell(
              onTap: onTap,
              borderRadius: AppRadius.smRadius,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: AppAlpha.soft),
                  borderRadius: AppRadius.smRadius,
                  border: Border.all(
                    color: effectiveColor.withValues(alpha: AppAlpha.medium),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: AppSize.iconSmall, color: effectiveColor),

                    const SizedBox(width: AppSpacing.xs),

                    Text(
                      label!,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: effectiveColor,
                      ),
                    ),

                    if (onClear != null) ...[
                      const SizedBox(width: AppSpacing.xs),

                      // A separate control, not a tap target nested inside the
                      // parent's: a single tap has to resolve to one action.
                      IconButton(
                        onPressed: onClear,
                        icon: const Icon(Icons.close, size: AppSize.iconSmall),
                        color: effectiveColor,
                        tooltip: context.t.common.remove,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: AppSize.minTapTarget,
                          minHeight: AppSize.minTapTarget,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );

    return Semantics(
      button: true,
      label: label == null ? tooltip : '$tooltip: $label',
      excludeSemantics: true,
      child: button,
    );
  }
}
