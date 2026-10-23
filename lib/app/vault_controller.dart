import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/vault_database.dart' hide Credential;
import '../vault/credential.dart';
import '../vault/export/vault_export_service.dart';
import '../vault/keys/key_manager.dart';
import '../vault/keys/secure_key_store.dart';
import '../vault/vault_service.dart';

enum AppPhase { loading, needsSetup, locked, unlocked }

class VaultController extends ChangeNotifier {
  final VaultService vault;
  final VaultDatabase db;

  AppPhase phase = AppPhase.loading;
  List<Credential> credentials = const [];

  VaultController({required this.vault, required this.db});

  static VaultController create() {
    final store = SecureKeyStore();
    final db = VaultDatabase.open();
    return VaultController(
      vault: VaultService(keyManager: KeyManager(store), db: db),
      db: db,
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
    phase = AppPhase.unlocked;
    await refreshCredentials();
    notifyListeners();
  }

  Future<bool> unlock({required String masterPassphrase}) async {
    try {
      await vault.unlock(masterPassphrase: masterPassphrase);
      phase = AppPhase.unlocked;
      await refreshCredentials();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void lock() {
    vault.lock();
    credentials = const [];
    phase = AppPhase.locked;
    notifyListeners();
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
