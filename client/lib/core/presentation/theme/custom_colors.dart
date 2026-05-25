import 'package:flutter/material.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  CustomColors({
    required this.background,
    required this.onBackground,
    required this.containerColor,
  });

  final Color background;
  final Color onBackground;
  final Color containerColor;

  @override
  ThemeExtension<CustomColors> copyWith({
    Color? background,
    Color? onBackground,
    Color? containerColor,
  }) {
    return CustomColors(
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      containerColor: containerColor ?? this.containerColor,
    );
  }

  @override
  ThemeExtension<CustomColors> lerp(
    covariant ThemeExtension<CustomColors>? other,
    double t,
  ) {
    if (other is! CustomColors) return this;

    return CustomColors(
      background: Color.lerp(background, other.background, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      containerColor: Color.lerp(containerColor, other.containerColor, t)!,
    );
  }
}
