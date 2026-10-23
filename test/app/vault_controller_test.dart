import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/app/vault_controller.dart';
import 'package:mysecrets/data/vault_database.dart';
import 'package:mysecrets/vault/keys/key_manager.dart';
import 'package:mysecrets/vault/vault_service.dart';

import '../vault/keys/in_memory_key_store.dart';

void main() {
  late VaultController controller;

  setUp(() {
    final db = VaultDatabase(NativeDatabase.memory());
    controller = VaultController(
      vault: VaultService(
        keyManager: KeyManager(InMemoryKeyStore()),
        db: db,
      ),
      db: db,
    );
  });

  tearDown(() async {
    await (controller.db as dynamic).close();
  });

  test('bootstrap reports needsSetup when no master key stored', () async {
    expect(controller.phase, AppPhase.loading);
    await controller.bootstrap();
    expect(controller.phase, AppPhase.needsSetup);
  });

  test('setup -> unlocked, credentials visible; lock -> locked', () async {
    await controller.bootstrap();
    await controller.setup(masterPassphrase: 'master-with-strength 42!');
    expect(controller.phase, AppPhase.unlocked);

    await controller.addCredential(
        platform: 'Test', username: 'u', password: 'p');
    expect(controller.credentials, hasLength(1));
    expect(controller.credentials.first.platform, 'Test');

    controller.lock();
    expect(controller.phase, AppPhase.locked);
    expect(controller.credentials, isEmpty);
  });

  test('unlock with wrong passphrase keeps locked', () async {
    await controller.bootstrap();
    await controller.setup(masterPassphrase: 'right');
    controller.lock();
    final ok = await controller.unlock(masterPassphrase: 'wrong');
    expect(ok, isFalse);
    expect(controller.phase, AppPhase.locked);
    final ok2 = await controller.unlock(masterPassphrase: 'right');
    expect(ok2, isTrue);
    expect(controller.phase, AppPhase.unlocked);
  });
}
