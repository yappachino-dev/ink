import 'package:go_router/go_router.dart';
import 'package:ink/features/vault/presentation/screens/setup_method_screen.dart';
import 'package:ink/features/vault/presentation/screens/setup_pattern_screen.dart';
import 'package:ink/features/vault/presentation/screens/setup_pin_screen.dart';
import 'package:ink/features/vault/presentation/screens/setup_recovery_screen.dart';
import 'package:ink/features/vault/presentation/screens/setup_verify_screen.dart';
import 'package:material_ui/material_ui.dart';

part 'vault_setup_routes.g.dart';

@TypedGoRoute<SetupVaultRoute>(
  path: '/setup',
  routes: [
    TypedGoRoute<SetupPinRoute>(path: 'pin'),
    TypedGoRoute<SetupPatternRoute>(path: 'pattern'),
    TypedGoRoute<SetupRecoveryRoute>(path: 'recovery'),
    TypedGoRoute<SetupVerifyRoute>(path: 'verify'),
  ],
)
class SetupVaultRoute extends GoRouteData with $SetupVaultRoute {
  const SetupVaultRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SetupMethodScreen();
  }
}

class SetupPinRoute extends GoRouteData with $SetupPinRoute {
  const SetupPinRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SetupPinScreen();
  }
}

class SetupPatternRoute extends GoRouteData with $SetupPatternRoute {
  const SetupPatternRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SetupPatternScreen();
  }
}

class SetupRecoveryRoute extends GoRouteData with $SetupRecoveryRoute {
  const SetupRecoveryRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SetupRecoveryScreen();
  }
}

class SetupVerifyRoute extends GoRouteData with $SetupVerifyRoute {
  const SetupVerifyRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SetupVerifyScreen();
  }
}
