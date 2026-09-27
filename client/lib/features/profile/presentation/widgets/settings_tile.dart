import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:material_ui/material_ui.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.title,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.subtitleColor,
    this.showArrow = true,
    super.key,
  });

  final IconData? icon;
  final String title;
  final String? subtitle;

  /// Overrides the muted subtitle colour, for a status that has to read as a
  /// status rather than as an aside.
  final Color? subtitleColor;
  final VoidCallback onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgRadius,
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
                  size: AppSize.iconMedium,
                  color: context.colorScheme.primary,
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

                    Text(
                      subtitle!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (showArrow)
              Icon(
                Icons.chevron_right,
                size: AppSize.iconMedium,
                color: context.theme.hintColor,
              ),
          ],
        ),
      ),
    );
  }
}
