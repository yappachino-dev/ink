import 'package:flutter/material.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';

class MetaIconButton extends StatelessWidget {
  const MetaIconButton({
    required this.icon,
    required this.onTap,
    this.label,
    this.isActive = false,
    this.activeColor,
    this.onClear,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isActive
        ? (activeColor ?? context.colorScheme.primary)
        : context.colorScheme.primary;

    if (label == null) {
      return GestureDetector(
        onTap: onTap,
        child: Icon(icon, size: 20, color: effectiveColor),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: effectiveColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: effectiveColor),

            const SizedBox(width: 4),

            Text(
              label!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: effectiveColor,
              ),
            ),

            if (onClear != null) ...[
              const SizedBox(width: 4),

              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 12, color: effectiveColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
