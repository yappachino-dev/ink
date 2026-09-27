// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$notesRoute, $noteNewRoute, $noteEditRoute];

RouteBase get $notesRoute => GoRouteData.$route(
  path: '/notes',
  hasOverriddenOnExit: false,
  factory: $NotesRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'calendar',
      hasOverriddenOnExit: false,
      factory: $NotesCalendarRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'new',
      hasOverriddenOnExit: false,
      factory: $NoteNewRoute._fromState,
    ),
    GoRouteData.$route(
      path: ':noteId',
      hasOverriddenOnExit: false,
      factory: $NoteEditRoute._fromState,
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

mixin $NoteNewRoute on GoRouteData {
  static NoteNewRoute _fromState(GoRouterState state) => const NoteNewRoute();

  @override
  String get location => GoRouteData.$location('/notes/new');

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

mixin $NoteEditRoute on GoRouteData {
  static NoteEditRoute _fromState(GoRouterState state) =>
      NoteEditRoute(noteId: state.pathParameters['noteId']!);

  NoteEditRoute get _self => this as NoteEditRoute;

  @override
  String get location =>
      GoRouteData.$location('/notes/${Uri.encodeComponent(_self.noteId)}');

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

RouteBase get $noteNewRoute => GoRouteData.$route(
  path: '/notes/new',
  hasOverriddenOnExit: false,
  factory: $NoteNewRoute._fromState,
);

RouteBase get $noteEditRoute => GoRouteData.$route(
  path: '/notes/:noteId',
  hasOverriddenOnExit: false,
  factory: $NoteEditRoute._fromState,
);
