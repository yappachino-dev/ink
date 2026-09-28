import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/contrast.dart';
import 'package:ink/core/presentation/theme/ink_colors.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:material_ui/material_ui.dart';

/// The editor's chrome must be visibly different from the note surface.
///
/// This is the assertion that was missing when the toolbar and the scaffold
/// disagreed in dark only, and it is deliberately *not* a golden. A golden
/// records whatever was there, so it confirms a 4-step near-miss as readily as
/// it catches one - which is how that bug, and a 40px gap rendered as 4px,
/// both passed a green suite.
///
/// A tint too small to notice is not a tint. `surfaceContainerLow` is four
/// steps off the surface in light, close enough to the near-identical greys
/// that read as a rendering fault. So the floor is a measurable one.
void main() {
  // Resolving a theme builds a GoogleFonts text theme, which reaches for both
  // the binding and the network. The golden test does the same.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const minSeparation = 1.06;

  for (final palette in InkPalette.values) {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      final tokens = palette.inkFor(brightness);
      final name = '${palette.name} $brightness';

      group(name, () {
        test('chrome is measurably distinct from the note surface', () {
          final separation = contrastRatio(tokens.chrome, tokens.surface);
          expect(
            separation,
            greaterThanOrEqualTo(minSeparation),
            reason:
                'chrome #${tokens.chrome.toARGB32().toRadixString(16)} is too '
                'close to surface '
                '#${tokens.surface.toARGB32().toRadixString(16)} to read as '
                'a deliberate tint',
          );
        });

        test('content on chrome still meets the text bar', () {
          expect(
            contrastRatio(tokens.onSurface, tokens.chrome),
            greaterThanOrEqualTo(4.5),
            reason: 'labels and icons on the toolbar must stay readable',
          );
        });
      });
    }
  }

  // `chrome` and `container` are separate roles that may legitimately share a
  // value in one brightness - in dark both resolve to `surfaceContainerHigh`.
  // Nothing asserts they differ in colour, because that would be asserting a
  // coincidence rather than a requirement. The requirement is only that
  // chrome differs from the surface it sits against, which is asserted above.
}

/// Resolves a palette's [InkColors] for a brightness by going through the
/// real theme, so the test cannot drift from what the app actually builds.
extension on InkPalette {
  InkColors inkFor(Brightness brightness) {
    final theme = brightness == Brightness.dark
        ? AppTheme.dark(this)
        : AppTheme.light(this);
    return theme.extension<InkColors>()!;
  }
}
