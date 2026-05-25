import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_navigator.g.dart';

abstract interface class AuthNavigator {
  void onOnboardingLoginCompleted();
  void onAuthCompleted();
}

@Riverpod(keepAlive: true)
AuthNavigator authNavigator(Ref ref) =>
    throw UnimplementedError('authNavigator must be overridden in main');
