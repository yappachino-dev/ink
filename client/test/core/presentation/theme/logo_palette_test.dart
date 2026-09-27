// The mark is painted with a `CustomPainter` and reads its colour from the
// theme rather than hardcoding one. That only holds if it reads the *same*
// `Theme` the app installs, and `material_ui` is a decoupled fork carrying its
// own `Theme`, `ThemeData` and `ColorScheme` types. Importing
// `package:flutter/material.dart` in the painter silently reads Flutter's
// stock theme instead, which yields the Material 3 baseline purple for every
// palette and both brightnesses.
//
// Nothing caught this: the welcome golden recorded the bug as its baseline, so
// re-recording it on every change kept confirming it. This samples real pixels
// rather than a picture, so the value is readable in a failure.

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/core/presentation/widgets/app_logo.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final boundaryKey = GlobalKey();

  /// Renders the mark and returns the colour it actually painted with, taken
  /// from the most common opaque pixel against a known background.
  Future<Color> paintedColor(WidgetTester tester, ThemeData theme) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          // The debug banner is a red ribbon across the corner and would win
          // the most-common-pixel vote.
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: RepaintBoundary(
            key: boundaryKey,
            child: const ColoredBox(
              color: Color(0xFFFFFFFF),
              child: Center(child: AppLogo(size: LogoSize.large)),
            ),
          ),
        ),
      ),
    );
    // MaterialApp animates a theme change. Sampling before it settles reads
    // the *previous* theme, which would quietly make this test tautological.
    await tester.pumpAndSettle();

    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;

    final image = await tester.runAsync(boundary.toImage);
    // `toByteData` takes a required named argument, so it cannot be torn off
    // into `runAsync`'s zero-argument callback.
    final bytes = await tester.runAsync(() => image!.toByteData());
    image!.dispose();
    final data = bytes!.buffer.asUint8List();

    final counts = <int, int>{};
    for (var i = 0; i < data.length; i += 4) {
      // `rawRgba` is R, G, B, A in that byte order.
      final argb =
          (data[i + 3] << 24) |
          (data[i] << 16) |
          (data[i + 1] << 8) |
          data[i + 2];
      if (argb == 0xFFFFFFFF) continue; // the background we placed
      counts[argb] = (counts[argb] ?? 0) + 1;
    }

    expect(counts, isNotEmpty, reason: 'the mark painted nothing');
    final dominant = counts.entries.reduce((a, b) => a.value > b.value ? a : b);
    return Color(dominant.key);
  }

  testWidgets('the mark is painted in the palette colour', (tester) async {
    const m3Baseline = Color(0xFF6750A4);

    for (final palette in InkPalette.values) {
      final painted = await paintedColor(tester, AppTheme.light(palette));

      expect(
        painted,
        AppTheme.light(palette).colorScheme.primary,
        reason: '${palette.name} did not paint its own primary',
      );
      expect(
        painted,
        isNot(m3Baseline),
        reason: '${palette.name} fell back to the Material 3 baseline',
      );
    }
  });

  testWidgets('every palette paints a different mark', (tester) async {
    final seen = <Color, InkPalette>{};

    for (final palette in InkPalette.values) {
      seen[await paintedColor(tester, AppTheme.dark(palette))] = palette;
    }

    expect(
      seen,
      hasLength(InkPalette.values.length),
      reason: 'palettes collapsed onto the same colour: ${seen.values}',
    );
  });

  testWidgets('the mark follows the brightness', (tester) async {
    final light = await paintedColor(tester, AppTheme.light(InkPalette.forest));
    final dark = await paintedColor(tester, AppTheme.dark(InkPalette.forest));

    expect(light, isNot(dark));
  });
}
