import 'package:flutter/material.dart';
import 'package:ink/core/presentation/theme/ink_colors.dart';

extension ThemeBuildContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  /// Semantic Ink design tokens. Prefer these over raw scheme colors.
  InkColors get ink => theme.extension<InkColors>()!;

  bool get isLight => theme.brightness == Brightness.light;
  bool get isDark => theme.brightness == Brightness.dark;
}

extension EmptyTextStyleExtension on TextStyle? {
  TextStyle get orEmpty => this ?? const TextStyle();
}
