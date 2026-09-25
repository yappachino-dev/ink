import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:ink/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:ink/features/auth/presentation/screens/login_screen.dart';
import 'package:ink/features/auth/presentation/screens/register_screen.dart';
import 'package:material_ui/material_ui.dart';

part 'auth_routes.g.dart';

/// Default navigation source for auth flows entered outside a deep link.
const defaultAuthSource = 'onboarding';

@TypedGoRoute<AuthRoute>(
  path: '/auth',
  routes: [
    TypedGoRoute<RegisterRoute>(path: 'register'),
    TypedGoRoute<EmailVerificationRoute>(path: 'email-verification'),
  ],
)
class AuthRoute extends GoRouteData with $AuthRoute {
  const AuthRoute({this.source = defaultAuthSource});

  final String source;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return LoginScreen(source: source);
  }
}

class RegisterRoute extends GoRouteData with $RegisterRoute {
  const RegisterRoute({this.source = defaultAuthSource});

  final String source;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return RegisterScreen(source: source);
  }
}

class EmailVerificationRoute extends GoRouteData with $EmailVerificationRoute {
  const EmailVerificationRoute({this.source = defaultAuthSource});

  final String source;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return EmailVerificationScreen(source: source);
  }
}
