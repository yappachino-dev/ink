import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Account-level preferences used by authentication flows.
abstract interface class AuthPreferences {
  bool get localOnly;

  Future<void> setLocalOnly({required bool local});
}

/// Domain-facing account preferences dependency.
final authPreferencesProvider = Provider<AuthPreferences>(
  (ref) => throw StateError(
    'authPreferencesProvider must be overridden at the app root',
  ),
);
