import 'dart:typed_data';

import 'package:mysecrets/vault/crypto/key_derivation_service.dart';
import 'package:mysecrets/vault/crypto/vault_cipher.dart';
import 'package:mysecrets/vault/crypto/vault_random.dart';

import 'vault_key_store.dart';

class KeyManagerException implements Exception {
  final String message;

  KeyManagerException(this.message);

  @override
  String toString() => 'KeyManagerException: $message';
}

class KeyManager {
  final VaultKeyStore _keyStore;

  KeyManager(this._keyStore);

  Future<Uint8List> createVault({
    required String masterPassphrase,
  }) async {
    if (await _keyStore.load(VaultKeyStore.wrappedDekKey) != null) {
      throw KeyManagerException('vault already initialized');
    }
    final salt = KeyDerivationService.newSalt();
    final dek = VaultRandom.dek();
    final kek = KeyDerivationService.deriveKek(
      masterPassphrase: masterPassphrase,
      salt: salt,
      iterations: defaultIterations,
      memoryKiB: defaultMemoryKiB,
      lanes: defaultLanes,
    );
    final sealedDek = VaultCipher.encrypt(key: kek, plaintext: dek);
    await _keyStore.save(
        VaultKeyStore.wrappedDekKey,
        Uint8List.fromList([
          ...salt,
          ...sealedDek,
        ]));
    return dek;
  }

  Future<Uint8List> unlock({
    required String masterPassphrase,
  }) async {
    final stored = await _keyStore.load(VaultKeyStore.wrappedDekKey);
    if (stored == null) {
      throw KeyManagerException('vault not initialized');
    }
    const saltLength = 16;
    final salt = Uint8List.sublistView(stored, 0, saltLength);
    final sealedDek =
        Uint8List.sublistView(stored, saltLength);
    final kek = KeyDerivationService.deriveKek(
      masterPassphrase: masterPassphrase,
      salt: salt,
      iterations: defaultIterations,
      memoryKiB: defaultMemoryKiB,
      lanes: defaultLanes,
    );
    return VaultCipher.decrypt(key: kek, sealed: sealedDek);
  }

  Future<bool> isInitialized() async =>
      await _keyStore.load(VaultKeyStore.wrappedDekKey) != null;

  Future<void> destroy() async {
    await _keyStore.delete(VaultKeyStore.wrappedDekKey);
  }
}
