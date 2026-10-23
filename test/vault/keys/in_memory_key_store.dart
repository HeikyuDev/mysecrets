import 'dart:typed_data';

import 'package:mysecrets/vault/keys/vault_key_store.dart';

class InMemoryKeyStore implements VaultKeyStore {
  final Map<String, Uint8List> _map = {};

  @override
  Future<void> save(String key, Uint8List value) async {
    _map[key] = Uint8List.fromList(value);
  }

  @override
  Future<Uint8List?> load(String key) async {
    final v = _map[key];
    return v == null ? null : Uint8List.fromList(v);
  }

  @override
  Future<void> delete(String key) async {
    _map.remove(key);
  }
}
