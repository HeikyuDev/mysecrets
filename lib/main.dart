import 'package:flutter/material.dart';

import 'access/auto_lock_service.dart';
import 'app/vault_controller.dart';
import 'ui/screens/enroll_gate_screen.dart';
import 'ui/screens/gate_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/setup_screen.dart';
import 'ui/screens/unlock_screen.dart';
import 'ui/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = VaultController.create();
  runApp(MySecretsApp(controller: controller));
}

class MySecretsApp extends StatefulWidget {
  final VaultController controller;

  const MySecretsApp({super.key, required this.controller});

  @override
  State<MySecretsApp> createState() => _MySecretsAppState();
}

class _MySecretsAppState extends State<MySecretsApp> {
  late final AutoLockService autoLock;

  @override
  void initState() {
    super.initState();
    autoLock = AutoLockService(
      inactivity: const Duration(seconds: 60),
      onLock: () => widget.controller.lock(),
    );
  }

  @override
  void dispose() {
    autoLock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mySecrets',
      theme: AppTheme.dark(),
      builder: (context, child) {
        return Listener(
          onPointerDown: (_) => autoLock.touch(),
          onPointerMove: (_) => autoLock.touch(),
          child: child!,
        );
      },
      home: BootGate(controller: widget.controller),
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
  bool? _biometricsAvailable;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    controller.gate.canUseBiometrics.then((ok) {
      if (mounted) setState(() => _biometricsAvailable = ok);
    });
    controller.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return FutureBuilder<bool>(
          future: controller.gate.hasQuickUnlock,
          builder: (context, quickUnlockSnapshot) {
            switch (controller.phase) {
              case AppPhase.loading:
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              case AppPhase.needsSetup:
                return SetupScreen(
                  onSetup: (p) => controller.setup(masterPassphrase: p),
                );
              case AppPhase.enrollingGate:
                return EnrollGateScreen(
                  biometricsAvailable: _biometricsAvailable ?? false,
                  onEnroll: (pin) => controller.enrollGate(pin: pin),
                );
              case AppPhase.locked:
                final quickUnlock =
                    quickUnlockSnapshot.data ?? false;
                if (quickUnlock) {
                  return GateScreen(
                    gate: controller.gate,
                    onDekReady: controller.unlockWithDek,
                  );
                }
                return UnlockScreen(
                  onUnlock: (p) => controller.unlock(masterPassphrase: p),
                );
              case AppPhase.unlocked:
                return HomeScreen(controller: controller);
            }
          },
        );
      },
    );
  }
}
