import 'package:grpc/grpc.dart' show StatusCode;
import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/features/auth/domain/failures/auth_failure.dart';

AuthFailure mapLoginFailure(CoreFailure failure) {
  if (failure case ApiFailure(:final statusCode)) {
    if (statusCode == StatusCode.unauthenticated) {
      return const InvalidCredentials();
    }
  }

  return AuthCoreFailure(failure);
}

AuthFailure mapRegisterFailure(CoreFailure failure) {
  if (failure case ApiFailure(:final statusCode, :final message)) {
    if (statusCode == StatusCode.alreadyExists) {
      return const EmailAlreadyInUse();
    }

    // The current backend contract uses InvalidArgument plus a human-readable
    // message for verification/password errors. Keep this mapping aligned with
    // those messages until structured gRPC error details are introduced.
    final normalizedMessage = message?.toLowerCase() ?? '';
    if (statusCode == StatusCode.invalidArgument) {
      if (normalizedMessage.contains('code')) {
        return const InvalidVerificationCode();
      }
      if (normalizedMessage.contains('password')) {
        return const InvalidPassword();
      }
    }
  }

  return AuthCoreFailure(failure);
}

AuthFailure mapRequestVerificationFailure(CoreFailure failure) {
  if (failure case ApiFailure(:final statusCode)) {
    if (statusCode == StatusCode.alreadyExists) {
      return const EmailAlreadyInUse();
    }
  }

  return AuthCoreFailure(failure);
}

AuthFailure mapAuthFailure(CoreFailure failure) => AuthCoreFailure(failure);
