import 'dart:typed_data';

abstract class VaultKeyStore {
  static const String wrappedDekKey = 'vault.wrapped_dek';
  static const String quickUnlockDekKey = 'vault.quick_unlock_dek';
  static const String pinHashKey = 'gate.pin_hash';

  Future<void> save(String key, Uint8List value);

  Future<Uint8List?> load(String key);

  Future<void> delete(String key);
}
