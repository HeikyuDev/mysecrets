import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/access/gate_controller.dart';
import 'package:mysecrets/access/pin_service.dart';
import 'package:mysecrets/app/vault_controller.dart';
import 'package:mysecrets/data/vault_database.dart';
import 'package:mysecrets/main.dart';
import 'package:mysecrets/ui/screens/setup_screen.dart';
import 'package:mysecrets/vault/keys/key_manager.dart';
import 'package:mysecrets/vault/vault_service.dart';

import 'access/fakes.dart';
import 'vault/keys/in_memory_key_store.dart';

void main() {
  testWidgets('app boots into setup screen when no vault exists',
      (tester) async {
    final db = VaultDatabase(NativeDatabase.memory());
    final store = InMemoryKeyStore();
    final controller = VaultController(
      vault: VaultService(
        keyManager: KeyManager(store),
        db: db,
      ),
      db: db,
      gate: GateController(
        pinService: PinService(),
        keyStore: store,
        quickUnlockStore: InMemoryQuickUnlockStore(),
        biometricPort: StubBiometricPort(),
      ),
    );
    await tester.pumpWidget(MySecretsApp(controller: controller));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(SetupScreen), findsOneWidget);
  });
}
