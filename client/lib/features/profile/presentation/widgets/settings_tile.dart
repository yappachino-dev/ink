import 'package:flutter/material.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.title,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.showArrow = true,
    super.key,
  });

  final IconData? icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: context.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
            ],

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textTheme.titleMedium),

                  if (subtitle != null) ...[
                    const SizedBox(height: 2),

                    Text(subtitle!, style: context.textTheme.bodySmall),
                  ],
                ],
              ),
            ),

            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: context.theme.hintColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
