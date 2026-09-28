import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/back_app_bar.dart';
import 'package:ink/core/presentation/widgets/safe_screen_wrapper.dart';
import 'package:material_ui/material_ui.dart';

class FlowScaffold extends StatelessWidget {
  const FlowScaffold({
    required this.body,
    this.showAppBar = true,
    this.padding = const EdgeInsets.only(
  left: AppSpacing.xxl,
  right: AppSpacing.xxl,
  top: AppSpacing.xl,
  bottom: AppSpacing.xxl,
),
    super.key,
  });

  final Widget body;
  final bool showAppBar;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surfaceContainer,
      appBar: showAppBar ? const BackAppBar() : null,
      body: SafeScreenWrapper(padding: padding, child: body),
    );
  }
}
