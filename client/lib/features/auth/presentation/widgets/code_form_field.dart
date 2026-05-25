import 'package:flutter/material.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/validators.dart';
import 'package:ink/i18n/strings.g.dart';

class CodeFormField extends StatelessWidget {
  const CodeFormField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: context.textTheme.bodyLarge,
      decoration: InputDecoration(hintText: context.t.auth.verify.codeHint),
      validator: (v) => verificationCodeValidator(
        v,
        emptyError: context.t.auth.verify.codeError,
        lengthError: context.t.auth.verify.codeError,
      ),
    );
  }
}
