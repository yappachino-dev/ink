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

  test('preserves gRPC status code and message', () async {
    final result = await runner.remoteRunner<void, CoreFailure>(
      call: () async => throw const GrpcError.unavailable('server is down'),
      mapCore: (failure) => failure,
    );

    final failure = result as Failure<void, CoreFailure>;
    expect(failure.error, isA<ApiFailure>());
    final apiFailure = failure.error as ApiFailure;
    expect(apiFailure.statusCode, StatusCode.unavailable);
    expect(apiFailure.message, 'server is down');
  });

  test('uses the gRPC code name when no message is present', () async {
    final result = await runner.remoteRunner<void, CoreFailure>(
      call: () async => throw const GrpcError.deadlineExceeded(),
      mapCore: (failure) => failure,
    );

    final failure = result as Failure<void, CoreFailure>;
    final apiFailure = failure.error as ApiFailure;
    expect(apiFailure.statusCode, StatusCode.deadlineExceeded);
    expect(apiFailure.message, StatusCode.name(StatusCode.deadlineExceeded));
  });
}
