import 'package:ink/core/domain/result.dart';
import 'package:ink/core/services/session/session_manager.dart';
import 'package:ink/features/auth/data/unified_auth_repository.dart';
import 'package:ink/features/auth/domain/auth_repository.dart';
import 'package:ink/features/auth/domain/auth_service.dart';
import 'package:ink/features/auth/domain/failures/auth_failure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service_impl.g.dart';

class AuthServiceImpl implements AuthService {
  const AuthServiceImpl({
    required AuthRepository repo,
    required SessionManager sessionManager,
  }) : _repo = repo,
       _sessionManager = sessionManager;

  final AuthRepository _repo;
  final SessionManager _sessionManager;

  @override
  Future<Result<void, AuthFailure>> login(String email, String password) async {
    final result = await _repo.login(email, password);

    if (result case Failure(error: final e)) return Failure(e);
    final accessToken = result.unwrap;

    _sessionManager.setAuthToken(accessToken);

    return const Success(null);
  }

  @override
  Future<Result<void, AuthFailure>> requestVerification(String email) {
    return _repo.requestVerification(email);
  }

  @override
  Future<Result<void, AuthFailure>> register(
    String email,
    String password,
    String code,
  ) async {
    final result = await _repo.register(email, password, code);

    if (result case Failure(error: final e)) return Failure(e);
    final accessToken = result.unwrap;

    _sessionManager.setAuthToken(accessToken);

    return const Success(null);
  }
}

@riverpod
AuthService authService(Ref ref) => AuthServiceImpl(
  repo: ref.watch(authRepositoryProvider),
  sessionManager: ref.watch(sessionManagerProvider.notifier),
);
