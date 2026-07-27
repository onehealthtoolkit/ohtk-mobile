import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/services/jwt.dart';

/// Build a minimal unsigned JWT with the given exp (unix seconds).
String _jwtWithExp(int expSeconds) {
  String b64(Map<String, dynamic> map) {
    final json = jsonEncode(map);
    return base64Url.encode(utf8.encode(json)).replaceAll('=', '');
  }

  final header = b64({'alg': 'none', 'typ': 'JWT'});
  final payload = b64({'exp': expSeconds});
  return '$header.$payload.sig';
}

void main() {
  group('Jwt skew used by ensureValidAccessToken', () {
    test('isExpired is true inside 3-minute skew before exp', () {
      final now = DateTime.now().toUtc();
      final exp = now.add(const Duration(minutes: 2)).millisecondsSinceEpoch ~/
          1000;
      final token = _jwtWithExp(exp);
      expect(Jwt.isExpired(token), isTrue);
    });

    test('isExpired is false when exp is beyond 3-minute skew', () {
      final now = DateTime.now().toUtc();
      final exp = now.add(const Duration(minutes: 10)).millisecondsSinceEpoch ~/
          1000;
      final token = _jwtWithExp(exp);
      expect(Jwt.isExpired(token), isFalse);
    });

    test('isExpired is true after real exp', () {
      final now = DateTime.now().toUtc();
      final exp = now.subtract(const Duration(minutes: 1)).millisecondsSinceEpoch ~/
          1000;
      final token = _jwtWithExp(exp);
      expect(Jwt.isExpired(token), isTrue);
    });
  });
}
