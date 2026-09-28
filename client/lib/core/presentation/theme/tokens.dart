import 'package:ink/core/presentation/theme/ink_colors.dart' show InkColors;
import 'package:material_ui/material_ui.dart';

/// Corner radii. The scale is intentionally coarse — pick the closest role
/// instead of inventing a new value.
abstract final class AppRadius {
  /// Hairline chips and tiny accents.
  static const double xs = 4;

  /// Small controls: drag handles, badges, mini buttons.
  static const double sm = 12;

  /// Text fields and inner surfaces.
  static const double md = 16;

  /// Cards and primary containers. The dominant app-wide radius.
  static const double lg = 20;

  /// Bottom sheets.
  static const double sheet = 24;

  /// Fully rounded pills (buttons, chips).
  static const double pill = 40;

  /// Pre-built [BorderRadius] objects — const-safe for decoration contexts.
  static const BorderRadius xsRadius = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));

  /// Top-only radius for bottom sheets.
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}

/// Spacing multiples. All gaps/paddings should snap to this scale.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  static const SizedBox gapXs = SizedBox(height: xs);
  static const SizedBox gapSm = SizedBox(height: sm);
  static const SizedBox gapMd = SizedBox(height: md);
  static const SizedBox gapLg = SizedBox(height: lg);
  static const SizedBox gapXl = SizedBox(height: xl);
  static const SizedBox gapXxl = SizedBox(height: xxl);

  /// Inset from the trailing and bottom edges for the floating action button.
  ///
  /// Notes and Calendar each placed their own button and the two disagreed by
  /// 4px, so the button visibly jumped when switching tabs. The Scaffold's
  /// built-in end-float location hard-codes its own margin, so `AppFabLocation`
  /// reads this instead and every screen's button moves together.
  static const double fabInset = gutter;

  /// The app's single screen gutter.
  ///
  /// Three screens had their own horizontal margins - the notes list used 16,
  /// the calendar 20 - so the same card was a different width depending on
  /// which tab it was in. [xl] is the value the calendar and the journal
  /// already used, and it is the larger of the two, so content loses width
  /// rather than gains it.
  static const double gutter = xl;

  /// Standard screen edge padding used by screens that scroll to the edges.
  ///
  /// Horizontal only, and *not* what the scaffolds use: a scaffold has to clear
  /// its own app bar, so its padding is [scaffold].
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: gutter);

  /// Content padding for a scaffold body: wider than [gutter] on the sides and
  /// inset from the app bar.
  ///
  /// Four screens (three scaffolds plus the personalization sheet) each spelled
  /// this same 24/20/24/24 out by hand, and the doc on [screen] claimed *they*
  /// used it - so the token and the reality disagreed, and changing the gutter
  /// would have silently missed every scaffold. One name, one value.
  static const EdgeInsets scaffold = EdgeInsets.only(
    left: xxl,
    right: xxl,
    top: xl,
    bottom: xxl,
  );

  /// Standard content padding for cards and sheets.
  static const EdgeInsets card = EdgeInsets.all(lg);

  /// Content padding for a sheet that holds a full-width list of rows.
  ///
  /// The pickers (priority, notebook, notebook filter) each spelled this out;
  /// they are the same three-line `EdgeInsets.only` in four files. It is wider
  /// than the `BottomSheetLayout` default, which is what sheets without rows
  /// still use.
  static const EdgeInsets sheetRows = EdgeInsets.only(
    left: xl,
    right: xl,
    top: md,
    bottom: lg,
  );

  /// A settings-style row: the app's most repeated container.
  static const EdgeInsets row = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: lg,
  );

  /// The gap between consecutive cards in a list.
  static const EdgeInsets listGap = EdgeInsets.only(bottom: sm);
}

/// Opacity steps for color derivations. Use with [Color.withValues] when a
/// one-off alpha is truly needed; prefer [InkColors] roles otherwise.
abstract final class AppAlpha {
  /// Barely-there washes (track fills, subtle dividers).
  static const double faint = 0.05;

  /// Soft tints (selection backgrounds, hover washes).
  static const double soft = 0.12;

  /// De-emphasized but clearly visible content.
  static const double medium = 0.5;

  /// Emphasized decorative content.
  static const double strong = 0.7;
}

/// Icon sizes and a few fixed component dimensions.
///
/// These lived in a separate `app_sizes.dart` imported as `sizes`, which made
/// them read as a second, competing scale next to [AppSpacing] and [AppRadius].
/// They are here now so there is one place to look.
abstract final class AppSize {
  /// The floating action button's diameter.
  ///
  /// Material's `kFloatingActionButtonSize`, named here because the app imports
  /// the decoupled `material_ui` fork, which does not export it. The button and
  /// the scroll clearance under it have to agree, so the number is stated once.
  static const double fab = 56;

  /// Inline glyphs: meta row labels, badge marks.
  static const double iconSmall = 14;

  /// Default glyph size for list rows and settings tiles.
  static const double iconMedium = 20;

  /// Prominent standalone glyphs.
  static const double iconLarge = 24;

  /// The largest glyph, used for empty states and headers.
  static const double iconXLarge = 28;

  /// Minimum tap target. Material's own floor is 48, which does not fit the
  /// dense rows this app uses, so interactive glyphs are floored here instead.
  static const double minTapTarget = 44;

  /// Tap target for a control nested *inside* another target.
  ///
  /// The [minTapTarget] floor assumes the control is the only way to reach
  /// its action. A clear button inside a chip is not: the chip's whole area
  /// opens the picker. At 44 the chip grows to 52 tall - taller than the
  /// editor chrome it sits above - so the row stopped reading as one bar.
  static const double compactTapTarget = 30;

  /// A full-width action button.
  static const Size buttonHeight = Size(double.infinity, 48);

  /// A full-width action button on a primary surface.
  static const Size buttonHeightLarge = Size(double.infinity, 56);
}

/// Blur sigmas for backdrop filters.
abstract final class AppEffects {
  /// Backdrop blur behind scrims and floating bars.
  static const double blurSm = 3;

  /// Stronger blur behind full-screen overlays.
  static const double blurLg = 4;
}

/// Layout constraints that encode product-level geometry rules.
abstract final class AppLayout {
  /// Navigation drawer width as a fraction of screen width.
  static const double drawerWidthRatio = 0.82;

  /// Calendar range boundaries.
  static DateTime get calendarFirstDay => DateTime.utc(2020);
  static DateTime get calendarLastDay => DateTime.utc(2030, 12, 31);
}
