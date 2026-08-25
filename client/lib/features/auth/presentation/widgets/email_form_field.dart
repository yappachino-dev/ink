import 'package:flutter/material.dart';
import 'package:ink/core/presentation/form_fields/deferred_validation_text_form_field.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/validators.dart';
import 'package:ink/i18n/strings.g.dart';

class EmailFormField extends StatelessWidget {
  const EmailFormField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return DeferredValidationTextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: context.textTheme.bodyLarge,
      decoration: InputDecoration(hintText: context.t.auth.form.emailHint),
      validator: (v) => emailValidator(
        v,
        emptyError: context.t.auth.form.emailError,
        formatError: context.t.auth.form.emailFormatError,
      ),
    );
  }
}
