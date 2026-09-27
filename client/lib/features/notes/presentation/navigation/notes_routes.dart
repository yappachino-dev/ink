import 'package:go_router/go_router.dart';
import 'package:ink/features/notes/presentation/screens/calendar_screen.dart';
import 'package:ink/features/notes/presentation/screens/home_screen.dart';
import 'package:ink/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:material_ui/material_ui.dart';

part 'notes_routes.g.dart';

/// The notes journal. This is a shell branch root, so it must not own a nested
/// `[noteId]` route: a `:param` under `/notes` here would shadow the standalone
/// editor route below and get caught by the shell's navigation bar.
@TypedGoRoute<NotesRoute>(path: '/notes')
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

/// Calendar is a journal of written days, a top-level destination in its own
/// right, so it gets its own root rather than nesting under `/notes`.
@TypedGoRoute<NotesCalendarRoute>(path: '/calendar')
class NotesCalendarRoute extends GoRouteData with $NotesCalendarRoute {
  const NotesCalendarRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const CalendarScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }
}

/// Writing is a destination, not a sheet: this gives it a back gesture and an
/// addressable URL, which is also where a future per-note conflict or sharing
/// affordance attaches (F-20). Declared at the root, outside the shell, so the
/// editor does not carry the tab bar.
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
