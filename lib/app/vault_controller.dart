import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../access/biometric_port.dart';
import '../access/gate_controller.dart';
import '../access/pin_service.dart';
import '../access/quick_unlock_store.dart';
import '../data/vault_database.dart' hide Credential;
import '../reminders/os_notifier.dart';
import '../reminders/reminder_service.dart';
import '../vault/credential.dart';
import '../vault/export/vault_export_service.dart';
import '../vault/keys/key_manager.dart';
import '../vault/keys/secure_key_store.dart';
import '../vault/vault_service.dart';

enum AppPhase { loading, needsSetup, enrollingGate, locked, unlocked }

class VaultController extends ChangeNotifier {
  final VaultService vault;
  final VaultDatabase db;
  final GateController gate;
  final ReminderService reminders;
  Timer? _recheckTimer;

  AppPhase phase = AppPhase.loading;
  List<Credential> credentials = const [];

  VaultController({
    required this.vault,
    required this.db,
    required this.gate,
    ReminderService? reminders,
  }) : reminders = reminders ??
            ReminderService(notifier: OsNotifier());

  static VaultController create() {
    final store = SecureKeyStore();
    final db = VaultDatabase.open();
    return VaultController(
      vault: VaultService(keyManager: KeyManager(store), db: db),
      db: db,
      gate: GateController(
        pinService: PinService(),
        keyStore: store,
        quickUnlockStore: SecureQuickUnlockStore(),
        biometricPort: LocalAuthBiometricPort(),
      ),
    );
  }

  Future<void> bootstrap() async {
    if (await vault.isBackendInitialized()) {
      phase = AppPhase.locked;
    } else {
      phase = AppPhase.needsSetup;
    }
    await refreshCredentials();
    notifyListeners();
  }

  Future<void> setup({required String masterPassphrase}) async {
    await vault.setup(masterPassphrase: masterPassphrase);
    phase = AppPhase.enrollingGate;
    await refreshCredentials();
    notifyListeners();
  }

  /// Enrolls PIN (+optional biometric) quick unlock using the DEK exposed by
  /// an already-unlocked vault.
  Future<void> enrollGate({required String pin}) async {
    final dek = vault.exposeDek();
    await gate.enrollQuickUnlock(pin: pin, dek: dek);
    phase = AppPhase.unlocked;
    notifyListeners();
  }

  Future<bool> unlockWithDek(Uint8List dek) async {
    vault.unlockWithDek(dek);
    phase = AppPhase.unlocked;
    await refreshCredentials();
    await _remindDue();
    _scheduleWeeklyRecheck();
    notifyListeners();
    return true;
  }

  /// Posts/clears rotation notifications for every stored credential.
  Future<List<Credential>> _remindDue() async {
    if (credentials.isEmpty) return const [];
    return reminders.process(
      credentials: credentials,
      nowUtc: DateTime.now().toUtc(),
    );
  }

  void _scheduleWeeklyRecheck() {
    _recheckTimer?.cancel();
    _recheckTimer = Timer.periodic(
        const Duration(days: 7), (_) async {
      await _remindDue();
    });
  }

  Future<bool> unlock({required String masterPassphrase}) async {
    try {
      await vault.unlock(masterPassphrase: masterPassphrase);
      phase = AppPhase.unlocked;
      await refreshCredentials();
      await _remindDue();
      _scheduleWeeklyRecheck();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void lock() {
    vault.lock();
    _recheckTimer?.cancel();
    credentials = const [];
    phase = AppPhase.locked;
    notifyListeners();
  }

  @override
  void dispose() {
    _recheckTimer?.cancel();
    super.dispose();
  }

  Future<void> refreshCredentials() async {
    if (phase != AppPhase.unlocked) return;
    credentials = await vault.listCredentials();
    notifyListeners();
  }

  Future<Credential> addCredential({
    required String platform,
    required String username,
    required String password,
    String? notes,
    int? rotationPolicyDays,
  }) async {
    final saved = await vault.addCredential(
      platform: platform,
      username: username,
      password: password,
      notes: notes,
      rotationPolicyDays: rotationPolicyDays,
    );
    await refreshCredentials();
    return saved;
  }

  Future<void> deleteCredential(String id) async {
    await vault.deleteCredential(id);
    await refreshCredentials();
  }

  Future<void> markChanged(String id) async {
    await vault.markChanged(id);
    await refreshCredentials();
  }

  Future<Uint8List> exportEncrypted({required String masterPassphrase}) {
    return Future.value(
      VaultExportService.export(
        masterPassphrase: masterPassphrase,
        credentials: credentials,
      ),
    );
  }
}
