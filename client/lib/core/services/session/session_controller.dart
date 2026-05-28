import 'dart:typed_data';

abstract interface class SessionController {
  void setAuthTokens(String accessToken, String refreshToken);
  void clearAccessToken();
  void clearRefreshToken();

  void setMasterKey(Uint8List key);
  void clearMasterKey();
}
