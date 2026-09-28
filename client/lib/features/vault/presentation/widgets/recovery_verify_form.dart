import 'dart:math';

import 'package:ink/core/presentation/app_animations.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class RecoveryVerifyForm extends StatefulWidget {
  const RecoveryVerifyForm({
    required this.indices,
    required this.isError,
    required this.onChanged,
    super.key,
  });

  final List<int> indices;
  final bool isError;
  final ValueChanged<List<String>> onChanged;

  @override
  State<RecoveryVerifyForm> createState() => RecoveryVerifyFormState();
}

class RecoveryVerifyFormState extends State<RecoveryVerifyForm>
    with SingleTickerProviderStateMixin {
  late final List<TextEditingController> _controllers;
  late final AnimationController _shakeController;

  List<String> get values =>
      _controllers.map((c) => c.text.trim().toLowerCase()).toList();

  void _onTextChanged() => widget.onChanged(values);

  @override
  void initState() {
    super.initState();

    _controllers = List<TextEditingController>.generate(
      widget.indices.length,
      (_) => TextEditingController()..addListener(_onTextChanged),
    );

    _shakeController = AnimationController(
      duration: AppDurations.slow,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant RecoveryVerifyForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isError && !oldWidget.isError) {
      _shakeController.forward(from: 0);
    }
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
        Visibility(
          visible: widget.isError,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Text(
            context.t.vault.setup.seedVerify.error,
            style: textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final offset = sin(_shakeController.value * pi * 3) * 8;

            return Transform.translate(
              offset: Offset(offset, 0),
              child: child,
            );
          },
          child: Column(
            children: List.generate(widget.indices.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _NumberedField(
                  number: widget.indices[index] + 1,
                  isError: widget.isError,
                  controller: _controllers[index],
                  isLast: index == widget.indices.length - 1,
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
    required this.isLast,
  });

  final int number;
  final bool isError;
  final TextEditingController controller;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    const borderRadius = 20.0;
    final activeColor = isError
        ? context.colorScheme.error
        : context.colorScheme.primary;

    return Row(
      children: [
        SizedBox(
          width: 35,
          child: Text(
            '$number.',
            style: context.textTheme.titleLarge?.copyWith(
              color: activeColor,
            ),
          ),
        ),

        Expanded(
          child: SizedBox(
            height: 60,
            child: TextField(
              controller: controller,
              autocorrect: false,
              enableSuggestions: false,
              textAlign: TextAlign.center,
              textInputAction: isLast
                  ? TextInputAction.done
                  : TextInputAction.next,
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                filled: true,
                fillColor: context.ink.container,
                hintText: context.t.vault.setup.seedVerify.inputHint,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(
                    color: activeColor.withValues(alpha: AppAlpha.medium),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(
                    color: activeColor,
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
