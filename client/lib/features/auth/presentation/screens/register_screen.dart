import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/app_snack_bar_extension.dart';
import 'package:ink/core/presentation/extensions/navigation_helper.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/validators.dart';
import 'package:ink/core/presentation/widgets/flow_scaffold.dart';
import 'package:ink/features/auth/presentation/navigation/auth_routes.dart';
import 'package:ink/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:ink/features/auth/presentation/widgets/email_form_field.dart';
import 'package:ink/features/auth/presentation/widgets/password_form_field.dart';
import 'package:ink/features/auth/presentation/widgets/primary_button.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({required this.source, super.key});

  final String source;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    final result = await ref
        .read(authProvider.notifier)
        .setupRegister(
          email,
          _passwordController.text.trim(),
        );

    if (!mounted) return;

    switch (result) {
      case RegisterResult.codeSent:
        context.showSnackBarInfo(context.t.auth.verify.codeSent(email: email));
        unawaited(
          EmailVerificationRoute(source: widget.source).push<void>(context),
        );
      case RegisterResult.alreadySent:
        unawaited(
          EmailVerificationRoute(source: widget.source).push<void>(context),
        );
      case RegisterResult.processing:
      case RegisterResult.failure:
        final failure = ref.read(authProvider).failure;
        if (failure != null) context.showSnackbarError('$failure');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = ref.watch(
      authProvider.select((state) => state.isProcessing),
    );

    return FlowScaffold(
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.t.auth.register.title,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            EmailFormField(controller: _emailController),

            const SizedBox(height: 16),

            PasswordFormField(controller: _passwordController),

            const SizedBox(height: 16),

            PasswordFormField(
              controller: _confirmPasswordController,
              hintText: context.t.auth.form.confirmPassword,
              validator: (v) => passwordConfirmValidator(
                v,
                password: _passwordController.text,
                emptyError: context.t.auth.form.confirmPassword,
                noMatchError: context.t.auth.form.passwordsNotMatch,
              ),
            ),

            const SizedBox(height: 32),

            PrimaryButton(
              label: context.t.auth.register.action,
              isLoading: isProcessing,
              onPressed: _onRegister,
            ),

            const SizedBox(height: 24),

            Column(
              children: [
                Text(
                  context.t.auth.register.haveAccount,
                  style: context.textTheme.bodyMedium,
                ),

                const SizedBox(height: 4),

                GestureDetector(
                  onTap: () => context.safePop(),
                  child: Text(
                    context.t.auth.login.action,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: context.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
