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
///
/// When the field *is* set the chip carries a second action, a clear button.
/// The two are separate semantics nodes: they are two actions, and collapsing
/// them into one labelled node is how the clear control ended up unreachable
/// by name.
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
    final color = isActive
        ? (activeColor ?? context.colorScheme.primary)
        : context.colorScheme.primary;

    final unset = Semantics(
      button: true,
      label: tooltip,
      // Declared rather than inherited: `excludeSemantics` drops descendant
      // actions, and with them the [InkWell]'s tap action, which left the
      // control announced as a button that did nothing when activated.
      onTap: onTap,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip,
        // The tooltip must not become the node a screen reader lands on; the
        // explicit label here is the name.
        excludeFromSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smRadius,
          // Not an [IconButton]. It has a hard 40px floor in this fork -
          // `constraints` and `styleFrom(minimumSize: 32)` both still measure
          // 40 - which made this row 40 tall against the 32px chip beside it,
          // so unset and set fields did not line up. 28 is below Material's
          // 48 preference but clears the WCAG 2.2 AA target-size floor of 24,
          // and each control keeps a name, a tooltip and a focus stop.
          child: SizedBox(
            width: AppSize.compactTapTarget,
            height: AppSize.compactTapTarget,
            child: Icon(icon, size: AppSize.iconMedium, color: color),
          ),
        ),
      ),
    );

    if (label == null) return unset;

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppAlpha.soft),
        borderRadius: AppRadius.smRadius,
        border: Border.all(color: color.withValues(alpha: AppAlpha.medium)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Siblings, not nested. The chip's node must not swallow the clear
          // button's, or the clear control is invisible to a screen reader
          // even though it is a separate tap target. Equally the [InkWell]
          // sits *inside* the labelled node rather than around it: wrapping
          // the whole chip in an [InkWell] gave the chip its own unlabelled
          // focus stop ahead of the real one.
          Semantics(
            button: true,
            label: '$tooltip: $label',
            // Declared here rather than inherited: `excludeSemantics` below
            // drops descendant semantics, and with it the [InkWell]'s tap
            // action, which left the chip announced as a button that did
            // nothing when activated.
            onTap: onTap,
            excludeSemantics: true,
            child: InkWell(
              onTap: onTap,
              borderRadius: AppRadius.smRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: AppSize.iconSmall, color: color),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      label!,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (onClear != null) ...[
            const SizedBox(width: AppSpacing.xs),

            // Deliberately not an [IconButton]. The chip sizes to its tallest
            // child and `IconButton` has a hard 40px floor in this fork -
            // `constraints` and `styleFrom(minimumSize: 32)` both still
            // measure 40 - so an icon-only clear button made every *set*
            // field 50px tall against the 32px Quill toolbar button directly
            // above it. Unset buttons keep the full target; this one sits
            // inside a chip that is already the primary target.
            Semantics(
              button: true,
              label: context.t.common.remove,
              child: Tooltip(
                message: context.t.common.remove,
                // The tooltip must not become the node a screen reader lands
                // on; the explicit label here is the name.
                excludeFromSemantics: true,
                child: InkWell(
                  onTap: onClear,
                  borderRadius: AppRadius.smRadius,
                  child: SizedBox(
                    width: AppSize.compactTapTarget,
                    height: AppSize.compactTapTarget,
                    child: Icon(
                      Icons.close,
                      size: AppSize.iconSmall,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
