import 'package:flutter/material.dart';

import 'app/vault_controller.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/setup_screen.dart';
import 'ui/screens/unlock_screen.dart';
import 'ui/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = VaultController.create();
  runApp(MySecretsApp(controller: controller));
}

class MySecretsApp extends StatelessWidget {
  final VaultController controller;

  const MySecretsApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mySecrets',
      theme: AppTheme.dark(),
      home: BootGate(controller: controller),
    );
  }
}

class BootGate extends StatefulWidget {
  final VaultController controller;

  const BootGate({super.key, required this.controller});

  @override
  State<BootGate> createState() => _BootGateState();
}

class _BootGateState extends State<BootGate> {
  late final VaultController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    controller.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        switch (controller.phase) {
          case AppPhase.loading:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case AppPhase.needsSetup:
            return SetupScreen(onSetup: (p) => controller.setup(masterPassphrase: p));
          case AppPhase.locked:
            return UnlockScreen(
                onUnlock: (p) => controller.unlock(masterPassphrase: p));
          case AppPhase.unlocked:
            return HomeScreen(controller: controller);
        }
      },
    );
  }
}
