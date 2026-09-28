import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/app_snack_bar_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/flow_scaffold.dart';
import 'package:ink/features/auth/domain/auth_preferences.dart';
import 'package:ink/features/auth/presentation/extensions/auth_failure_ui_extension.dart';
import 'package:ink/features/auth/presentation/navigation/auth_navigator.dart';
import 'package:ink/features/auth/presentation/navigation/auth_routes.dart';
import 'package:ink/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:ink/features/auth/presentation/widgets/email_form_field.dart';
import 'package:ink/features/auth/presentation/widgets/password_form_field.dart';
import 'package:ink/features/auth/presentation/widgets/primary_button.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({required this.source, super.key});

  final String source;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text.trim());

    if (!mounted) return;

    if (success) {
      context.showSnackBarSuccess(context.t.auth.login.success);
      await ref.read(authPreferencesProvider).setLocalOnly(local: false);

      if (widget.source == 'inApp') {
        ref.read(authNavigatorProvider).onAuthCompleted();
      }
    } else {
      final failure = ref.read(authProvider).failure;
      if (failure != null) {
        context.showSnackbarError(failure.message(context.t));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = ref.watch(
      authProvider.select((state) => state.isProcessing),
    );

    return PopScope(
      onPopInvokedWithResult: (didPop, _) =>
          didPop ? ref.read(authProvider.notifier).abortFlow() : null,
      child: FlowScaffold(
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.t.auth.login.title,
                style: context.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              EmailFormField(controller: _emailController),

              const SizedBox(height: AppSpacing.lg),

              PasswordFormField(controller: _passwordController),

              const SizedBox(height: AppSpacing.xxxl),

              PrimaryButton(
                label: context.t.auth.login.action,
                isLoading: isProcessing,
                onPressed: _onLogin,
              ),

              const SizedBox(height: AppSpacing.xxl),

              if (widget.source == 'inApp')
                Column(
                  children: [
                    Text(
                      context.t.auth.login.noAccount,
                      style: context.textTheme.bodyMedium,
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    GestureDetector(
                      onTap: () => RegisterRoute(
                        source: widget.source,
                      ).push<void>(context),
                      child: Text(
                        context.t.auth.register.action,
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
      ),
    );
  }
}
