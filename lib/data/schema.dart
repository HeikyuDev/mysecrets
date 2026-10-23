import 'package:drift/drift.dart';

class Credentials extends Table {
  TextColumn get id => text()();
  IntColumn get createdAtUtcMs => integer()();
  IntColumn get updatedAtUtcMs => integer()();
  IntColumn get lastChangedUtcMs => integer()();
  IntColumn get rotationPolicyDays => integer().nullable()();
  BlobColumn get dataCiphertext => blob()();
}

class VaultMeta extends Table {
  TextColumn get key => text()();
  BlobColumn get valueCiphertext => blob()();
}
