import 'package:go_router/go_router.dart';
import 'package:ink/features/notes/presentation/screens/calendar_screen.dart';
import 'package:ink/features/notes/presentation/screens/home_screen.dart';
import 'package:ink/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:material_ui/material_ui.dart';

part 'notes_routes.g.dart';

@TypedGoRoute<NotesRoute>(
  path: '/notes',
  routes: [
    TypedGoRoute<NotesCalendarRoute>(path: 'calendar'),
    TypedGoRoute<NoteNewRoute>(path: 'new'),
    TypedGoRoute<NoteEditRoute>(path: ':noteId'),
  ],
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


/// Writing is a destination, not a sheet: this gives it a back gesture and an
/// addressable URL, which is also where a future per-note conflict or sharing
/// affordance attaches (F-20).
@TypedGoRoute<NoteNewRoute>(path: '/notes/new')
class NoteNewRoute extends GoRouteData with $NoteNewRoute {
  const NoteNewRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      key: state.pageKey,
      fullscreenDialog: true,
      child: const NoteEditorScreen(),
    );
  }
}

@TypedGoRoute<NoteEditRoute>(path: '/notes/:noteId')
class NoteEditRoute extends GoRouteData with $NoteEditRoute {
  const NoteEditRoute({required this.noteId});

  final String noteId;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      key: state.pageKey,
      fullscreenDialog: true,
      child: NoteEditorScreen(noteId: noteId),
    );
  }
}
