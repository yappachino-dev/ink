import 'package:ink/core/presentation/app_animations.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:material_ui/material_ui.dart';

class ProjectItem extends StatelessWidget {
  const ProjectItem({
    required this.title,
    required this.emoji,
    required this.color,
    required this.onTap,
    required this.isSelected,
    this.onLongPress,
    this.count,
    super.key,
  });

  final String title;
  final String emoji;
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
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: AppAlpha.soft)
                : Colors.transparent,
            borderRadius: AppRadius.smRadius,
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),

              const SizedBox(width: 12),

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
                const SizedBox(width: 8),
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
