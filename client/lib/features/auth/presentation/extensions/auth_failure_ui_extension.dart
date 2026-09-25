import 'package:grpc/grpc.dart' show StatusCode;
import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/features/auth/domain/failures/auth_failure.dart';
import 'package:ink/i18n/strings.g.dart';

extension AuthFailureUiMessage on AuthFailure {
  String message(Translations strings) {
    return switch (this) {
      InvalidCredentials() => strings.auth.errors.invalidCredentials,
      EmailAlreadyInUse() => strings.auth.errors.emailAlreadyInUse,
      AuthCoreFailure(:final core) => _coreMessage(core, strings),
    };
  }

  static String _coreMessage(CoreFailure core, Translations strings) {
    if (core case ApiFailure(:final statusCode)) {
      return switch (statusCode) {
        StatusCode.unavailable => strings.auth.errors.network,
        StatusCode.deadlineExceeded => strings.auth.errors.timeout,
        _ => strings.auth.errors.unknown,
      };
    }

    if (core is NetworkFailure) return strings.auth.errors.network;
    return strings.auth.errors.unknown;
  }
}
