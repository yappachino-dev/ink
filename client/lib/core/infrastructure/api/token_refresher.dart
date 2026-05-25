import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';

// Used as a contract
// ignore: one_member_abstracts
abstract interface class TokenRefresher {
  Future<Result<String, CoreFailure>> refreshToken();
}
