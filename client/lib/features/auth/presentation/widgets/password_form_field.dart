import 'package:flutter/material.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/validators.dart';
import 'package:ink/i18n/strings.g.dart';

class PasswordFormField extends StatefulWidget {
  const PasswordFormField({
    required this.controller,
    this.hintText,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String? hintText;
  final String? Function(String?)? validator;

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureInput = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureInput,
      style: context.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: widget.hintText ?? context.t.auth.form.passwordHint,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureInput
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () => setState(() => _obscureInput = !_obscureInput),
        ),
      ),
      validator:
          widget.validator ??
          (v) => passwordValidator(
            v,
            emptyError: context.t.auth.form.passwordError,
            lengthError: context.t.auth.form.passwordLengthError,
          ),
    );
  }
}
