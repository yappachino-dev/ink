import 'package:flutter/material.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/widgets/app_logo.dart';
import 'package:ink/core/presentation/widgets/wide_filled_button.dart';
import 'package:ink/features/auth/presentation/navigation/auth_routes.dart';
import 'package:ink/features/vault/presentation/navigation/vault_setup_routes.dart';
import 'package:ink/i18n/strings.g.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ink.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(flex: 3),

              Text(
                context.t.common.appName,
                style: context.textTheme.displayLarge,
              ),

              const SizedBox(height: 24),

              const AppLogo(size: LogoSize.large),

              const Spacer(flex: 2),

              Text(
                context.t.auth.tagline,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                context.t.auth.chooseMethod,
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              WideFilledButton(
                onPressed: () => const SetupVaultRoute().push<void>(context),
                child: Text(context.t.welcome.createLocalStorage),
              ),

              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: () => const AuthRoute().push<void>(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 51),
                ),
                child: Text(context.t.welcome.haveAccount),
              ),

              const Spacer(flex: 10),
            ],
          ),
        ),
      ),
    );
  }
}
