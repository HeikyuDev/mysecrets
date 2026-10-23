import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/app/vault_controller.dart';
import 'package:mysecrets/data/vault_database.dart';
import 'package:mysecrets/main.dart';
import 'package:mysecrets/ui/screens/setup_screen.dart';
import 'package:mysecrets/vault/keys/key_manager.dart';
import 'package:mysecrets/vault/vault_service.dart';

import 'vault/keys/in_memory_key_store.dart';

void main() {
  testWidgets('app boots into setup screen when no vault exists',
      (tester) async {
    final db = VaultDatabase(NativeDatabase.memory());
    final controller = VaultController(
      vault: VaultService(
        keyManager: KeyManager(InMemoryKeyStore()),
        db: db,
      ),
      db: db,
    );
    await tester.pumpWidget(MySecretsApp(controller: controller));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(SetupScreen), findsOneWidget);
  });
}
