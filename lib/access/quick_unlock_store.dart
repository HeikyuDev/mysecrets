import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../vault/keys/vault_key_store.dart';

/// Port for storing the DEK in OS-protected storage so biometric/PIN gates
/// can unlock without the master passphrase. The OS (Keychain/Keystore)
/// enforces the user-presence check; we never persist plaintext of any kind
/// outside this protection.
abstract class QuickUnlockStore {
  Future<bool> get isEnrolled;

  Future<void> enroll(Uint8List dek);

  Future<Uint8List?> retrieve();

  Future<void> clear();
}

/// User-presence access control: the OS requires the enrolled biometric or
/// device passcode before this item can be read.
class SecureQuickUnlockStore implements QuickUnlockStore {
  final FlutterSecureStorage _storage;

  SecureQuickUnlockStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
                aOptions: AndroidOptions(),
                iOptions: IOSOptions(
                    accessibility:
                        KeychainAccessibility.first_unlock_this_device));

  @override
  Future<bool> get isEnrolled async => await _storage.read(
      key: VaultKeyStore.quickUnlockDekKey) != null;

  @override
  Future<void> enroll(Uint8List dek) async {
    await _storage.write(
      key: VaultKeyStore.quickUnlockDekKey,
      value: base64Encode(dek),
    );
  }

  @override
  Future<Uint8List?> retrieve() async {
    final raw = await _storage.read(key: VaultKeyStore.quickUnlockDekKey);
    if (raw == null) return null;
    return Uint8List.fromList(base64Decode(raw));
  }

  @override
  Future<void> clear() => _storage.delete(key: VaultKeyStore.quickUnlockDekKey);
}
