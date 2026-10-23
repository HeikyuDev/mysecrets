import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/vault/crypto/vault_cipher.dart';
import 'package:mysecrets/vault/crypto/vault_random.dart';

void main() {
  group('VaultCipher', () {
    final key = VaultRandom.dek();
    final plaintext =
        Uint8List.fromList('{"credentials":[]}'.codeUnits);

    test('roundtrip recovers plaintext', () {
      final sealed = VaultCipher.encrypt(key: key, plaintext: plaintext);
      final out = VaultCipher.decrypt(key: key, sealed: sealed);
      expect(out, equals(plaintext));
    });

    test('different key fails authentication', () {
      final otherKey = VaultRandom.dek();
      final sealed = VaultCipher.encrypt(key: key, plaintext: plaintext);
      expect(() => VaultCipher.decrypt(key: otherKey, sealed: sealed),
          throwsA(isA<VaultCipherException>()));
    });

    test('tampered ciphertext fails authentication', () {
      final sealed = VaultCipher.encrypt(key: key, plaintext: plaintext);
      sealed[sealed.length - 1] ^= 0xFF;
      expect(() => VaultCipher.decrypt(key: key, sealed: sealed),
          throwsA(isA<VaultCipherException>()));
    });

    test('tampered nonce fails authentication', () {
      final sealed = VaultCipher.encrypt(key: key, plaintext: plaintext);
      sealed[2] ^= 0xFF;
      expect(() => VaultCipher.decrypt(key: key, sealed: sealed),
          throwsA(isA<VaultCipherException>()));
    });

    test('nonce is random per encryption', () {
      final a = VaultCipher.encrypt(key: key, plaintext: plaintext);
      final b = VaultCipher.encrypt(key: key, plaintext: plaintext);
      expect(a, isNot(equals(b)));
      final plainA = VaultCipher.decrypt(key: key, sealed: a);
      final plainB = VaultCipher.decrypt(key: key, sealed: b);
      expect(plainA, equals(plaintext));
      expect(plainB, equals(plaintext));
    });

    test('associated data is bound', () {
      final aad = Uint8List.fromList('header'.codeUnits);
      final sealed = VaultCipher.encrypt(
          key: key, plaintext: plaintext, associatedData: aad);
      final tamperedAad = Uint8List.fromList('headeR'.codeUnits);
      expect(
          () => VaultCipher.decrypt(
              key: key, sealed: sealed, associatedData: tamperedAad),
          throwsA(isA<VaultCipherException>()));
      expect(
          VaultCipher.decrypt(
              key: key, sealed: sealed, associatedData: aad),
          equals(plaintext));
    });

    test('rejects too-short sealed data', () {
      final short = Uint8List.fromList(List.filled(20, 0));
      expect(() => VaultCipher.decrypt(key: key, sealed: short),
          throwsA(isA<VaultCipherException>()));
    });
  });
}
