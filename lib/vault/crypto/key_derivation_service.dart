import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'vault_random.dart';

const int kekLengthBytes = 32;
const int defaultIterations = 3;
const int defaultMemoryKiB = 16384;
const int defaultLanes = 1;

class KeyDerivationService {
  KeyDerivationService._();

  static Uint8List deriveKek({
    required String masterPassphrase,
    required Uint8List salt,
    int iterations = defaultIterations,
    int memoryKiB = defaultMemoryKiB,
    int lanes = defaultLanes,
    int outputLength = kekLengthBytes,
  }) {
    if (masterPassphrase.isEmpty) {
      throw ArgumentError.value(masterPassphrase, 'masterPassphrase',
          'must not be empty');
    }
    if (salt.length < 8) {
      throw ArgumentError.value(salt.length, 'salt',
          'must be at least 8 bytes');
    }

    final passphrase = Uint8List.fromList(utf8.encode(masterPassphrase));
    final generator = Argon2BytesGenerator();
    generator.init(
      Argon2Parameters(
        Argon2Parameters.ARGON2_id,
        salt,
        desiredKeyLength: outputLength,
        iterations: iterations,
        memory: memoryKiB,
        lanes: lanes,
        version: Argon2Parameters.ARGON2_VERSION_13,
      ),
    );

    final out = Uint8List(outputLength);
    generator.deriveKey(passphrase, 0, out, 0);
    passphrase.fillRange(0, passphrase.length, 0);
    return out;
  }

  static Uint8List newSalt() => VaultRandom.salt();
}
