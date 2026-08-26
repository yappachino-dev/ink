import 'package:ink/core/domain/result.dart';
import 'package:ink/features/auth/domain/failures/auth_failure.dart';

abstract interface class AuthService {
  Future<Result<void, AuthFailure>> login(String email, String password);

  Future<Result<void, AuthFailure>> requestVerification(String email);
  Future<Result<void, AuthFailure>> register(
    String email,
    String password,
    String code,
  );

  /// Clears the session: revokes the server-side refresh token (best-effort),
  /// zeroes the vault master key and removes stored tokens.
  Future<void> logout();
}
