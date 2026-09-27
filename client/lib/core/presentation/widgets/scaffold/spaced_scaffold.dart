import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:material_ui/material_ui.dart';

class SpacedScaffold extends StatelessWidget {
  const SpacedScaffold({
    required this.children,
    this.appBar,
    this.alignment = MainAxisAlignment.spaceBetween,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.xxl,
      vertical: AppSpacing.xl,
    ),
    this.spacing = 24.0,
    super.key,
  });

  final List<Widget> children;
  final PreferredSizeWidget? appBar;
  final MainAxisAlignment alignment;
  final EdgeInsetsGeometry padding;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ink.scaffold,
      appBar: appBar,
      body: _SafeScreenWrapper(
        padding: padding,
        child: Column(
          mainAxisAlignment: alignment,
          spacing: spacing,
          children: children,
        ),
      ),
    );
  }
}

class _SafeScreenWrapper extends StatelessWidget {
  const _SafeScreenWrapper({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(padding: padding, child: child),
          ),
        ],
      ),
    );
  }
}
