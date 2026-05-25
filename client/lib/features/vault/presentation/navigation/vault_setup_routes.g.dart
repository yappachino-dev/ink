// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_setup_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$setupVaultRoute];

RouteBase get $setupVaultRoute => GoRouteData.$route(
  path: '/setup',
  factory: $SetupVaultRoute._fromState,
  routes: [
    GoRouteData.$route(path: 'pin', factory: $SetupPinRoute._fromState),
    GoRouteData.$route(path: 'pattern', factory: $SetupPatternRoute._fromState),
    GoRouteData.$route(
      path: 'recovery',
      factory: $SetupRecoveryRoute._fromState,
    ),
    GoRouteData.$route(path: 'vefiry', factory: $SetupVerifyRoute._fromState),
  ],
);

mixin $SetupVaultRoute on GoRouteData {
  static SetupVaultRoute _fromState(GoRouterState state) =>
      const SetupVaultRoute();

  @override
  String get location => GoRouteData.$location('/setup');

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

mixin $SetupPinRoute on GoRouteData {
  static SetupPinRoute _fromState(GoRouterState state) => const SetupPinRoute();

  @override
  String get location => GoRouteData.$location('/setup/pin');

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

mixin $SetupPatternRoute on GoRouteData {
  static SetupPatternRoute _fromState(GoRouterState state) =>
      const SetupPatternRoute();

  @override
  String get location => GoRouteData.$location('/setup/pattern');

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

mixin $SetupRecoveryRoute on GoRouteData {
  static SetupRecoveryRoute _fromState(GoRouterState state) =>
      const SetupRecoveryRoute();

  @override
  String get location => GoRouteData.$location('/setup/recovery');

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

mixin $SetupVerifyRoute on GoRouteData {
  static SetupVerifyRoute _fromState(GoRouterState state) =>
      const SetupVerifyRoute();

  @override
  String get location => GoRouteData.$location('/setup/vefiry');

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
