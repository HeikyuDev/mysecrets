import 'dart:convert';
import 'dart:typed_data';

import 'package:mysecrets/vault/crypto/vault_cipher.dart';

import 'credential.dart';

class CredentialCodec {
  CredentialCodec._();

  static Uint8List encode({
    required Uint8List dek,
    required Credential credential,
  }) {
    return VaultCipher.encrypt(
      key: dek,
      plaintext: Uint8List.fromList(utf8.encode(credential.toJson())),
    );
  }

  static Credential decode({
    required Uint8List dek,
    required Uint8List ciphertext,
  }) {
    final raw = VaultCipher.decrypt(key: dek, sealed: ciphertext);
    return Credential.fromJson(utf8.decode(raw));
  }
}
