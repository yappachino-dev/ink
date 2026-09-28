import 'package:flutter/widgets.dart';
import 'package:ink/core/presentation/theme/tokens.dart';

class SafeScreenWrapper extends StatelessWidget {
  const SafeScreenWrapper({
    required this.child,
    this.padding = const EdgeInsets.only(
  left: AppSpacing.xxl,
  right: AppSpacing.xxl,
  top: AppSpacing.xl,
  bottom: AppSpacing.xxl,
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
