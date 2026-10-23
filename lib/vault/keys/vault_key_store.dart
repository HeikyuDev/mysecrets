import 'dart:typed_data';

abstract class VaultKeyStore {
  static const String wrappedDekKey = 'vault.wrapped_dek';

  Future<void> save(String key, Uint8List value);

  Future<Uint8List?> load(String key);

  Future<void> delete(String key);
}
