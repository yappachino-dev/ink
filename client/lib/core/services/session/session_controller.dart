import 'dart:typed_data';

abstract interface class SessionController {
  void setAuthToken(String? token);
  void setMasterKey(Uint8List key);
  void clearSession();
}
