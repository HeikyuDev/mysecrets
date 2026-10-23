import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../vault/keys/vault_key_store.dart';

class PinService {
  static const int saltLength = 16;
  static const int hashLength = 32;
  static const int iterations = 120000;

  PinService();

  Future<void> enroll(
      {required VaultKeyStore store, required String pin}) async {
    _assertPin(pin);
    final salt = _secureSalt();
    final hash = _derive(pin, salt);
    await store.save(VaultKeyStore.pinHashKey, Uint8List.fromList([
      ...salt,
      ...hash,
    ]));
  }

  Future<bool> verify(
      {required VaultKeyStore store, required String pin}) async {
    final stored = await store.load(VaultKeyStore.pinHashKey);
    if (stored == null) return false;
    final salt = Uint8List.sublistView(stored, 0, saltLength);
    final expected = Uint8List.sublistView(stored, saltLength);
    final candidate = _derive(pin, salt);
    return constantTimeEquals(expected, candidate);
  }

  Uint8List _derive(String pin, Uint8List salt) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, iterations, hashLength));
    final out = Uint8List(hashLength);
    derivator.deriveKey(
        Uint8List.fromList(utf8.encode(pin)), 0, out, 0);
    return out;
  }

  static void _assertPin(String pin) {
    if (pin.length != 6 || !RegExp(r'^\d+$').hasMatch(pin)) {
      throw ArgumentError.value(pin, 'pin', 'must be exactly 6 digits');
    }
  }

  static bool constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  Uint8List _secureSalt() {
    final r = Random.secure();
    return Uint8List.fromList(
        List.generate(saltLength, (_) => r.nextInt(256)));
  }
}
