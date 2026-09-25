import 'package:grpc/grpc.dart' show StatusCode;
import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/features/auth/domain/failures/auth_failure.dart';

AuthFailure mapAuthCoreFailure(CoreFailure failure) {
  if (failure case ApiFailure(:final statusCode)) {
    return switch (statusCode) {
      StatusCode.unauthenticated => const InvalidCredentials(),
      StatusCode.alreadyExists => const EmailAlreadyInUse(),
      _ => AuthCoreFailure(failure),
    };
  }

  return AuthCoreFailure(failure);
}
