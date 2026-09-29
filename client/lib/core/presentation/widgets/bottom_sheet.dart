import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:material_ui/material_ui.dart';

class BottomSheetLayout extends StatelessWidget {
  const BottomSheetLayout({
    required this.children,
    this.header,
    this.padding = const EdgeInsets.only(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      top: AppSpacing.md,
      bottom: AppSpacing.lg,
    ),
    this.padForKeyboard = false,
    this.showDivider = false,
    super.key,
  });

  final List<Widget> children;
  final Widget? header;
  final EdgeInsets padding;
  final bool padForKeyboard;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final bottomInset = padForKeyboard
        ? MediaQuery.viewInsetsOf(context).bottom
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: context.ink.surface,
        borderRadius: AppRadius.sheetTop,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: padding.add(EdgeInsets.only(bottom: bottomInset)),
          // One ink surface for the whole sheet. The Container above paints a
          // BoxDecoration and is not a Material, so every ListTile in every
          // sheet that used this layout was without an ancestor to paint its
          // splash into: no ripple, and a debug assert on some tiles. This was
          // previously fixed one tile at a time, in the reminder sheet only,
          // which left the priority, notebook, filter, view-mode and language
          // sheets broken. Transparent so the Container's colour still shows.
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BottomSheetLayoutDragHandle(),
                AppSpacing.gapLg,

                if (header != null) ...[header!, AppSpacing.gapSm],

                if (showDivider) ...[const _Divider(), AppSpacing.gapMd],

                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomSheetLayoutDragHandle extends StatelessWidget {
  const _BottomSheetLayoutDragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: AppSize.sheetHandleWidth,
        height: AppSize.sheetHandleHeight,
        decoration: BoxDecoration(
          color: context.theme.dividerColor,
          // `xsRadius` rather than a literal 2. The radius scale bottoms out at
          // 4, which is this handle's height, so the ends come out fully
          // rounded - the conventional drag handle - instead of the near-square
          // bar the 2 produced.
          borderRadius: AppRadius.xsRadius,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(color: context.theme.dividerColor, height: 1);
  }
}
