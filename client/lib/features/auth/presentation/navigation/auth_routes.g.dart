// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$authRoute];

RouteBase get $authRoute => GoRouteData.$route(
  path: '/auth',
  factory: $AuthRoute._fromState,
  routes: [
    GoRouteData.$route(path: 'register', factory: $RegisterRoute._fromState),
    GoRouteData.$route(
      path: 'email-verification',
      factory: $EmailVerificationRoute._fromState,
    ),
  ],
);

mixin $AuthRoute on GoRouteData {
  static AuthRoute _fromState(GoRouterState state) =>
      AuthRoute(source: state.uri.queryParameters['source'] ?? 'onboarding');

  AuthRoute get _self => this as AuthRoute;

  @override
  String get location => GoRouteData.$location(
    '/auth',
    queryParams: {if (_self.source != 'onboarding') 'source': _self.source},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RegisterRoute on GoRouteData {
  static RegisterRoute _fromState(GoRouterState state) => RegisterRoute(
    source: state.uri.queryParameters['source'] ?? 'onboarding',
  );

  RegisterRoute get _self => this as RegisterRoute;

  @override
  String get location => GoRouteData.$location(
    '/auth/register',
    queryParams: {if (_self.source != 'onboarding') 'source': _self.source},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $EmailVerificationRoute on GoRouteData {
  static EmailVerificationRoute _fromState(GoRouterState state) =>
      EmailVerificationRoute(
        source: state.uri.queryParameters['source'] ?? 'onboarding',
      );

  EmailVerificationRoute get _self => this as EmailVerificationRoute;

  @override
  String get location => GoRouteData.$location(
    '/auth/email-verification',
    queryParams: {if (_self.source != 'onboarding') 'source': _self.source},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
