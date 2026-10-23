import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/vault/credential.dart';
import 'package:mysecrets/vault/crypto/vault_cipher.dart';
import 'package:mysecrets/vault/crypto/vault_header.dart';
import 'package:mysecrets/vault/export/vault_export_service.dart';

void main() {
  group('VaultExportService', () {
    final now = DateTime.utc(2026, 1, 1, 12, 0);
    final credentials = [
      Credential(
        id: 'a',
        platform: 'GitHub',
        username: 'n@x.io',
        password: 'g4rb41g0-symbols!#',
        notes: null,
        createdAtUtc: now,
        updatedAtUtc: now,
        lastChangedUtc: now,
      ),
      Credential(
        id: 'b',
        platform: 'Bank',
        username: 'user2',
        password: 'p@55w0rd',
        notes: 'main',
        createdAtUtc: now,
        updatedAtUtc: now,
        lastChangedUtc: now,
      ),
    ];

    test('export/restore roundtrip recovers 100% of credentials', () {
      final file = VaultExportService.export(
          masterPassphrase: 'strong master p4ssphrase!', credentials: credentials);
      final restored = VaultExportService.restore(
          masterPassphrase: 'strong master p4ssphrase!', vaultFile: file);
      expect(restored.length, 2);
      expect(restored[0].platform, 'GitHub');
      expect(restored[0].password, 'g4rb41g0-symbols!#');
      expect(restored[1].notes, 'main');
    });

    test('wrong passphrase does not restore', () {
      final file = VaultExportService.export(
          masterPassphrase: 'strong master p4ssphrase!', credentials: credentials);
      expect(
        () => VaultExportService.restore(
            masterPassphrase: 'wrong-passphrase', vaultFile: file),
        throwsA(isA<VaultCipherException>()),
      );
    });

    test('tampered file does not restore', () {
      final file = VaultExportService.export(
          masterPassphrase: 'strong master p4ssphrase!', credentials: credentials);
      final tampered = Uint8List.fromList(file);
      tampered[tampered.length - 3] ^= 0xFF;
      expect(
        () => VaultExportService.restore(
            masterPassphrase: 'strong master p4ssphrase!', vaultFile: tampered),
        throwsA(isA<Exception>()),
      );
    });

    test('unknown future format version rejected', () {
      final file = VaultExportService.export(
          masterPassphrase: 'strong master p4ssphrase!', credentials: credentials);
      final tampered = Uint8List.fromList(file);
      tampered[5] = 99;
      expect(
        () => VaultExportService.restore(
            masterPassphrase: 'strong master p4ssphrase!', vaultFile: tampered),
        throwsA(isA<VaultHeaderException>()),
      );
    });
  });
}
