# Theming

Ink uses semantic Material 3 roles with per-brightness generated schemes.
This page describes the implemented system.

## Runtime architecture

- `core/presentation/theme/app_theme.dart` builds light and dark `ThemeData` as sibling modes from the Ink brand seed through FlexColorScheme 9 and the decoupled `material_ui` APIs.
- `core/presentation/theme/palettes.dart` defines Forest, Ocean, Dusk, and Ember palette options. Adding a palette requires a corresponding contrast-test case.
- `core/presentation/theme/ink_colors.dart` and `theme_extensions.dart` hold Ink-specific semantic roles such as scrims, highlights, shadows, and status colors.
- `core/presentation/theme/tokens.dart` centralizes spacing, radii, alpha, effects, and layout constants.
- Widgets consume `Theme.of(context)` roles or `InkColors`; they should not branch on platform brightness or use raw light/dark literals for semantic colors.
- `TableCalendar` remains behind a small SDK `Material` compatibility wrapper because its current release still uses Flutter SDK Material widgets.
- User palette selection is persisted through `UserConfig` and consumed by the appearance settings screen.
- Inter is bundled under `client/assets/fonts/inter/` and registered in `client/lib/main.dart` so rendering does not depend on network font fetching.

## Guardrails

### Contrast tests

`client/test/core/presentation/theme/theme_contrast_test.dart` checks every `InkPalette` in both brightnesses. Material and Ink content roles must meet WCAG AA contrast (4.5:1 for normal text).

When adding or changing a palette or semantic role:

1. Add or update the palette case if needed.
2. Run the contrast test.
3. Correct token values rather than weakening the threshold.

### Paired goldens

`client/test/core/presentation/theme/theme_golden_test.dart` stores paired light/dark baselines for:

- Home
- Calendar
- Note editor
- Vault setup

Goldens disable runtime Google Fonts fetching, explicitly load Material Icons, and inject a fixed calendar date. Update baselines only for an intentional, reviewed visual change:

```bash
cd client
flutter test test/core/presentation/theme/theme_golden_test.dart --update-goldens
```

Review the resulting PNGs in both brightnesses before committing them.

Two known limits of this net:

- `profile.png`, `vault-setup.png`, and `welcome.png` exist, but the auth,
  email-verification, and unlock screens still have no baseline, and neither do
  bottom sheets. Changes to those surfaces ship without visual verification.
- The notes baseline file is still `goldens/home.png`. It was renamed with the
  rest of the Home -> Notes vocabulary in PR #82, but the file was left alone to
  keep that PR's goldens byte-identical. `NotesScreen` is what it renders.

Re-record only the goldens affected by a change, in the same PR as the change,
so a bad restyle stays attributable.

## Review rules

- Add or reuse a semantic role before introducing another one-off alpha blend.
- Do not use `Colors.black` or `Colors.white` as application surface/text tokens.
- Do not derive dark mode by mechanically inverting light-mode values.
- Keep palettes mode-aware; the same raw brand literal is not automatically valid on both surfaces.
- Any palette change must pass contrast and relevant paired golden tests.

### `InkColors.chrome`

Non-editable chrome that sits directly against editable content: the editor's
bottom bar (meta row + formatting toolbar). One step of M3 container away from
`surface`, chosen per brightness.

| | note surface | chrome | direction |
| --- | --- | --- | --- |
| light | `#fcfcfc` | `#f3f3f3` | chrome is darker |
| dark | `#151515` | `#1d1d1d` | chrome is lighter |

It cannot be a fixed `colorScheme.surfaceContainer`. `InkColors.surface` is
already `surfaceContainer` in dark, so a fixed chrome would have been *identical*
to the note surface in dark - an invisible tint in exactly the theme where the
scaffold/toolbar band bug was visible.

`chrome_surface_test.dart` asserts a measurable separation (>= 1.06:1) in every
palette and both brightnesses. `surfaceContainerLow` fails it at 1.035:1 in
light. A golden would not: it records whatever is there.

Two rules this token exists to enforce:

