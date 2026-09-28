import 'package:ink/core/presentation/app_animations.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/presentation/widgets/notebooks/notebook_icon_view.dart';
import 'package:material_ui/material_ui.dart';

class NotebookItem extends StatelessWidget {
  const NotebookItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isSelected,
    this.onLongPress,
    this.count,
    super.key,
  });

  final String title;

  /// An icon key, or a legacy emoji glyph string.
  final String icon;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: AppAlpha.soft)
                : Colors.transparent,
            borderRadius: AppRadius.smRadius,
          ),
          child: Row(
            children: [
              NotebookIconView(value: icon, color: color),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: isSelected ? color : context.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),

              if (count != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$count',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.theme.hintColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
