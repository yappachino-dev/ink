import 'package:ink/core/presentation/app_animations.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

/// How far through vault creation the user is.
///
/// The setup flow creates an encryption key and then asks the user to write
/// down a recovery phrase. Without a position marker a five-screen flow gives
/// no signal about how much is left, and no signal at all about the step that
/// actually matters - the one where losing the phrase loses the data.
class SetupProgress extends StatelessWidget {
  const SetupProgress({required this.step, required this.total, super.key});

  /// One-based position of the current screen.
  final int step;

  /// Screens in the flow, including this one.
  final int total;

  @override
  Widget build(BuildContext context) {
    final remaining = total - step;
    final label = remaining == 0
        ? context.t.vault.progressLast
        : context.t.vault.progressRemaining(count: remaining);

    return Semantics(
      label: context.t.vault.progressSemantic(current: step, total: total),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t.vault.progressStep(current: step, total: total),
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.ink.onSurfaceMuted,
                ),
              ),
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.ink.onSurfaceMuted,
                ),
              ),
            ],
          ),

          AppSpacing.gapSm,

          // A bar rather than dots: it reads as progress, and the segment
          // widths survive large text scales where equal dots would crowd.
          Row(
            children: [
              for (var i = 1; i <= total; i++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    height: AppSize.iconSmall * 0.5,
                    decoration: BoxDecoration(
                      color: i <= step
                          ? context.colorScheme.primary
                          : context.ink.outline,
                      borderRadius: AppRadius.xsRadius,
                    ),
                  ),
                ),
                if (i != total) const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
