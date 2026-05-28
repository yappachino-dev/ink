import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/auth/types.dart';
import 'package:ink/features/auth/domain/failures/auth_failure.dart';

abstract interface class AuthRepository {
  Future<Result<TokenPayload, AuthFailure>> login(
    String email,
    String password,
  );

  Future<Result<void, AuthFailure>> requestVerification(String email);
  Future<Result<TokenPayload, AuthFailure>> register(
    String email,
    String password,
    String code,
  );
}
