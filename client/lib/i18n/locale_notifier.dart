import 'dart:async';

import 'package:ink/core/config/user_config.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_notifier.g.dart';

@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  @override
  AppLocale build() => LocaleSettings.currentLocale;

  Future<void> changeLocale(AppLocale newLocale) async {
    final saveFuture = ref
        .read(userPreferencesProvider)
        .setLocaleCode(newLocale.languageTag);

    await LocaleSettings.setLocale(newLocale);

    state = newLocale;

    await saveFuture;
  }
}
