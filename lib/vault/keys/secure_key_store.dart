import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'vault_key_store.dart';

class SecureKeyStore implements VaultKeyStore {
  final FlutterSecureStorage _storage;

  SecureKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
                aOptions: AndroidOptions(encryptedSharedPreferences: true));

  @override
  Future<void> save(String key, Uint8List value) async {
    await _storage.write(key: key, value: base64Encode(value));
  }

  @override
  Future<Uint8List?> load(String key) async {
    final raw = await _storage.read(key: key);
    if (raw == null) return null;
    return Uint8List.fromList(base64Decode(raw));
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}
