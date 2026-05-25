import 'package:flutter/material.dart';
import 'package:ink/core/presentation/theme/custom_colors.dart';

extension ThemeBuildContextEntension on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  CustomColors get customColors => theme.extension<CustomColors>()!;

  bool get isLight => theme.brightness == Brightness.light;
  bool get isDark => theme.brightness == Brightness.dark;
}

extension EmptyTextStyleExtenions on TextStyle? {
  TextStyle get orEmpty => this ?? const TextStyle();
}
