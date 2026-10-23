import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/vault/crypto/vault_header.dart';
import 'package:mysecrets/vault/crypto/vault_random.dart';

void main() {
  group('VaultHeader', () {
    test('encode/decode roundtrip', () {
      final header = VaultHeader.create(
          iterations: 3, memoryKiB: 16384, lanes: 1, salt: VaultRandom.salt());
      final decoded = VaultHeader.decode(header.encode());
      expect(decoded.formatVersion, 1);
      expect(decoded.iterations, header.iterations);
      expect(decoded.memoryKiB, header.memoryKiB);
      expect(decoded.lanes, header.lanes);
      expect(decoded.salt, header.salt);
    });

    test('rejects wrong magic bytes', () {
      final bytes = Uint8List.fromList([0, 0, 0, 0, 0, 1]);
      expect(() => VaultHeader.decode(bytes),
          throwsA(isA<VaultHeaderException>()));
    });

    test('rejects unknown future version', () {
      final header = VaultHeader.create(
          iterations: 3, memoryKiB: 16384, lanes: 1, salt: VaultRandom.salt());
      final bytes = header.encode();
      bytes[5] = 99;
      expect(() => VaultHeader.decode(bytes),
          throwsA(isA<VaultHeaderException>()));
    });

    test('rejects truncated header', () {
      final header = VaultHeader.create(
          iterations: 3, memoryKiB: 16384, lanes: 1, salt: VaultRandom.salt());
      final bytes = header.encode();
      expect(() => VaultHeader.decode(Uint8List.sublistView(bytes, 0, 4)),
          throwsA(isA<VaultHeaderException>()));
    });

    test('magic bytes are MYSEC', () {
      final header = VaultHeader.create(
          iterations: 3, memoryKiB: 16384, lanes: 1, salt: VaultRandom.salt());
      final bytes = header.encode();
      expect([bytes[0], bytes[1], bytes[2], bytes[3], bytes[4]],
          [0x4D, 0x59, 0x53, 0x45, 0x43]);
    });
  });
}
