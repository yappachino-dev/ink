/// Stable application-level destinations used by the shared bottom navigation.
///
/// Feature screens may use these paths when crossing feature boundaries; they
/// should not import another feature's route or presentation implementation.
abstract final class AppDestinations {
  static const notes = '/notes';
  static const calendar = '/notes/calendar';
  static const profile = '/profile';
  static const authInApp = '/auth?source=inApp';
}
