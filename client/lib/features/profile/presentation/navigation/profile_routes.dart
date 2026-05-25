import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/features/profile/presentation/screens/personalization_screen.dart';
import 'package:ink/features/profile/presentation/screens/profile_screen.dart';

part 'profile_routes.g.dart';

@TypedGoRoute<ProfileRoute>(
  path: '/profile',
  routes: [TypedGoRoute<PersonalizationRoute>(path: 'personalization')],
)
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ProfileScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }
}

class PersonalizationRoute extends GoRouteData with $PersonalizationRoute {
  const PersonalizationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PersonalizationScreen();
  }
}
