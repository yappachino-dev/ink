import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/auth/domain/auth_service.dart';

/// Domain-facing authentication service dependency.
///
/// The concrete implementation is wired by the application composition root
/// in `app/init.dart`; presentation code only depends on this contract.
final authServiceProvider = Provider<AuthService>(
  (ref) => throw StateError(
    'authServiceProvider must be overridden at the app root',
  ),
);
