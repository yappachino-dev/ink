import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/features/auth/data/mappers/auth_failure_mapper.dart';
import 'package:ink/features/auth/domain/failures/auth_failure.dart';

void main() {
  test('maps unauthenticated responses to invalid credentials', () {
    expect(
      mapAuthCoreFailure(const ApiFailure(StatusCode.unauthenticated, 'nope')),
      const InvalidCredentials(),
    );
  });

  test('maps already-exists responses to email-in-use', () {
    expect(
      mapAuthCoreFailure(const ApiFailure(StatusCode.alreadyExists, 'exists')),
      const EmailAlreadyInUse(),
    );
  });

  test('preserves other API failures inside the auth core failure', () {
    const apiFailure = ApiFailure(StatusCode.unavailable, 'down');

    final mapped = mapAuthCoreFailure(apiFailure);

    expect(mapped, isA<AuthCoreFailure>());
    expect((mapped as AuthCoreFailure).core, same(apiFailure));
  });
}
