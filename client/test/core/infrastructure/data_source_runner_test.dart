import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/data_source_runner.dart';

class _TestRunner with DataSourceRunner {}

void main() {
  late _TestRunner runner;

  setUp(() {
    runner = _TestRunner();
  });

  test('maps unavailable responses to a network failure', () async {
    final result = await runner.remoteRunner<void, CoreFailure>(
      call: () async => throw const GrpcError.unavailable('server is down'),
      mapCore: (failure) => failure,
    );

    final failure = result as Failure<void, CoreFailure>;
    expect(failure.error, isA<NetworkFailure>());
  });

  test('maps deadline-exceeded responses to a timeout failure', () async {
    final result = await runner.remoteRunner<void, CoreFailure>(
      call: () async => throw const GrpcError.deadlineExceeded(),
      mapCore: (failure) => failure,
    );

    final failure = result as Failure<void, CoreFailure>;
    expect(failure.error, isA<TimeoutFailure>());
  });

  test('maps already-exists responses to their own failure', () async {
    final result = await runner.remoteRunner<void, CoreFailure>(
      call: () async => throw const GrpcError.alreadyExists('slot differs'),
      mapCore: (failure) => failure,
    );

    final failure = result as Failure<void, CoreFailure>;
    expect(failure.error, isA<AlreadyExistsFailure>());
    expect(failure.error, isNot(isA<ApiFailure>()));
  });

  test('preserves other gRPC status codes and messages', () async {
    final result = await runner.remoteRunner<void, CoreFailure>(
      call: () async => throw const GrpcError.unauthenticated('token expired'),
      mapCore: (failure) => failure,
    );

    final failure = result as Failure<void, CoreFailure>;
    expect(failure.error, isA<ApiFailure>());
    final apiFailure = failure.error as ApiFailure;
    expect(apiFailure.statusCode, StatusCode.unauthenticated);
    expect(apiFailure.message, 'token expired');
  });
}
