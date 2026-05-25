import 'package:dio/dio.dart';
import 'package:drift/native.dart';
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
    } on DioException catch (e, st) {
      logger.e('Call failed in remoteRunner', error: e, stackTrace: st);

      if (e.response != null) {
        final statusCode = e.response!.statusCode ?? 0;
        final message = e.response!.data?.toString();

        return Failure(mapCore(ApiFailure(statusCode, message)));
      }

      return Failure(mapCore(const NetworkFailure()));
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
