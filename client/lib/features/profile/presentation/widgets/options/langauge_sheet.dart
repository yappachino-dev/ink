import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/i18n/locale_notifier.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class LanguageSheet extends ConsumerWidget {
  const LanguageSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);

    return BottomSheetLayout(
      header: Text(
        context.t.profile.settings.language,
        style: context.textTheme.titleLarge,
      ),
      children: [
        ...AppLocale.values.map(
          (lang) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(lang.label, style: context.textTheme.titleMedium),
            trailing: current == lang
                ? Icon(
                    Icons.check,
                    size: AppSize.iconMedium,
                    color: context.colorScheme.primary,
                  )
                : null,
            onTap: () {
              unawaited(ref.read(localeProvider.notifier).changeLocale(lang));

              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}

extension AppLocaleLabel on AppLocale {
  String get label => switch (this) {
    AppLocale.en => 'English',
  };
}
