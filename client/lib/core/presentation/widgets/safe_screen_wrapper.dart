import 'package:flutter/widgets.dart';

class SafeScreenWrapper extends StatelessWidget {
  const SafeScreenWrapper({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 20, 24, 24),
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
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
