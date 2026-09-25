import 'package:go_router/go_router.dart';
import 'package:ink/features/notes/presentation/screens/calendar_screen.dart';
import 'package:ink/features/notes/presentation/screens/home_screen.dart';
import 'package:material_ui/material_ui.dart';

part 'notes_routes.g.dart';

@TypedGoRoute<NotesRoute>(
  path: '/notes',
  routes: [TypedGoRoute<NotesCalendarRoute>(path: 'calendar')],
)
class NotesRoute extends GoRouteData with $NotesRoute {
  const NotesRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const HomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }
}

class NotesCalendarRoute extends GoRouteData with $NotesCalendarRoute {
  const NotesCalendarRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CalendarScreen();
  }
}
