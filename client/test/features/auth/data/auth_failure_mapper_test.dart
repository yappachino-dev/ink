import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/features/auth/data/mappers/auth_failure_mapper.dart';
import 'package:ink/features/auth/domain/failures/auth_failure.dart';

void main() {
  test('login maps unauthenticated responses to invalid credentials', () {
    expect(
      mapLoginFailure(const ApiFailure(StatusCode.unauthenticated, 'nope')),
      const InvalidCredentials(),
    );
  });

  test('register maps already-exists responses to email-in-use', () {
    expect(
      mapRegisterFailure(const ApiFailure(StatusCode.alreadyExists, 'exists')),
      const EmailAlreadyInUse(),
    );
  });

  test('register maps verification-code errors to a specific failure', () {
    expect(
      mapRegisterFailure(
        const ApiFailure(
          StatusCode.invalidArgument,
          'invalid verification code',
        ),
      ),
      const InvalidVerificationCode(),
    );
  });

  test('register maps password-policy errors to a specific failure', () {
    expect(
      mapRegisterFailure(
        const ApiFailure(
          StatusCode.invalidArgument,
          'password must be between 6 and 72 bytes',
        ),
      ),
      const InvalidPassword(),
    );
  });

  test(
    'generic auth operations do not treat unauthenticated as bad password',
    () {
      const failure = ApiFailure(StatusCode.unauthenticated, 'expired session');

      final mapped = mapAuthFailure(failure);
      expect(mapped, isA<AuthCoreFailure>());
      expect((mapped as AuthCoreFailure).core, same(failure));
    },
  );
}
