import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'vault_random.dart';

class VaultCipherException implements Exception {
  final String message;

  VaultCipherException(this.message);

  @override
  String toString() => 'VaultCipherException: $message';
}

class VaultCipher {
  static const int _nonceLength = 12;
  static const int _macLengthBits = 128;

  VaultCipher._();

  static Uint8List encrypt({
    required Uint8List key,
    required Uint8List plaintext,
    Uint8List? associatedData,
  }) {
    if (key.isEmpty) {
      throw ArgumentError.value(key, 'key', 'must not be empty');
    }
    final nonce = VaultRandom.nonce(length: _nonceLength);
    final gcm = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(KeyParameter(key), _macLengthBits, nonce,
            associatedData ?? Uint8List(0)),
      );

    final cipherText = Uint8List(plaintext.length + _macLengthBits ~/ 8);
    var pos = gcm.processBytes(plaintext, 0, plaintext.length, cipherText, 0);
    pos += gcm.doFinal(cipherText, pos);

    final out = BytesBuilder();
    out.add(nonce);
    out.add(Uint8List.sublistView(cipherText, 0, pos));
    return out.toBytes();
  }

  static Uint8List decrypt({
    required Uint8List key,
    required Uint8List sealed,
    Uint8List? associatedData,
  }) {
    if (sealed.length < _nonceLength + _macLengthBits ~/ 8) {
      throw VaultCipherException('sealed data too short');
    }
    final nonce = Uint8List.sublistView(sealed, 0, _nonceLength);
    final cipherText = Uint8List.sublistView(sealed, _nonceLength);
    final gcm = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(KeyParameter(key), _macLengthBits, nonce,
            associatedData ?? Uint8List(0)),
      );

    final plain = Uint8List(cipherText.length);    var pos = 0;
    try {
      pos = gcm.processBytes(
          cipherText, 0, cipherText.length, plain, 0);
      pos += gcm.doFinal(plain, pos);
    } on InvalidCipherTextException {
      throw VaultCipherException(
          'authentication failed: wrong key or tampered data');
    }
    return Uint8List.sublistView(plain, 0, pos);
  }
}
