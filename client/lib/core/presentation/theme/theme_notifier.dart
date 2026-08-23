import 'package:flutter/material.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_notifier.g.dart';

class ThemePreferences {
  const ThemePreferences({this.mode = ThemeMode.system, this.palette = InkPalette.forest});

  final ThemeMode mode;
  final InkPalette palette;

  ThemePreferences copyWith({ThemeMode? mode, InkPalette? palette}) =>
      ThemePreferences(
        mode: mode ?? this.mode,
        palette: palette ?? this.palette,
      );
}

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemePreferences build() {
    final prefs = ref.watch(userPreferencesProvider);

    return ThemePreferences(
      mode: _modeFromString(prefs.themeModeString),
      palette: InkPalette.byId(prefs.paletteIdString),
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = state.copyWith(mode: mode);

    await ref.read(userPreferencesProvider).setThemeModeString(_toString(mode));
  }

  Future<void> setPalette(InkPalette palette) async {
    state = state.copyWith(palette: palette);

    await ref.read(userPreferencesProvider).setPaletteIdString(palette.id);
  }

  static String _toString(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  static ThemeMode _modeFromString(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
