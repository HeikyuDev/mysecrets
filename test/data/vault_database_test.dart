import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/data/vault_database.dart';

void main() {
  late VaultDatabase db;

  setUp(() {
    db = VaultDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('VaultDatabase ciphertext-only persistence', () {
    test('insert and read back a credential row', () async {
      final ciphertext =
          Uint8List.fromList(utf8.encode('fake-encrypted-json-blob'));
      await db.into(db.credentials).insert(CredentialsCompanion.insert(
            id: 'cred-1',
            createdAtUtcMs: 1700000000000,
            updatedAtUtcMs: 1700000000001,
            lastChangedUtcMs: 1700000000000,
            dataCiphertext: ciphertext,
          ));

      final row =
          await (db.select(db.credentials)
                ..where((t) => t.id.equals('cred-1')))
              .getSingle();
      expect(row.dataCiphertext, equals(ciphertext));
    });

    test('row columns contain no plaintext fields', () async {
      final row = CredentialsCompanion.insert(
        id: 'cred-2',
        createdAtUtcMs: 1,
        updatedAtUtcMs: 2,
        lastChangedUtcMs: 1,
        dataCiphertext: Uint8List.fromList([1, 2, 3]),
      );
      await db.into(db.credentials).insert(row);
      final cols = await db.customSelect(
        'SELECT * FROM credentials WHERE id = ?',
        variables: [Variable.withString('cred-2')],
      ).getSingle();
      final colsLower = cols.data.keys.map((k) => k.toLowerCase()).toList();
      for (final forbidden in ['platform', 'username', 'password', 'notes']) {
        expect(colsLower.any((c) => c.contains(forbidden)), isFalse,
            reason: 'found plaintext column name: $forbidden');
      }
    });

    test('vault meta roundtrip', () async {
      await db.into(db.vaultMeta).insert(VaultMetaCompanion.insert(
            key: 'pinned_cred_id',
            valueCiphertext: Uint8List.fromList([9, 9, 9]),
          ));
      final row = await (db.select(db.vaultMeta)
            ..where((t) => t.key.equals('pinned_cred_id')))
          .getSingle();
      expect(row.valueCiphertext, equals(Uint8List.fromList([9, 9, 9])));
    });

    test('rotation policy can be null and set', () async {
      await db.into(db.credentials).insert(CredentialsCompanion.insert(
            id: 'c3',
            createdAtUtcMs: 0,
            updatedAtUtcMs: 0,
            lastChangedUtcMs: 0,
            dataCiphertext: Uint8List(0),
          ));
      var row = await (db.select(db.credentials)
            ..where((t) => t.id.equals('c3')))
          .getSingle();
      expect(row.rotationPolicyDays, null);

      await (db.update(db.credentials)
            ..where((t) => t.id.equals('c3')))
          .write(const CredentialsCompanion(
              rotationPolicyDays: Value(90)));
      row = await (db.select(db.credentials)
            ..where((t) => t.id.equals('c3')))
          .getSingle();
      expect(row.rotationPolicyDays, 90);
    });
  });
}
