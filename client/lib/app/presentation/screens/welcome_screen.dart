import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/app_logo.dart';
import 'package:ink/core/presentation/widgets/wide_filled_button.dart';
import 'package:ink/features/auth/presentation/navigation/auth_routes.dart';
import 'package:ink/features/vault/presentation/navigation/vault_setup_routes.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ink.surface,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screen,
          child: Column(
            children: [
              const Spacer(flex: 3),

              Text(
                context.t.common.appName,
                style: context.textTheme.displayLarge,
              ),

              const SizedBox(height: AppSpacing.xxl),

              const AppLogo(size: LogoSize.large),

              const Spacer(flex: 2),

              // The thesis, stated before the user has invested anything.
              // This replaces the previous "your plans under reliable
              // protection" tagline, which described a backup product and
              // never mentioned encryption.
              Text(
                context.t.welcome.thesis,
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(height: 1.45),
              ),
              // Enough separation that "Choose how to use" reads as a label
              // for the buttons rather than a caption to the thesis.
              const SizedBox(height: AppSpacing.xxxl),

              Text(context.t.auth.chooseMethod, textAlign: TextAlign.center),

              const Spacer(flex: 3),

              WideFilledButton(
                onPressed: () => const SetupVaultRoute().push<void>(context),
                child: Text(context.t.welcome.createLocalStorage),
              ),

              const SizedBox(height: AppSpacing.lg),

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
