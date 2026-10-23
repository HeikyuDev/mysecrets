import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/vault/crypto/key_derivation_service.dart';

void main() {
  group('KeyDerivationService', () {
    final salt = Uint8List.fromList(List.filled(16, 0x42));

    test('derives deterministic KEK for same passphrase, salt and params', () {
      final a = KeyDerivationService.deriveKek(
          masterPassphrase: 'correct horse battery staple', salt: salt);
      final b = KeyDerivationService.deriveKek(
          masterPassphrase: 'correct horse battery staple', salt: salt);
      expect(a, equals(b));
    });

    test('different passphrase yields different KEK', () {
      final a = KeyDerivationService.deriveKek(
          masterPassphrase: 'correct horse', salt: salt);
      final b = KeyDerivationService.deriveKek(
          masterPassphrase: 'wrong horse', salt: salt);
      expect(a, isNot(equals(b)));
    });

    test('different salt yields different KEK', () {
      final otherSalt =
          Uint8List.fromList(List.filled(16, 0x43));
      final a = KeyDerivationService.deriveKek(
          masterPassphrase: 'p', salt: salt);
      final b = KeyDerivationService.deriveKek(
          masterPassphrase: 'p', salt: otherSalt);
      expect(a, isNot(equals(b)));
    });

    test('rejects empty passphrase', () {
      expect(
          () => KeyDerivationService.deriveKek(
              masterPassphrase: '', salt: salt),
          throwsArgumentError);
    });

    test('rejects short salt', () {
      final shortSalt = Uint8List.fromList(List.filled(4, 0x01));
      expect(
          () => KeyDerivationService.deriveKek(
              masterPassphrase: 'p', salt: shortSalt),
          throwsArgumentError);
    });

    test('produces 32-byte output by default', () {
      final kek = KeyDerivationService.deriveKek(
          masterPassphrase: 'p', salt: salt);
      expect(kek.length, 32);
    });
  });
}
