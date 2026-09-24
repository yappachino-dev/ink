import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/ink_colors.dart';
import 'package:ink/core/presentation/theme/palettes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final palette in InkPalette.values) {
    for (final brightness in Brightness.values) {
      final label = '${palette.id} ${brightness.name}';

      testWidgets('$label maintains WCAG AA contrast for content tokens', (
        tester,
      ) async {
        final theme = brightness == Brightness.dark
            ? AppTheme.dark(palette)
            : AppTheme.light(palette);
        final colors = theme.colorScheme;
        final ink = theme.extension<InkColors>()!;

        _expectContrast(
          label,
          foreground: colors.onSurface,
          background: colors.surface,
        );
        _expectContrast(
          label,
          foreground: colors.onSurface,
          background: ink.scaffold,
        );
        _expectContrast(
          label,
          foreground: colors.onSurfaceVariant,
          background: colors.surface,
        );
        _expectContrast(
          label,
          foreground: colors.onSurface,
          background: ink.container,
        );
        _expectContrast(
          label,
          foreground: colors.onSurfaceVariant,
          background: ink.container,
        );
        _expectContrast(
          label,
          foreground: colors.primary,
          background: colors.surface,
        );
        _expectContrast(
          label,
          foreground: colors.onPrimary,
          background: colors.primary,
        );
        _expectContrast(
          label,
          foreground: colors.onSecondary,
          background: colors.secondary,
        );
        _expectContrast(
          label,
          foreground: colors.onTertiary,
          background: colors.tertiary,
        );
        _expectContrast(
          label,
          foreground: colors.onError,
          background: colors.error,
        );
        _expectContrast(
          label,
          foreground: colors.onSurface,
          background: Color.alphaBlend(ink.highlight, colors.surface),
        );
      });
    }
  }
}

void _expectContrast(
  String label, {
  required Color foreground,
  required Color background,
}) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  final ratio = (lighter + 0.05) / (darker + 0.05);

  expect(
    ratio,
    greaterThanOrEqualTo(4.5),
    reason: '$label failed WCAG AA contrast: ${ratio.toStringAsFixed(2)}:1',
  );
}
