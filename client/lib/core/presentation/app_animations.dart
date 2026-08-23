
/// Canonical animation durations. Pick by role, not by feel-of-the-moment.
abstract final class AppDurations {
  /// Micro-interactions: icon swaps, small fades.
  static const Duration fast = Duration(milliseconds: 150);

  /// Standard control feedback: presses, toggles.
  static const Duration base = Duration(milliseconds: 200);

  /// Navigation drawer slide.
  static const Duration drawer = Duration(milliseconds: 280);

  /// Bottom sheet enter/exit and view switches.
  static const Duration sheet = Duration(milliseconds: 300);

  /// Emphasized transitions (progress reveals).
  static const Duration slow = Duration(milliseconds: 350);

  /// Full-screen dramatic sequences only (e.g. fatal/intro screen).
  static const Duration dramatic = Duration(milliseconds: 1200);
}
