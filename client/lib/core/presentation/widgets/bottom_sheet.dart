import 'package:flutter/material.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';

class BottomSheetLayout extends StatelessWidget {
  const BottomSheetLayout({
    required this.children,
    this.header,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
        color: context.customColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: padding.add(EdgeInsets.only(bottom: bottomInset)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BottomSheetLayoutDragHandle(),
              const SizedBox(height: 16),

              if (header != null) ...[
                header!,
                const SizedBox(height: 8),
              ],

              if (showDivider) ...[
                const _Divider(),
                const SizedBox(height: 12),
              ],

              ...children,
            ],
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
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.theme.dividerColor,
          borderRadius: BorderRadius.circular(2),
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
