import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/app_snack_bar_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/flow_scaffold.dart';
import 'package:ink/features/auth/domain/auth_preferences.dart';
import 'package:ink/features/auth/presentation/extensions/auth_failure_ui_extension.dart';
import 'package:ink/features/auth/presentation/navigation/auth_navigator.dart';
import 'package:ink/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:ink/features/auth/presentation/widgets/code_form_field.dart';
import 'package:ink/features/auth/presentation/widgets/primary_button.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({required this.source, super.key});

  final String source;

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();

    super.dispose();
  }

  Future<void> _onConfirm() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .confirmRegister(_codeController.text.trim());

    if (!mounted) return;

    if (success) {
      context.showSnackBarSuccess(context.t.auth.register.success);
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

  Future<void> _onResend() async {
    final success = await ref.read(authProvider.notifier).resendCode();

    if (!mounted) return;

    if (success) {
      context.showSnackBarInfo(
        context.t.auth.verify.codeSent(email: ref.read(authProvider).email!),
      );
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

    return FlowScaffold(
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.t.auth.verify.title,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xs),

            CodeFormField(controller: _codeController),

            const SizedBox(height: AppSpacing.xxxl),

            PrimaryButton(
              label: context.t.common.confirm,
              isLoading: isProcessing,
              onPressed: _onConfirm,
            ),

            const SizedBox(height: AppSpacing.xxl),

            Center(
              child: TextButton(
                onPressed: _onResend,
                child: Text(
                  context.t.auth.verify.resend,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: context.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
