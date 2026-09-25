import 'dart:typed_data';

abstract interface class SessionController {
  Future<void> setAuthTokens(String accessToken, String refreshToken);
  Future<void> clearAccessToken();
  Future<void> clearRefreshToken();

  /// Re-reads persisted tokens after a failed load. Only valid while the
  /// session has no established key material.
  void retrySessionLoad();

  void setMasterKey(Uint8List key);
  void clearMasterKey();
}
