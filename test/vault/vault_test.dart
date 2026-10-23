import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/vault/crypto/vault_cipher.dart';
import 'package:mysecrets/vault/crypto/vault_header.dart';
import 'package:mysecrets/vault/vault.dart';

void main() {
  group('Vault seal/unseal', () {
    final payload = Uint8List.fromList('[{"f":"json-like"}]'.codeUnits);

    test('full roundtrip recovers payload', () {
      final dek = Vault.newDek();
      final file = Vault.seal(
          masterPassphrase:
              'a master passphrase of decent strength 42!', dek: dek, payload: payload);
      expect(VaultHeader.decode(file).formatVersion, 1);

      final recoveredDek = Vault.unsealDek(
          masterPassphrase:
              'a master passphrase of decent strength 42!',
          vaultFile: file);
      expect(recoveredDek, dek);

      final recovered =
          Vault.unsealPayload(masterPassphrase: 'a master passphrase of decent strength 42!', vaultFile: file);
      expect(recovered, payload);
    });

    test('wrong passphrase fails to unlock DEK', () {
      final file = Vault.seal(
          masterPassphrase: 'true passphrase', dek: Vault.newDek(), payload: payload);
      expect(
          () => Vault.unsealDek(
              masterPassphrase: 'wrong passphrase', vaultFile: file),
          throwsA(isA<VaultCipherException>()));
    });

    test('payload file not readable without DEK binding', () {
      final file = Vault.seal(
          masterPassphrase: 'true passphrase', dek: Vault.newDek(), payload: payload);
      final headerLength = VaultHeader.decode(file).encode().length;
      final sealedDek = 12 + 32 + 16;
      final tampered = Uint8List.fromList(file);
      tampered[headerLength + sealedDek + 10] ^= 0xFF;
      expect(
          () => Vault.unsealPayload(
              masterPassphrase: 'true passphrase', vaultFile: tampered),
          throwsA(isA<VaultCipherException>()));
    });
  });
}
