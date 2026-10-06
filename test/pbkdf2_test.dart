import 'dart:convert';

import 'package:fhir_db/fhir_db.dart';
import 'package:test/test.dart';

/// [pbkdf2] is the one PBKDF2-HMAC-SHA256 in the family: fhir_db derives the
/// SQLCipher key with it, and fhirant's backup encryption and legacy
/// password verification call it too (fhirant REVIEW-2026-09-17 ST6, which
/// found the loop written three times). It had no test of its own. These
/// answers were computed with Python's hashlib on 2026-10-06:
/// `hashlib.pbkdf2_hmac('sha256', password, salt, iterations, dkLen).hex()`
/// — an independent implementation, not this one agreeing with itself.
void main() {
  String hex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  const cases = <(String, String, int, int, String)>[
    (
      'password',
      'salt',
      1,
      32,
      '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b',
    ),
    (
      'password',
      'salt',
      2,
      32,
      'ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43',
    ),
    (
      'password',
      'salt',
      4096,
      32,
      'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a',
    ),
    // dkLen past one HMAC block (32 bytes): the second block's counter.
    (
      'passwordPASSWORDpassword',
      'saltSALTsaltSALTsaltSALTsaltSALTsalt',
      4096,
      40,
      '348c89dbcbd32b2f32d814b8116e84cf2b17347ebc1800181c4e2a1fb8dd53e1'
          'c635518c7dac47e9',
    ),
    // A NUL inside password and salt, and a dkLen under one block.
    (
      'pass\u0000word',
      'sa\u0000lt',
      4096,
      16,
      '89b69d0516f829893c696226650a8687'
    ),
  ];

  for (final (password, salt, iterations, dkLen, expected) in cases) {
    test('pbkdf2($password, $salt, $iterations, $dkLen) = hashlib', () {
      final dk = pbkdf2(
        password: password,
        salt: utf8.encode(salt),
        iterations: iterations,
        keyLength: dkLen,
      );
      expect(dk, hasLength(dkLen));
      expect(hex(dk), expected);
    });
  }
}
