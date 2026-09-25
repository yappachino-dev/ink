import 'package:ink/core/presentation/widgets/app_logo.dart';
import 'package:material_ui/material_ui.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Text(title, style: textTheme.headlineSmall),
        ),

        const Expanded(
          child: Center(
            child: Opacity(opacity: 0.45, child: AppLogo(size: LogoSize.large)),
          ),
        ),
      ],
    );
  }
}
