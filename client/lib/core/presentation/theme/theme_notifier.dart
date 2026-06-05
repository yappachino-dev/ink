import 'package:flutter/material.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_notifier.g.dart';

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    final savedThemeString = ref.watch(userPreferencesProvider).themeModeString;

    return _fromString(savedThemeString);
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;

    await ref.read(userPreferencesProvider).setThemeModeString(_toString(mode));
  }

  static String _toString(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  static ThemeMode _fromString(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
