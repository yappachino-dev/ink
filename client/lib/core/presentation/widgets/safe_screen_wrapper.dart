import 'package:flutter/widgets.dart';
import 'package:ink/core/presentation/theme/tokens.dart';

class SafeScreenWrapper extends StatelessWidget {
  const SafeScreenWrapper({
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.xxl,
      vertical: AppSpacing.xl,
    ),
    super.key,
  });

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
