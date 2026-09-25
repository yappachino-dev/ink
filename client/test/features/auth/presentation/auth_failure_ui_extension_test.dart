import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/features/auth/domain/failures/auth_failure.dart';
import 'package:ink/features/auth/presentation/extensions/auth_failure_ui_extension.dart';
import 'package:ink/i18n/strings.g.dart';

void main() {
  final strings = Translations();

  test('maps typed auth failures to their messages', () {
    expect(
      const InvalidCredentials().message(strings),
      'Invalid email or password.',
    );
    expect(
      const EmailAlreadyInUse().message(strings),
      'An account with this email already exists.',
    );
    expect(const InvalidVerificationCode().message(strings), 'Invalid code');
    expect(
      const InvalidPassword().message(strings),
      'Password must be between 6 and 72 characters',
    );
  });

  test('maps transport-level failures to shared messages', () {
    expect(
      const AuthCoreFailure(NetworkFailure()).message(strings),
      'Unable to reach the server. Check your connection.',
    );
    expect(
      const AuthCoreFailure(TimeoutFailure()).message(strings),
      'The server took too long to respond. Try again.',
    );
    expect(
      const AuthCoreFailure(ApiFailure(13, 'internal')).message(strings),
      'Something went wrong. Please try again.',
    );
  });
}
