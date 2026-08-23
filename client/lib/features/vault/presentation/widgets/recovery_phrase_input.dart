import 'package:flutter/material.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:ink/core/presentation/theme/tokens.dart';

class RecoveryPhraseInput extends StatefulWidget {
  const RecoveryPhraseInput({
    required this.onPhraseCompleted,
    required this.onPhraseIncomplete,
    super.key,
  });

  final ValueChanged<List<String>> onPhraseCompleted;
  final VoidCallback onPhraseIncomplete;

  @override
  State<RecoveryPhraseInput> createState() => _RecoveryPhraseInputState();
}

class _RecoveryPhraseInputState extends State<RecoveryPhraseInput> {
  final List<TextEditingController> _controllers = List.generate(
    12,
    (_) => TextEditingController(),
  );

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(_validateInputs);
    }
  }

  void _validateInputs() {
    final allFilled = _controllers.every((c) => c.text.trim().isNotEmpty);
    if (allFilled) {
      final words = _controllers.map((c) => c.text.trim()).toList();
      widget.onPhraseCompleted(words);
    } else {
      widget.onPhraseIncomplete();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

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
                    child: _InputCard(
                      number: (rowIndex * 3) + colIndex + 1,
                      controller: _controllers[(rowIndex * 3) + colIndex],
                    ),
                  ),
                ),

                if (colIndex < 2) const SizedBox(width: 10),
              ],
            ],
          ),

          if (rowIndex < 3) const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({required this.number, required this.controller});

  final int number;
  final TextEditingController controller;

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
                color: context.colorScheme.primary.withValues(alpha: AppAlpha.strong),
              ),
            ),
          ),

          Center(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                filled: false,
                hintText: context.t.vault.unlock.seed.wordHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
