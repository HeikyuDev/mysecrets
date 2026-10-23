import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'schema.dart';

part 'vault_database.g.dart';

@DriftDatabase(tables: [Credentials, VaultMeta])
class VaultDatabase extends _$VaultDatabase {
  VaultDatabase(super.e);

  VaultDatabase.open() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'mysecrets');
  }
}
