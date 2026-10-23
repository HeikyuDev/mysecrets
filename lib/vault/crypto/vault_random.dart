import 'dart:math';
import 'dart:typed_data';

class VaultRandom {
  static final Random _secure = Random.secure();

  static Uint8List nextBytes(int length) {
    if (length <= 0) {
      throw ArgumentError.value(length, 'length', 'must be positive');
    }
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _secure.nextInt(256);
    }
    return bytes;
  }

  static Uint8List salt({int length = 16}) => nextBytes(length);

  static Uint8List nonce({int length = 12}) => nextBytes(length);

  static Uint8List dek({int length = 32}) => nextBytes(length);
}