- The bar's background and `QuillSimpleToolbar`'s own `color` must be the same
  token. Quill paints its own background, so a different value is a band inside
  the bar.
- The bar's background paints *outside* its `SafeArea`, so it runs through the
  bottom inset. See `Container` vs `DecoratedBox` in the workflow notes: the
  `Container` is also what insets the child by the border width and keeps the
  1px top divider visible.

`chrome` and `container` are separate roles that may share a value in one
brightness; that is fine and nothing asserts otherwise.

### The editor has two zones, not three

```text
note text    ink.surface    editable - the only place in the app with a cursor
-----------  outlineVariant
meta row     ink.surface    buttons showing note structure
-----------  outlineVariant
toolbar      ink.chrome     formatting controls
```

The meta row sits on the **note surface**, not on the chrome. It shows note
structure, and putting it on the note's own surface lets the note read as one
continuous rectangle from its text through its metadata. It stays a row of
buttons, so it is not "editable" either - the boundary between typing and
tapping is the hairline above it, not the tint.

That hairline is load-bearing and is held to `outlineVariant`, the same token
as the toolbar's own top border. It was `dividerColor`, which measured 1.14:1
against the surface in light and came out fainter than the border between the
two *non-editable* rows below it - the one line in the editor whose job was to
mark a real boundary was the weakest line in the layout.

**When this should flip:** if the meta row ever shows note *content* rather
than controls - a preview, tags, an inline summary - tinting it would be a
lie and it should move to `chrome`. `editor_bottom_chrome_test.dart` asserts
the meta row paints no surface of its own, so the flip has to be deliberate.

### `AppSpacing.scaffold` and `AppSpacing.sheetRows`

`AppSpacing.screen` is horizontal-only and is used by screens that scroll to
their edges. Three scaffolds and the personalization sheet each spelled out the
same `24/20/24/24` by hand, while the doc on `screen` claimed *they* used it -
so the token and the reality disagreed and a gutter change would have missed
every scaffold. That is now one `AppSpacing.scaffold`.

`AppSpacing.sheetRows` is the `20/20/12/16` block that the priority, project,
notebook-filter and reminder sheets each wrote out. It is wider than
`BottomSheetLayout`'s own default, which is what sheets without rows still use.

### The sheet supplies the ink surface once

`ListTile` paints its splash on the nearest `Material`. `BottomSheetLayout`
paints its background through a `BoxDecoration` and is not one, so every tile
built on it had no ink surface. This was fixed once, in the reminder picker, by
wrapping that single tile - leaving priority, project, filter, view-mode and
language sheets with the same missing ripple and the same debug assert. It is now
one transparent `Material` in the shared layout, so a new tile gets a ripple
without knowing it exists.

### `AppSpacing.fabInset` and the one floating action button

Notes and Calendar each built their own `FloatingActionButton` and they drifted
three ways: the inset from the edge, the elevation, and the colours. The inset
was user-visible - Notes placed its by hand at 20px, Calendar used the Scaffold
slot, whose end-float location hard-codes 16px - so **the button jumped 4px
when switching tabs**.

Both now use `AppFab`, placed with `AppFabLocation`, which reads
`AppSpacing.fabInset` (= `gutter`). One widget, one location, one token: a
change to that constant moves every screen's button together.

`AppFabLocation` extends `StandardFabLocation` with the fork's `FabEndOffsetX`
and `FabFloatOffsetY` mixins and overrides `getOffsetX`/`getOffsetY` to swap
`kFloatingActionButtonMargin` for the token. Note this fork's location API is
`Offset getOffset(ScaffoldPrelayoutGeometry)`, not stock Flutter's
`getOffsetFor(Size, Size)`.

`getOffsetY` anchors to `contentBottom` rather than the scaffold height, because
the navigation bar belongs to an *outer* Scaffold: the inner one ends at the top
of that bar, so the slot lands exactly where a hand-placed bottom inset would.

Notes keeps its drawer-open animation (scale and opacity to zero) inside the
slot. At scale zero the button has no hit area, so an open drawer cannot have
the invisible button swallow taps meant for the scrim.
