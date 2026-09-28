import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:material_ui/material_ui.dart';

class RecoveryPhraseDisplay extends StatelessWidget {
  const RecoveryPhraseDisplay({
    required this.phrase,
    super.key,
  });

  final List<String> phrase;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int rowIndex = 0; rowIndex < 4; rowIndex++) ...[
          Row(
            children: [
              for (int colIndex = 0; colIndex < 3; colIndex++) ...[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.8,
                    child: _WordCard(
                      number: (rowIndex * 3) + colIndex + 1,
                      word: phrase[(rowIndex * 3) + colIndex],
                    ),
                  ),
                ),

                if (colIndex < 2) const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),

          if (rowIndex < 3) const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({required this.number, required this.word});

  final int number;
  final String word;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.ink.container,
        borderRadius: AppRadius.smRadius,
        border: Border.all(
          color: context.colorScheme.primary.withValues(alpha: AppAlpha.medium),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: AppAlpha.faint),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            left: 6,
            child: Text(
              '$number',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.primary.withValues(
                  alpha: AppAlpha.strong,
                ),
              ),
            ),
          ),

          Center(
            child: Text(
              word,
              style: context.textTheme.labelMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
