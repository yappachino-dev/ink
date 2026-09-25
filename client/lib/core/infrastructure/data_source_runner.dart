import 'package:drift/native.dart';
import 'package:grpc/grpc.dart';
import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/logger.dart';

mixin DataSourceRunner {
  Future<Result<T, F>> remoteRunner<T, F>({
    required Future<T> Function() call,
    required F Function(CoreFailure core) mapCore,
  }) async {
    try {
      final result = await call();
      return Success(result);
    } on GrpcError catch (e, st) {
      logger.e('gRPC call failed in remoteRunner', error: e, stackTrace: st);
      return Failure(mapCore(ApiFailure(e.code, e.message ?? e.codeName)));
    } on Exception catch (e, st) {
      logger.e('Unhandled exception in remoteRunner', error: e, stackTrace: st);
      return Failure(mapCore(UnexpectedFailure(e)));
    }
  }

  Future<Result<T, F>> localRunner<T, F>({
    required Future<T> Function() call,
    required F Function(CoreFailure core) mapCore,
  }) async {
    try {
      final result = await call();
      return Success(result);
    } on SqliteException catch (e, st) {
      logger.e('Call failed in localRunner', error: e, stackTrace: st);
      return Failure(mapCore(StorageFailure(e.message)));
    } on Exception catch (e, st) {
      logger.e('Unhandled exception in localRunner', error: e, stackTrace: st);
      return Failure(mapCore(UnexpectedFailure(e)));
    }
  }
}
