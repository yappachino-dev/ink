import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/i18n/strings.g.dart';

class CompletedSection extends ConsumerWidget {
  const CompletedSection({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(completedExpnadedProvider);

    return Container(
      decoration: BoxDecoration(
        color: context.customColors.containerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: ref.read(completedExpnadedProvider.notifier).toggle,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(
                    context.t.home.completed,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.theme.hintColor,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    '${children.length}',
                    style: context.textTheme.bodySmall,
                  ),

                  const SizedBox(width: 6),

                  AnimatedRotation(
                    turns: isExpanded ? 0 : -0.5,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: context.theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: Column(children: children),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
