import 'package:flutter/material.dart';
import 'package:ink/core/presentation/app_animations.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';

class UnlockMethod extends StatelessWidget {
  const UnlockMethod({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final containerColor = context.ink.container;
    final borderColor = isSelected
        ? context.colorScheme.primary
        : context.colorScheme.primary.withValues(alpha: AppAlpha.soft);

    return AnimatedContainer(
      margin: const EdgeInsets.only(bottom: 12),
      duration: AppDurations.base,
      width: double.infinity,
      decoration: BoxDecoration(
        color: containerColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: AppRadius.lgRadius,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: context.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
