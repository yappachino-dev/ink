/// Stable application-level destinations used by the shared bottom navigation.
///
/// Feature screens may use these paths when crossing feature boundaries; they
/// should not import another feature's route or presentation implementation.
abstract final class AppDestinations {
  static const notes = '/notes';
  static const calendar = '/calendar';
  static const profile = '/profile';
  static const registerInApp = '/auth/register?source=inApp';

  /// Entry point for a device with no vault. Exposed here rather than imported
  /// from `WelcomeRoute` so a feature screen can return to onboarding without
  /// reaching into the app router's route classes.
  static const welcome = '/welcome';
}
