// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$notesRoute];

RouteBase get $notesRoute => GoRouteData.$route(
  path: '/notes',
  factory: $NotesRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'calendar',
      factory: $NotesCalendarRoute._fromState,
    ),
  ],
);

mixin $NotesRoute on GoRouteData {
  static NotesRoute _fromState(GoRouterState state) => const NotesRoute();

  @override
  String get location => GoRouteData.$location('/notes');

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

mixin $NotesCalendarRoute on GoRouteData {
  static NotesCalendarRoute _fromState(GoRouterState state) =>
      const NotesCalendarRoute();

  @override
  String get location => GoRouteData.$location('/notes/calendar');

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
