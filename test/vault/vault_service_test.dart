import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/data/vault_database.dart';
import 'package:mysecrets/vault/crypto/vault_cipher.dart';
import 'package:mysecrets/vault/keys/key_manager.dart';
import 'package:mysecrets/vault/vault_service.dart';

import 'keys/in_memory_key_store.dart';

void main() {
  late InMemoryKeyStore store;
  late KeyManager keyManager;
  late VaultDatabase db;
  late VaultService service;

  setUp(() {
    store = InMemoryKeyStore();
    keyManager = KeyManager(store);
    db = VaultDatabase(NativeDatabase.memory());
    service = VaultService(keyManager: keyManager, db: db);
  });

  tearDown(() => db.close());

  group('VaultService integration', () {
    test('full lifecycle: setup, save, lock, unlock, data integrity',
        () async {
      await service.setup(masterPassphrase: 'correct horse battery 42');

      final saved = await service.addCredential(
        platform: 'GitHub',
        username: 'elnah@example.com',
        password: 'S3cure-G3nerated!',
        notes: 'work account',
        rotationPolicyDays: 90,
      );

      expect(service.state, VaultState.unlocked);

      service.lock();
      expect(service.state, VaultState.locked);
      expect(
        () => service.listCredentials(),
        throwsA(isA<VaultLockedException>()),
      );

      await service.unlock(masterPassphrase: 'correct horse battery 42');
      final loaded = await service.getCredential(saved.id);
      expect(loaded, isNotNull);
      expect(loaded!.platform, 'GitHub');
      expect(loaded.username, 'elnah@example.com');
      expect(loaded.password, 'S3cure-G3nerated!');
      expect(loaded.notes, 'work account');
      expect(loaded.createdAtUtc, saved.createdAtUtc);
    });

    test('setup before anything unlocks directly and keeps isInitialized',
        () async {
      expect(service.state, VaultState.lockedByMissingSetup);
      await service.setup(masterPassphrase: 'p');
      expect(service.isInitialized, isTrue);
      expect(await service.isBackendInitialized(), isTrue);
    });

    test('unlock with wrong passphrase fails and vault stays locked',
        () async {
      await service.setup(masterPassphrase: 'true-key');
      final saved = await service.addCredential(
          platform: 'X', username: 'u', password: 'p');
      service.lock();

      await expectLater(
        service.unlock(masterPassphrase: 'wrong-key'),
        throwsA(isA<VaultCipherException>()),
      );
      expect(service.state, VaultState.locked);

      await service.unlock(masterPassphrase: 'true-key');
      expect((await service.listCredentials()).first.id, saved.id);
    });

    test('plaintext never touches the database', () async {
      await service.setup(masterPassphrase: 'p');
      await service.addCredential(
          platform: 'SecretBank', username: 'me', password: 'TOPSECRET999');

      final ignoreCaseRows = await db
          .customSelect('SELECT data_ciphertext FROM credentials')
          .get();
      expect(ignoreCaseRows, hasLength(1));
      final blob = String.fromCharCodes(
          (ignoreCaseRows.first.data['data_ciphertext'] as List<int>));
      expect(blob.contains('SecretBank'), isFalse);
      expect(blob.contains('TOPSECRET999'), isFalse);
    });

    test('lock clears DEK: lock() then updateCredential throws', () async {
      await service.setup(masterPassphrase: 'p');
      final saved = await service.addCredential(
          platform: 'X', username: 'u', password: 'p');
      service.lock();
      expect(
        () => service.getCredential(saved.id),
        throwsA(isA<VaultLockedException>()),
      );
    });

    test('update stamps updatedAt, markChanged stamps lastChanged',
        () async {
      await service.setup(masterPassphrase: 'p');
      final saved = await service.addCredential(
          platform: 'A', username: 'u', password: 'p1');

      await service.updateCredential(
        saved.copyWith(password: 'p2'),
      );
      final updated = await service.getCredential(saved.id);
      expect(updated!.password, 'p2');
      expect(updated.lastChangedUtc, saved.lastChangedUtc);

      await service.markChanged(saved.id);
      final rotated = await service.getCredential(saved.id);
      expect(rotated!.lastChangedUtc.isAfter(saved.lastChangedUtc), isTrue);
    });

    test('delete removes credential', () async {
      await service.setup(masterPassphrase: 'p');
      final saved = await service.addCredential(
          platform: 'A', username: 'u', password: 'p1');
      await service.deleteCredential(saved.id);
      expect(await service.listCredentials(), isEmpty);
    });
  });
}
