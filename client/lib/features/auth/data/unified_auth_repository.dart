import 'package:ink/core/domain/auth_tokens.dart';
import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/auth/token_refresher.dart';
import 'package:ink/core/infrastructure/data_source_runner.dart';
import 'package:ink/features/auth/data/mappers/auth_failure_mapper.dart';
import 'package:ink/features/auth/data/sources/auth_remote_data_source.dart';
import 'package:ink/features/auth/domain/auth_repository.dart';
import 'package:ink/features/auth/domain/failures/auth_failure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unified_auth_repository.g.dart';

class UnifiedAuthRepository
    with DataSourceRunner
    implements AuthRepository, TokenRefresher {
  UnifiedAuthRepository({required AuthRemoteDataSource remote})
    : _remote = remote;

  final AuthRemoteDataSource _remote;

  // --- Repository interface implementation ---

  @override
  Future<Result<TokenPayload, AuthFailure>> login(
    String email,
    String password,
  ) {
    return remoteRunner(
      call: () => _remote.login((email: email, password: password)),
      mapCore: mapAuthCoreFailure,
    );
  }

  @override
  Future<Result<void, AuthFailure>> requestVerification(String email) {
    return remoteRunner(
      call: () => _remote.requestVerification((email: email)),
      mapCore: mapAuthCoreFailure,
    );
  }

  @override
  Future<Result<TokenPayload, AuthFailure>> register(
    String email,
    String password,
    String code,
  ) {
    return remoteRunner(
      call: () =>
          _remote.register((email: email, password: password, code: code)),
      mapCore: mapAuthCoreFailure,
    );
  }

  @override
  Future<Result<void, AuthFailure>> logout(String refreshToken) {
    return remoteRunner(
      call: () => _remote.logout(refreshToken),
      mapCore: mapAuthCoreFailure,
    );
  }

  // --- Token refresher interface implementation ---

  @override
  Future<Result<TokenPayload, CoreFailure>> refreshTokens(
    String refreshToken,
  ) async {
    if (_ongoingRefresh != null) return _ongoingRefresh!;

    _ongoingRefresh = _performRefresh(
      refreshToken,
    ).whenComplete(() => _ongoingRefresh = null);

    return _ongoingRefresh!;
  }

  Future<Result<TokenPayload, CoreFailure>>? _ongoingRefresh;

  Future<Result<TokenPayload, CoreFailure>> _performRefresh(
    String refreshToken,
  ) {
    return remoteRunner(
      call: () => _remote.refresh(refreshToken),
      mapCore: (core) => core,
    );
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    ref.watch(unifiedAuthRepositoryProvider);

@Riverpod(keepAlive: true)
UnifiedAuthRepository unifiedAuthRepository(Ref ref) =>
    UnifiedAuthRepository(remote: ref.watch(authRemoteDataSourceProvider));
