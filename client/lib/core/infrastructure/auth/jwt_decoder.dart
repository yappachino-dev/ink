import 'dart:convert';

extension JwtDecoder on String {
  Map<String, dynamic> jwtDecode() {
    try {
      final parts = split('.');
      if (parts.length != 3) {
        throw const FormatException('Invalid JWT token structure.');
      }

      final payload = parts[1];

      final normalizedPayload = base64Url.normalize(payload);
      final decodedString = utf8.decode(base64Url.decode(normalizedPayload));

      return jsonDecode(decodedString) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Failed to decode JWT payload: $e');
    }
  }

  DateTime? jwtExpirationDate() {
    final decoded = jwtDecode();
    final exp = decoded['exp'] as int?;

    if (exp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
  }

  bool isJwtExpired({Duration buffer = const Duration(seconds: 10)}) {
    try {
      final expirationDate = jwtExpirationDate();
      if (expirationDate == null) return true;

      final now = DateTime.now().toUtc();

      return now.isAfter(expirationDate.subtract(buffer));
    } catch (_) {
      return true;
    }
  }
}
