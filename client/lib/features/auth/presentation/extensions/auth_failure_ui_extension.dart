import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/features/auth/domain/failures/auth_failure.dart';
import 'package:ink/i18n/strings.g.dart';

extension AuthFailureUiMessage on AuthFailure {
  String message(Translations strings) {
    return switch (this) {
      InvalidCredentials() => strings.auth.errors.invalidCredentials,
      EmailAlreadyInUse() => strings.auth.errors.emailAlreadyInUse,
      InvalidVerificationCode() => strings.auth.verify.codeError,
      InvalidPassword() => strings.auth.form.passwordLengthError,
      AuthCoreFailure(:final core) => _coreMessage(core, strings),
    };
  }

  static String _coreMessage(CoreFailure core, Translations strings) {
    if (core is NetworkFailure) return strings.common.errors.network;
    if (core is TimeoutFailure) return strings.common.errors.timeout;
    return strings.common.errors.unknown;
  }
}
