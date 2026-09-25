import 'package:ink/core/domain/core_failure.dart';

sealed class AuthFailure {
  const AuthFailure();
}

class InvalidCredentials extends AuthFailure {
  const InvalidCredentials();
}

class EmailAlreadyInUse extends AuthFailure {
  const EmailAlreadyInUse();
}

class InvalidVerificationCode extends AuthFailure {
  const InvalidVerificationCode();
}

class InvalidPassword extends AuthFailure {
  const InvalidPassword();
}

class AuthCoreFailure extends AuthFailure {
  const AuthCoreFailure(this.core);

  final CoreFailure core;
}
