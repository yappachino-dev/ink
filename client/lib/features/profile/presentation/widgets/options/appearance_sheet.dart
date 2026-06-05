import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/theme_notifier.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/i18n/strings.g.dart';

class AppearanceSheet extends ConsumerWidget {
  const AppearanceSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeProvider);

    final options = [
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
        ...options.map(
          (opt) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              opt.icon,
              size: sizes.iconLarge,
              color: current == opt.mode
                  ? context.colorScheme.primary
                  : context.theme.hintColor,
            ),
            title: Text(opt.label, style: context.textTheme.titleMedium),
            trailing: current == opt.mode
                ? Icon(
                    Icons.check,
                    size: sizes.iconMedium,
                    color: context.colorScheme.primary,
                  )
                : null,
            onTap: () {
              unawaited(ref.read(themeProvider.notifier).setTheme(opt.mode));

              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
