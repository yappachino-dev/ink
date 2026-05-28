import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/auth/types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_refresher.g.dart';

// Used as a contract
// ignore: one_member_abstracts
abstract interface class TokenRefresher {
  Future<Result<TokenPayload, CoreFailure>> refreshToken();
}

@Riverpod(keepAlive: true)
TokenRefresher tokenRefresher(Ref ref) =>
    throw UnimplementedError('tokenRefresher must be overriden in main');
