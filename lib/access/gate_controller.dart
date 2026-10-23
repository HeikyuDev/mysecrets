import 'dart:math';

import 'package:flutter/foundation.dart';

import 'biometric_port.dart';
import 'pin_service.dart';
import 'quick_unlock_store.dart';
import '../vault/keys/vault_key_store.dart';

class GateDecision {
  final bool unlocked;
  final int retryAfterSeconds;
  final Uint8List? dek;

  const GateDecision(
      {required this.unlocked, this.retryAfterSeconds = 0, this.dek});
}

class GateController extends ChangeNotifier {
  final PinService pinService;
  final VaultKeyStore keyStore;
  final QuickUnlockStore quickUnlockStore;
  final BiometricPort biometricPort;

  int _failedAttempts = 0;
  bool _busy = false;

  GateController({
    required this.pinService,
    required this.keyStore,
    required this.quickUnlockStore,
    required this.biometricPort,
  });

  bool get busy => _busy;

  int get retryAfterSeconds =>
      _failedAttempts == 0 ? 0 : (1 << min(_failedAttempts, 6));

  Future<bool> get hasPinEnrolled =>
      keyStore.load(VaultKeyStore.pinHashKey).then((v) => v != null);

  Future<bool> get hasQuickUnlock => quickUnlockStore.isEnrolled;

  Future<bool> get canUseBiometrics => biometricPort.canUseBiometrics();

  /// Enrolls the PIN and stores the DEK under OS user-presence protection,
  /// enabling biometric/PIN unlock for future sessions.
  Future<void> enrollQuickUnlock({
    required String pin,
    required Uint8List dek,
  }) async {
    await pinService.enroll(store: keyStore, pin: pin);
    await quickUnlockStore.enroll(dek);
    notifyListeners();
  }

  Future<GateDecision> unlockWithBiometrics() async {
    if (_busy) return const GateDecision(unlocked: false);
    _busy = true;
    notifyListeners();
    try {
      final wait = retryAfterSeconds;
      if (wait > 0) {
        return GateDecision(unlocked: false, retryAfterSeconds: wait);
      }
      final result = await biometricPort.authenticate(
          reason: 'Unlock your mySecrets vault');
      if (result == BiometricResult.success) {
        return _retrieveDek();
      }
      return const GateDecision(unlocked: false);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<GateDecision> unlockWithPin(String pin) async {
    final wait = retryAfterSeconds;
    if (wait > 0) {
      return GateDecision(unlocked: false, retryAfterSeconds: wait);
    }
    final ok = await pinService.verify(store: keyStore, pin: pin);
    if (!ok) {
      _failedAttempts++;
      notifyListeners();
      return GateDecision(
          unlocked: false, retryAfterSeconds: retryAfterSeconds);
    }
    _failedAttempts = 0;
    return _retrieveDek();
  }

  GateDecision _retrieveDek() {
    return GateDecision(unlocked: true);
  }

  /// The app layer calls this after a successful gate decision to hand the
  /// retrieved DEK to VaultService.
  Future<Uint8List?> retrieveDekForUnlock() => quickUnlockStore.retrieve();

  void reset() {
    _failedAttempts = 0;
    notifyListeners();
  }
}
