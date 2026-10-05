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

  test(
    'verification requests map already-exists responses to email-in-use',
    () {
      expect(
        mapRequestVerificationFailure(
          const ApiFailure(StatusCode.alreadyExists, 'exists'),
        ),
        const EmailAlreadyInUse(),
      );
    },
  );

  test('register maps already-exists responses to email-in-use', () {
    expect(
      mapRegisterFailure(const ApiFailure(StatusCode.alreadyExists, 'exists')),
      const EmailAlreadyInUse(),
    );
  });

  test('register maps verification-code errors to a specific failure', () {
    expect(
      mapRegisterFailure(
        const ApiFailure(StatusCode.invalidArgument, 'invalid code'),
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

  // DataSourceRunner maps gRPC already-exists to AlreadyExistsFailure, so
  // these mappers must recognize that type and not only the raw ApiFailure.
  // While the runner still produced an ApiFailure, register() and
  // requestVerification() fell through to a generic error and the user lost
  // "email already in use".
  test('register maps already-exists to EmailAlreadyInUse', () {
    expect(
      mapRegisterFailure(const AlreadyExistsFailure()),
      isA<EmailAlreadyInUse>(),
    );
  });

  test('request verification maps already-exists to EmailAlreadyInUse', () {
    expect(
      mapRequestVerificationFailure(const AlreadyExistsFailure()),
      isA<EmailAlreadyInUse>(),
    );
  });

  test('a generic auth mapper does not claim the already-exists meaning', () {
    expect(
      mapAuthFailure(const AlreadyExistsFailure()),
      isA<AuthCoreFailure>(),
    );
  });
}
