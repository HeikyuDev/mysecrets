import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/vault/keys/key_manager.dart';
import 'package:mysecrets/vault/keys/vault_key_store.dart';

import 'in_memory_key_store.dart';

void main() {
  group('KeyManager', () {
    late InMemoryKeyStore store;
    late KeyManager manager;

    setUp(() {
      store = InMemoryKeyStore();
      manager = KeyManager(store);
    });

    test('createVault generates DEK and persists only wrapped form', () async {
      final dek = await manager.createVault(masterPassphrase: 'master 1234');
      expect(dek.length, 32);
      expect(await manager.isInitialized(), isTrue);

      final stored = await store.load(VaultKeyStore.wrappedDekKey);
      expect(stored, isNotNull);
      expect(stored!.sublist(16), isNot(equals(dek)),
          reason: 'stored bytes must be ciphertext, not raw DEK');
    });

    test('unlock recovers the same DEK', () async {
      final dek =
          await manager.createVault(masterPassphrase: 'master 1234');
      final recovered = await manager.unlock(masterPassphrase: 'master 1234');
      expect(recovered, dek);
    });

    test('wrong passphrase throws on unlock', () async {
      await manager.createVault(masterPassphrase: 'master 1234');
      await expectLater(manager.unlock(masterPassphrase: 'wrong 9999'),
          throwsA(isA<Exception>()));
    });

    test('second createVault is rejected', () async {
      await manager.createVault(masterPassphrase: 'master 1234');
      expect(
        () => manager.createVault(masterPassphrase: 'another passphrase'),
        throwsA(isA<KeyManagerException>()),
      );
    });

    test('unlock before create throws', () async {
      expect(
        () => manager.unlock(masterPassphrase: 'master 1234'),
        throwsA(isA<KeyManagerException>()),
      );
    });

    test('destroy clears state', () async {
      await manager.createVault(masterPassphrase: 'master 1234');
      await manager.destroy();
      expect(await manager.isInitialized(), isFalse);
      expect(
        () => manager.unlock(masterPassphrase: 'master 1234'),
        throwsA(isA<KeyManagerException>()),
      );
    });
  });
}
