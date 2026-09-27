import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/theme_notifier.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class AppearanceSheet extends ConsumerWidget {
  const AppearanceSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(themeProvider);

    final modeOptions = [
      (
        mode: ThemeMode.light,
        label: context.t.profile.settings.appearance.light,
        icon: Icons.light_mode_outlined,
      ),
      (
        mode: ThemeMode.dark,
        label: context.t.profile.settings.appearance.dark,
        icon: Icons.dark_mode_outlined,
      ),
      (
        mode: ThemeMode.system,
        label: context.t.profile.settings.appearance.system,
        icon: Icons.brightness_auto_outlined,
      ),
    ];

    return BottomSheetLayout(
      header: Text(
        context.t.profile.settings.appearance.title,
        style: context.textTheme.titleLarge,
      ),
      children: [
        ...modeOptions.map(
          (opt) => _OptionTile(
            icon: opt.icon,
            label: opt.label,
            selected: prefs.mode == opt.mode,
            onTap: () {
              unawaited(ref.read(themeProvider.notifier).setTheme(opt.mode));

              Navigator.pop(context);
            },
          ),
        ),

        AppSpacing.gapMd,

        Text('Theme', style: context.textTheme.titleMedium),
        AppSpacing.gapSm,

        Row(
          children: InkPalette.values
              .map(
                (palette) => Expanded(
                  child: _PaletteSwatch(
                    palette: palette,
                    selected: prefs.palette == palette,
                    onTap: () => unawaited(
                      ref.read(themeProvider.notifier).setPalette(palette),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected
        ? context.colorScheme.primary
        : context.theme.hintColor;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 24, color: accent),
      title: Text(label, style: context.textTheme.titleMedium),
      trailing: selected ? Icon(Icons.check, size: 20, color: accent) : null,
      onTap: onTap,
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final InkPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: palette.seed);

    return Tooltip(
      message: palette.label,
      child: InkWell(
        borderRadius: AppRadius.lgRadius,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smRadius,
            border: Border.all(
              color: selected
                  ? context.colorScheme.primary
                  : context.ink.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
              ),
              AppSpacing.gapXs,
              Text(
                palette.label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: selected
                      ? context.colorScheme.primary
                      : context.ink.onSurfaceMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
