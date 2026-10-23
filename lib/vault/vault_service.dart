import 'package:drift/drift.dart' hide isNull, isNotNull;

import '../data/vault_database.dart' hide Credential;
import 'credential.dart';
import 'credential_codec.dart';
import 'crypto/vault_random.dart';
import 'keys/key_manager.dart';

enum VaultState { lockedByMissingSetup, locked, unlocked }

class VaultSetupRequiredException implements Exception {
  @override
  String toString() =>
      'VaultSetupRequiredException: vault has no master key yet';
}

class VaultLockedException implements Exception {
  @override
  String toString() => 'VaultLockedException: vault is locked';
}

class VaultService {
  final KeyManager _keyManager;
  final VaultDatabase _db;

  VaultState _state = VaultState.lockedByMissingSetup;
  Uint8List? _dek;

  VaultService({required this._keyManager, required this._db});

  /// Opens the service, resolving whether a master key already exists.
  static Future<VaultService> open({
    required KeyManager keyManager,
    required VaultDatabase db,
  }) async {
    final service = VaultService(keyManager: keyManager, db: db);
    if (await keyManager.isInitialized()) {
      service._state = VaultState.locked;
    }
    return service;
  }

  VaultState get state => _state;

  bool get isInitialized => _state != VaultState.lockedByMissingSetup;

  Future<bool> isBackendInitialized() => _keyManager.isInitialized();

  Future<void> setup({required String masterPassphrase}) async {
    if (_state == VaultState.unlocked || _state == VaultState.locked) {
      throw ArgumentError('vault already set up in this session');
    }
    final dek =
        await _keyManager.createVault(masterPassphrase: masterPassphrase);
    _dek = dek;
    _state = VaultState.unlocked;
  }

  Future<void> unlock({required String masterPassphrase}) async {
    _dek = await _keyManager.unlock(masterPassphrase: masterPassphrase);
    _state = VaultState.unlocked;
  }

  /// Fast-path unlock using the DEK provided by the access gate (biometric
  /// or PIN verified against OS-protected storage).
  void unlockWithDek(Uint8List dek) {
    _dek = Uint8List.fromList(dek);
    _state = VaultState.unlocked;
  }

  /// Exposes the DEK for quick-unlock enrollment. Only callable unlocked.
  Uint8List exposeDek() => _requireDek;

  void lock() {
    _dek = null;
    _state = VaultState.locked;
  }

  Uint8List get _requireDek {
    if (_state == VaultState.lockedByMissingSetup) {
      throw VaultSetupRequiredException();
    }
    if (_state != VaultState.unlocked || _dek == null) {
      throw VaultLockedException();
    }
    return _dek!;
  }

  Future<Credential> addCredential({
    required String platform,
    required String username,
    required String password,
    String? notes,
    int? rotationPolicyDays,
  }) async {
    final dek = _requireDek;
    final now = DateTime.now().toUtc();
    final id = _newId();
    final credential = Credential(
      id: id,
      platform: platform,
      username: username,
      password: password,
      notes: notes,
      rotationPolicyDays: rotationPolicyDays,
      createdAtUtc: now,
      updatedAtUtc: now,
      lastChangedUtc: now,
    );
    await _db.into(_db.credentials).insert(
          CredentialsCompanion.insert(
            id: id,
            createdAtUtcMs: now.millisecondsSinceEpoch,
            updatedAtUtcMs: now.millisecondsSinceEpoch,
            lastChangedUtcMs: now.millisecondsSinceEpoch,
            rotationPolicyDays: Value(rotationPolicyDays),
            dataCiphertext:
                CredentialCodec.encode(dek: dek, credential: credential),
          ),
        );
    return credential;
  }

  Future<List<Credential>> listCredentials() async {
    final dek = _requireDek;
    final rows = await _db.select(_db.credentials).get();
    return rows
        .map((r) =>
            CredentialCodec.decode(dek: dek, ciphertext: r.dataCiphertext))
        .toList();
  }

  Future<Credential?> getCredential(String id) async {
    final dek = _requireDek;
    final row = await (_db.select(_db.credentials)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return CredentialCodec.decode(dek: dek, ciphertext: row.dataCiphertext);
  }

  /// Persists [updated]; id is authoritative from storage lookup.
  /// updatedAt is always stamped to now. lastChanged only moves when
  /// [markChanged] is true (user rotated password on the external site).
  Future<void> updateCredential(Credential updated,
      {bool markChanged = false}) async {
    final dek = _requireDek;
    final now = DateTime.now().toUtc();
    final stamped = Credential(
      id: updated.id,
      platform: updated.platform,
      username: updated.username,
      password: updated.password,
      notes: updated.notes,
      createdAtUtc: updated.createdAtUtc,
      updatedAtUtc: now,
      lastChangedUtc: markChanged ? now : updated.lastChangedUtc,
    );
    await (_db.update(_db.credentials)
          ..where((t) => t.id.equals(stamped.id)))
        .write(CredentialsCompanion(
      updatedAtUtcMs: Value(stamped.updatedAtUtc.millisecondsSinceEpoch),
      lastChangedUtcMs:
          Value(stamped.lastChangedUtc.millisecondsSinceEpoch),
      dataCiphertext:
          Value(CredentialCodec.encode(dek: dek, credential: stamped)),
    ));
  }

  /// Stamps lastChangedUtc to now — used when the user marks a password
  /// as rotated after changing it on the external platform.
  Future<void> markChanged(String credentialId) async {
    final current = await getCredential(credentialId);
    if (current == null) {
      throw ArgumentError.value(credentialId, 'credentialId', 'not found');
    }
    await updateCredential(current, markChanged: true);
  }

  Future<void> deleteCredential(String credentialId) async {
    _requireDek;
    await (_db.delete(_db.credentials)..where((t) => t.id.equals(credentialId)))
        .go();
  }

  String _newId() =>
      VaultRandom.nextBytes(16).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
