import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/i18n/strings.g.dart';

class RecoveryVerifyForm extends StatefulWidget {
  const RecoveryVerifyForm({
    required this.indices,
    required this.isError,
    required this.onChanged,
    super.key,
  });

  final List<int> indices;
  final bool isError;
  final VoidCallback onChanged;

  @override
  State<RecoveryVerifyForm> createState() => RecoveryVerifyFormState();
}

class RecoveryVerifyFormState extends State<RecoveryVerifyForm>
    with SingleTickerProviderStateMixin {
  late final List<TextEditingController> _controllers;
  late final AnimationController _shakeController;

  Future<void> shake() => _shakeController.forward(from: 0);

  List<String> get values => _controllers.map((c) => c.text).toList();

  @override
  void initState() {
    super.initState();

    _controllers = List<TextEditingController>.generate(
      3,
      (_) => TextEditingController()..addListener(widget.onChanged),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();

    for (final c in _controllers) {
      c.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        if (widget.isError) ...[
          Text(
            context.t.vault.setup.seedVerify.error,
            style: textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),
        ],

        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final offset = sin(_shakeController.value * pi * 4) * 8;

            return Transform.translate(
              offset: Offset(widget.isError ? offset : 0, 0),
              child: child,
            );
          },
          child: Column(
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _NumberedField(
                  number: widget.indices[index] + 1,
                  isError: widget.isError,
                  controller: _controllers[index],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _NumberedField extends StatelessWidget {
  const _NumberedField({
    required this.number,
    required this.isError,
    required this.controller,
  });

  final int number;
  final bool isError;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 35,
          child: Text(
            '$number.',
            style: context.textTheme.titleLarge?.copyWith(
              color: context.colorScheme.primary,
            ),
          ),
        ),

        Expanded(
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: context.colorScheme.shadow.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: context.customColors.containerColor,
                hintText: context.t.vault.setup.seedVerify.inputHint,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: isError
                        ? context.colorScheme.error.withValues(alpha: 0.5)
                        : context.colorScheme.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: isError
                        ? context.colorScheme.error
                        : context.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
