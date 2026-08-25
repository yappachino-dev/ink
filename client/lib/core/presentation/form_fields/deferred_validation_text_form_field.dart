import 'package:flutter/material.dart';

/// A [TextFormField] that validates "deferred": it stays quiet while the user
/// is typing, and starts live validation only once they finish the field —
/// focus leaves, they tap outside, or they submit from the keyboard. Errors
/// therefore appear before the form's action button is pressed, without the
/// impatience of per-keystroke validation on untouched fields.
///
/// Submitting the enclosing [Form] always validates regardless.
class DeferredValidationTextFormField extends StatefulWidget {
  const DeferredValidationTextFormField({
    required this.controller,
    this.validator,
    this.decoration = const InputDecoration(),
    this.style,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.textInputAction,
    super.key,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final InputDecoration decoration;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;

  @override
  State<DeferredValidationTextFormField> createState() =>
      _DeferredValidationTextFormFieldState();
}

class _DeferredValidationTextFormFieldState
    extends State<DeferredValidationTextFormField> {
  late final FocusNode _focusNode;

  /// Whether the user has finished the field at least once; from then on the
  /// field re-validates on every change so errors clear as they type.
  var _liveValidationStarted = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus) {
      _startLiveValidation();
    }
  }

  void _startLiveValidation() {
    if (!_liveValidationStarted && widget.controller.text.isNotEmpty) {
      setState(() => _liveValidationStarted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      validator: widget.validator,
      style: widget.style,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      textInputAction: widget.textInputAction,
      autovalidateMode: _liveValidationStarted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      onTapOutside: (_) => _startLiveValidation(),
      onFieldSubmitted: (_) => _startLiveValidation(),
      decoration: widget.decoration.copyWith(suffixIcon: widget.suffixIcon),
    );
  }
}
