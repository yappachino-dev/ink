// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_unlock_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$unlockVaultRoute];

RouteBase get $unlockVaultRoute => GoRouteData.$route(
  path: '/unlock',
  factory: $UnlockVaultRoute._fromState,
  routes: [
    GoRouteData.$route(path: 'pin', factory: $UnlockPinRoute._fromState),
    GoRouteData.$route(
      path: 'pattern',
      factory: $UnlockPatternRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'recovery',
      factory: $UnlockRecoveryRoute._fromState,
    ),
    GoRouteData.$route(path: 'fatal', factory: $FatalRoute._fromState),
  ],
);

mixin $UnlockVaultRoute on GoRouteData {
  static UnlockVaultRoute _fromState(GoRouterState state) =>
      const UnlockVaultRoute();

  @override
  String get location => GoRouteData.$location('/unlock');

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

mixin $UnlockPinRoute on GoRouteData {
  static UnlockPinRoute _fromState(GoRouterState state) =>
      const UnlockPinRoute();

  @override
  String get location => GoRouteData.$location('/unlock/pin');

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

mixin $UnlockPatternRoute on GoRouteData {
  static UnlockPatternRoute _fromState(GoRouterState state) =>
      const UnlockPatternRoute();

  @override
  String get location => GoRouteData.$location('/unlock/pattern');

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

mixin $UnlockRecoveryRoute on GoRouteData {
  static UnlockRecoveryRoute _fromState(GoRouterState state) =>
      const UnlockRecoveryRoute();

  @override
  String get location => GoRouteData.$location('/unlock/recovery');

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

mixin $FatalRoute on GoRouteData {
  static FatalRoute _fromState(GoRouterState state) => const FatalRoute();

  @override
  String get location => GoRouteData.$location('/unlock/fatal');

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
