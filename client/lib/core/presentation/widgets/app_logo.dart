import 'package:material_ui/material_ui.dart';

/// The Ink mark, drawn rather than shipped as a raster.
///
/// The previous implementation loaded `assets/images/logo.png`, a 168x159
/// raster. That caused three defects:
///
/// - It was blurry. At [LogoSize.large] the mark is drawn 160 logical pixels
///   wide, which needs 320 device pixels on a 2x display and 480 on a 3x one.
///   The source was 168 pixels, so it was upscaled ~1.9x on 2x and ~2.9x on 3x.
/// - Its light and dark variants were the same file, so the mark could not
///   respond to the theme at all.
/// - The source was 168x159 (not square) but rendered into a square box with
///   `BoxFit.contain`, so it was letterboxed and sat slightly high.
///
/// Painting the mark instead makes it resolution independent, genuinely
/// themeable, and square, and removes an asset from the bundle.
enum LogoSize {
  small(100),
  large(160);

  const LogoSize(this.edge);

  /// Width and height of the square canvas, in logical pixels.
  final double edge;
}

class AppLogo extends StatelessWidget {
  const AppLogo({
    required this.size,
    this.semanticLabel = 'App Logo',
    super.key,
  });

  final LogoSize size;

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Semantics(
      label: semanticLabel,
      image: true,
      child: SizedBox.square(
        dimension: size.edge,
        child: CustomPaint(painter: _LogoPainter(color)),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // The mark is authored against this canvas; all geometry below is derived
    // from `unit` so the painting scales cleanly to any [LogoSize].
    final unit = size.shortestSide;

    final stroke = unit * 0.038;
    final bodyInset = unit * 0.10;

    final bodyRect = Rect.fromLTWH(
      bodyInset,
      bodyInset * 1.35,
      unit - (bodyInset * 2),
      unit - (bodyInset * 2.4),
    );
    final bodyRadius = Radius.circular(unit * 0.07);

    final outline = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Calendar body: one continuous closed rounded rectangle. The badge is
    // painted afterwards as an opaque fill, so it masks the bottom-right corner
    // on its own. Cutting a gap in the stroke here instead leaves a dangling
    // stub where the path resumes.
    final body = Path()
      ..addRRect(
        RRect.fromRectAndRadius(bodyRect, bodyRadius),
      );

    canvas.drawPath(body, outline);

    // Binder rings. The pair sums to 1.0 so it straddles the body's midpoint;
    // at [0.26, 0.62] it summed to 0.88 and sat 4.8% of the canvas left of
    // centre, which reads as a misalignment rather than a design.
    for (final fraction in [0.32, 0.68]) {
      final x = bodyRect.left + bodyRect.width * fraction;
      canvas.drawLine(
        Offset(x, bodyRect.top - unit * 0.05),
        Offset(x, bodyRect.top + unit * 0.11),
        outline,
      );
    }

    // Header divider.
    canvas.drawLine(
      Offset(bodyRect.left, bodyRect.top + bodyRect.height * 0.30),
      Offset(bodyRect.right, bodyRect.top + bodyRect.height * 0.30),
      outline,
    );

    // Badge: an opaque rounded square painted over the body's bottom-right
    // corner, plus a checkmark on top.
    final badgeEdge = unit * 0.32;
    final badgeRect = Rect.fromLTWH(
      unit - badgeEdge - unit * 0.05,
      unit - badgeEdge - unit * 0.05,
      badgeEdge,
      badgeEdge,
    );
    final badgeRadius = Radius.circular(unit * 0.04);

    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, badgeRadius),
      Paint()..color = color,
    );

    final check = Path()
      ..moveTo(
        badgeRect.left + badgeRect.width * 0.22,
        badgeRect.top + badgeRect.height * 0.52,
      )
      ..lineTo(
        badgeRect.left + badgeRect.width * 0.42,
        badgeRect.top + badgeRect.height * 0.72,
      )
      ..lineTo(
        badgeRect.left + badgeRect.width * 0.78,
        badgeRect.top + badgeRect.height * 0.30,
      );

    canvas.drawPath(
      check,
      Paint()
        ..color = _onColor(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 1.05
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// Picks a legible checkmark colour for the badge, preferring the surface
  /// colour the mark sits on and falling back to a contrasting tone when the
  /// mark is itself close to a surface colour.
  Color _onColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
