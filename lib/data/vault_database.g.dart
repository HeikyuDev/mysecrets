// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_database.dart';

// ignore_for_file: type=lint
class $CredentialsTable extends Credentials
    with TableInfo<$CredentialsTable, Credential> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CredentialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMsMeta = const VerificationMeta(
    'createdAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcMs = GeneratedColumn<int>(
    'created_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMsMeta = const VerificationMeta(
    'updatedAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtcMs = GeneratedColumn<int>(
    'updated_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastChangedUtcMsMeta = const VerificationMeta(
    'lastChangedUtcMs',
  );
  @override
  late final GeneratedColumn<int> lastChangedUtcMs = GeneratedColumn<int>(
    'last_changed_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rotationPolicyDaysMeta =
      const VerificationMeta('rotationPolicyDays');
  @override
  late final GeneratedColumn<int> rotationPolicyDays = GeneratedColumn<int>(
    'rotation_policy_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataCiphertextMeta = const VerificationMeta(
    'dataCiphertext',
  );
  @override
  late final GeneratedColumn<Uint8List> dataCiphertext =
      GeneratedColumn<Uint8List>(
        'data_ciphertext',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAtUtcMs,
    updatedAtUtcMs,
    lastChangedUtcMs,
    rotationPolicyDays,
    dataCiphertext,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credentials';
  @override
  VerificationContext validateIntegrity(
    Insertable<Credential> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at_utc_ms')) {
      context.handle(
        _createdAtUtcMsMeta,
        createdAtUtcMs.isAcceptableOrUnknown(
          data['created_at_utc_ms']!,
          _createdAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMsMeta);
    }
    if (data.containsKey('updated_at_utc_ms')) {
      context.handle(
        _updatedAtUtcMsMeta,
        updatedAtUtcMs.isAcceptableOrUnknown(
          data['updated_at_utc_ms']!,
          _updatedAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMsMeta);
    }
    if (data.containsKey('last_changed_utc_ms')) {
      context.handle(
        _lastChangedUtcMsMeta,
        lastChangedUtcMs.isAcceptableOrUnknown(
          data['last_changed_utc_ms']!,
          _lastChangedUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastChangedUtcMsMeta);
    }
    if (data.containsKey('rotation_policy_days')) {
      context.handle(
        _rotationPolicyDaysMeta,
        rotationPolicyDays.isAcceptableOrUnknown(
          data['rotation_policy_days']!,
          _rotationPolicyDaysMeta,
        ),
      );
    }
    if (data.containsKey('data_ciphertext')) {
      context.handle(
        _dataCiphertextMeta,
        dataCiphertext.isAcceptableOrUnknown(
          data['data_ciphertext']!,
          _dataCiphertextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataCiphertextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Credential map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Credential(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_ms'],
      )!,
      updatedAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_ms'],
      )!,
      lastChangedUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_changed_utc_ms'],
      )!,
      rotationPolicyDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rotation_policy_days'],
      ),
      dataCiphertext: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}data_ciphertext'],
      )!,
    );
  }

  @override
  $CredentialsTable createAlias(String alias) {
    return $CredentialsTable(attachedDatabase, alias);
  }
}

class Credential extends DataClass implements Insertable<Credential> {
  final String id;
  final int createdAtUtcMs;
  final int updatedAtUtcMs;
  final int lastChangedUtcMs;
  final int? rotationPolicyDays;
  final Uint8List dataCiphertext;
  const Credential({
    required this.id,
    required this.createdAtUtcMs,
    required this.updatedAtUtcMs,
    required this.lastChangedUtcMs,
    this.rotationPolicyDays,
    required this.dataCiphertext,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs);
    map['updated_at_utc_ms'] = Variable<int>(updatedAtUtcMs);
    map['last_changed_utc_ms'] = Variable<int>(lastChangedUtcMs);
    if (!nullToAbsent || rotationPolicyDays != null) {
      map['rotation_policy_days'] = Variable<int>(rotationPolicyDays);
    }
    map['data_ciphertext'] = Variable<Uint8List>(dataCiphertext);
    return map;
  }

  CredentialsCompanion toCompanion(bool nullToAbsent) {
    return CredentialsCompanion(
      id: Value(id),
      createdAtUtcMs: Value(createdAtUtcMs),
      updatedAtUtcMs: Value(updatedAtUtcMs),
      lastChangedUtcMs: Value(lastChangedUtcMs),
      rotationPolicyDays: rotationPolicyDays == null && nullToAbsent
          ? const Value.absent()
          : Value(rotationPolicyDays),
      dataCiphertext: Value(dataCiphertext),
    );
  }

  factory Credential.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Credential(
      id: serializer.fromJson<String>(json['id']),
      createdAtUtcMs: serializer.fromJson<int>(json['createdAtUtcMs']),
      updatedAtUtcMs: serializer.fromJson<int>(json['updatedAtUtcMs']),
      lastChangedUtcMs: serializer.fromJson<int>(json['lastChangedUtcMs']),
      rotationPolicyDays: serializer.fromJson<int?>(json['rotationPolicyDays']),
      dataCiphertext: serializer.fromJson<Uint8List>(json['dataCiphertext']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAtUtcMs': serializer.toJson<int>(createdAtUtcMs),
      'updatedAtUtcMs': serializer.toJson<int>(updatedAtUtcMs),
      'lastChangedUtcMs': serializer.toJson<int>(lastChangedUtcMs),
      'rotationPolicyDays': serializer.toJson<int?>(rotationPolicyDays),
      'dataCiphertext': serializer.toJson<Uint8List>(dataCiphertext),
    };
  }

  Credential copyWith({
    String? id,
    int? createdAtUtcMs,
    int? updatedAtUtcMs,
    int? lastChangedUtcMs,
    Value<int?> rotationPolicyDays = const Value.absent(),
    Uint8List? dataCiphertext,
  }) => Credential(
    id: id ?? this.id,
    createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
    updatedAtUtcMs: updatedAtUtcMs ?? this.updatedAtUtcMs,
    lastChangedUtcMs: lastChangedUtcMs ?? this.lastChangedUtcMs,
    rotationPolicyDays: rotationPolicyDays.present
        ? rotationPolicyDays.value
        : this.rotationPolicyDays,
    dataCiphertext: dataCiphertext ?? this.dataCiphertext,
  );
  Credential copyWithCompanion(CredentialsCompanion data) {
    return Credential(
      id: data.id.present ? data.id.value : this.id,
      createdAtUtcMs: data.createdAtUtcMs.present
          ? data.createdAtUtcMs.value
          : this.createdAtUtcMs,
      updatedAtUtcMs: data.updatedAtUtcMs.present
          ? data.updatedAtUtcMs.value
          : this.updatedAtUtcMs,
      lastChangedUtcMs: data.lastChangedUtcMs.present
          ? data.lastChangedUtcMs.value
          : this.lastChangedUtcMs,
      rotationPolicyDays: data.rotationPolicyDays.present
          ? data.rotationPolicyDays.value
          : this.rotationPolicyDays,
      dataCiphertext: data.dataCiphertext.present
          ? data.dataCiphertext.value
          : this.dataCiphertext,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Credential(')
          ..write('id: $id, ')
          ..write('createdAtUtcMs: $createdAtUtcMs, ')
          ..write('updatedAtUtcMs: $updatedAtUtcMs, ')
          ..write('lastChangedUtcMs: $lastChangedUtcMs, ')
          ..write('rotationPolicyDays: $rotationPolicyDays, ')
          ..write('dataCiphertext: $dataCiphertext')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAtUtcMs,
    updatedAtUtcMs,
    lastChangedUtcMs,
    rotationPolicyDays,
    $driftBlobEquality.hash(dataCiphertext),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Credential &&
          other.id == this.id &&
          other.createdAtUtcMs == this.createdAtUtcMs &&
          other.updatedAtUtcMs == this.updatedAtUtcMs &&
          other.lastChangedUtcMs == this.lastChangedUtcMs &&
          other.rotationPolicyDays == this.rotationPolicyDays &&
          $driftBlobEquality.equals(other.dataCiphertext, this.dataCiphertext));
}

class CredentialsCompanion extends UpdateCompanion<Credential> {
  final Value<String> id;
  final Value<int> createdAtUtcMs;
  final Value<int> updatedAtUtcMs;
  final Value<int> lastChangedUtcMs;
  final Value<int?> rotationPolicyDays;
  final Value<Uint8List> dataCiphertext;
  final Value<int> rowid;
  const CredentialsCompanion({
    this.id = const Value.absent(),
    this.createdAtUtcMs = const Value.absent(),
    this.updatedAtUtcMs = const Value.absent(),
    this.lastChangedUtcMs = const Value.absent(),
    this.rotationPolicyDays = const Value.absent(),
    this.dataCiphertext = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CredentialsCompanion.insert({
    required String id,
    required int createdAtUtcMs,
    required int updatedAtUtcMs,
    required int lastChangedUtcMs,
    this.rotationPolicyDays = const Value.absent(),
    required Uint8List dataCiphertext,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAtUtcMs = Value(createdAtUtcMs),
       updatedAtUtcMs = Value(updatedAtUtcMs),
       lastChangedUtcMs = Value(lastChangedUtcMs),
       dataCiphertext = Value(dataCiphertext);
  static Insertable<Credential> custom({
    Expression<String>? id,
    Expression<int>? createdAtUtcMs,
    Expression<int>? updatedAtUtcMs,
    Expression<int>? lastChangedUtcMs,
    Expression<int>? rotationPolicyDays,
    Expression<Uint8List>? dataCiphertext,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAtUtcMs != null) 'created_at_utc_ms': createdAtUtcMs,
      if (updatedAtUtcMs != null) 'updated_at_utc_ms': updatedAtUtcMs,
      if (lastChangedUtcMs != null) 'last_changed_utc_ms': lastChangedUtcMs,
      if (rotationPolicyDays != null)
        'rotation_policy_days': rotationPolicyDays,
      if (dataCiphertext != null) 'data_ciphertext': dataCiphertext,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CredentialsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAtUtcMs,
    Value<int>? updatedAtUtcMs,
    Value<int>? lastChangedUtcMs,
    Value<int?>? rotationPolicyDays,
    Value<Uint8List>? dataCiphertext,
    Value<int>? rowid,
  }) {
    return CredentialsCompanion(
      id: id ?? this.id,
      createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
      updatedAtUtcMs: updatedAtUtcMs ?? this.updatedAtUtcMs,
      lastChangedUtcMs: lastChangedUtcMs ?? this.lastChangedUtcMs,
      rotationPolicyDays: rotationPolicyDays ?? this.rotationPolicyDays,
      dataCiphertext: dataCiphertext ?? this.dataCiphertext,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAtUtcMs.present) {
      map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs.value);
    }
    if (updatedAtUtcMs.present) {
      map['updated_at_utc_ms'] = Variable<int>(updatedAtUtcMs.value);
    }
    if (lastChangedUtcMs.present) {
      map['last_changed_utc_ms'] = Variable<int>(lastChangedUtcMs.value);
    }
    if (rotationPolicyDays.present) {
      map['rotation_policy_days'] = Variable<int>(rotationPolicyDays.value);
    }
    if (dataCiphertext.present) {
      map['data_ciphertext'] = Variable<Uint8List>(dataCiphertext.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CredentialsCompanion(')
          ..write('id: $id, ')
          ..write('createdAtUtcMs: $createdAtUtcMs, ')
          ..write('updatedAtUtcMs: $updatedAtUtcMs, ')
          ..write('lastChangedUtcMs: $lastChangedUtcMs, ')
          ..write('rotationPolicyDays: $rotationPolicyDays, ')
          ..write('dataCiphertext: $dataCiphertext, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VaultMetaTable extends VaultMeta
    with TableInfo<$VaultMetaTable, VaultMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaultMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueCiphertextMeta = const VerificationMeta(
    'valueCiphertext',
  );
  @override
  late final GeneratedColumn<Uint8List> valueCiphertext =
      GeneratedColumn<Uint8List>(
        'value_ciphertext',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [key, valueCiphertext];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vault_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<VaultMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_ciphertext')) {
      context.handle(
        _valueCiphertextMeta,
        valueCiphertext.isAcceptableOrUnknown(
          data['value_ciphertext']!,
          _valueCiphertextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valueCiphertextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  VaultMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaultMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueCiphertext: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}value_ciphertext'],
      )!,
    );
  }

  @override
  $VaultMetaTable createAlias(String alias) {
    return $VaultMetaTable(attachedDatabase, alias);
  }
}

class VaultMetaData extends DataClass implements Insertable<VaultMetaData> {
  final String key;
  final Uint8List valueCiphertext;
  const VaultMetaData({required this.key, required this.valueCiphertext});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value_ciphertext'] = Variable<Uint8List>(valueCiphertext);
    return map;
  }

  VaultMetaCompanion toCompanion(bool nullToAbsent) {
    return VaultMetaCompanion(
      key: Value(key),
      valueCiphertext: Value(valueCiphertext),
    );
  }

  factory VaultMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaultMetaData(
      key: serializer.fromJson<String>(json['key']),
      valueCiphertext: serializer.fromJson<Uint8List>(json['valueCiphertext']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'valueCiphertext': serializer.toJson<Uint8List>(valueCiphertext),
    };
  }

  VaultMetaData copyWith({String? key, Uint8List? valueCiphertext}) =>
      VaultMetaData(
        key: key ?? this.key,
        valueCiphertext: valueCiphertext ?? this.valueCiphertext,
      );
  VaultMetaData copyWithCompanion(VaultMetaCompanion data) {
    return VaultMetaData(
      key: data.key.present ? data.key.value : this.key,
      valueCiphertext: data.valueCiphertext.present
          ? data.valueCiphertext.value
          : this.valueCiphertext,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaultMetaData(')
          ..write('key: $key, ')
          ..write('valueCiphertext: $valueCiphertext')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(key, $driftBlobEquality.hash(valueCiphertext));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaultMetaData &&
          other.key == this.key &&
          $driftBlobEquality.equals(
            other.valueCiphertext,
            this.valueCiphertext,
          ));
}

class VaultMetaCompanion extends UpdateCompanion<VaultMetaData> {
  final Value<String> key;
  final Value<Uint8List> valueCiphertext;
  final Value<int> rowid;
  const VaultMetaCompanion({
    this.key = const Value.absent(),
    this.valueCiphertext = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaultMetaCompanion.insert({
    required String key,
    required Uint8List valueCiphertext,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       valueCiphertext = Value(valueCiphertext);
  static Insertable<VaultMetaData> custom({
    Expression<String>? key,
    Expression<Uint8List>? valueCiphertext,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (valueCiphertext != null) 'value_ciphertext': valueCiphertext,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaultMetaCompanion copyWith({
    Value<String>? key,
    Value<Uint8List>? valueCiphertext,
    Value<int>? rowid,
  }) {
    return VaultMetaCompanion(
      key: key ?? this.key,
      valueCiphertext: valueCiphertext ?? this.valueCiphertext,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueCiphertext.present) {
      map['value_ciphertext'] = Variable<Uint8List>(valueCiphertext.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaultMetaCompanion(')
          ..write('key: $key, ')
          ..write('valueCiphertext: $valueCiphertext, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$VaultDatabase extends GeneratedDatabase {
  _$VaultDatabase(QueryExecutor e) : super(e);
  $VaultDatabaseManager get managers => $VaultDatabaseManager(this);
  late final $CredentialsTable credentials = $CredentialsTable(this);
  late final $VaultMetaTable vaultMeta = $VaultMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [credentials, vaultMeta];
}

typedef $$CredentialsTableCreateCompanionBuilder =
    CredentialsCompanion Function({
      required String id,
      required int createdAtUtcMs,
      required int updatedAtUtcMs,
      required int lastChangedUtcMs,
      Value<int?> rotationPolicyDays,
      required Uint8List dataCiphertext,
      Value<int> rowid,
    });
typedef $$CredentialsTableUpdateCompanionBuilder =
    CredentialsCompanion Function({
      Value<String> id,
      Value<int> createdAtUtcMs,
      Value<int> updatedAtUtcMs,
      Value<int> lastChangedUtcMs,
      Value<int?> rotationPolicyDays,
      Value<Uint8List> dataCiphertext,
      Value<int> rowid,
    });

class $$CredentialsTableFilterComposer
    extends Composer<_$VaultDatabase, $CredentialsTable> {
  $$CredentialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMs => $composableBuilder(
    column: $table.updatedAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastChangedUtcMs => $composableBuilder(
    column: $table.lastChangedUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rotationPolicyDays => $composableBuilder(
    column: $table.rotationPolicyDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get dataCiphertext => $composableBuilder(
    column: $table.dataCiphertext,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CredentialsTableOrderingComposer
    extends Composer<_$VaultDatabase, $CredentialsTable> {
  $$CredentialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMs => $composableBuilder(
    column: $table.updatedAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastChangedUtcMs => $composableBuilder(
    column: $table.lastChangedUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rotationPolicyDays => $composableBuilder(
    column: $table.rotationPolicyDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get dataCiphertext => $composableBuilder(
    column: $table.dataCiphertext,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CredentialsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $CredentialsTable> {
  $$CredentialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcMs => $composableBuilder(
    column: $table.updatedAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastChangedUtcMs => $composableBuilder(
    column: $table.lastChangedUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rotationPolicyDays => $composableBuilder(
    column: $table.rotationPolicyDays,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get dataCiphertext => $composableBuilder(
    column: $table.dataCiphertext,
    builder: (column) => column,
  );
}

class $$CredentialsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $CredentialsTable,
          Credential,
          $$CredentialsTableFilterComposer,
          $$CredentialsTableOrderingComposer,
          $$CredentialsTableAnnotationComposer,
          $$CredentialsTableCreateCompanionBuilder,
          $$CredentialsTableUpdateCompanionBuilder,
          (
            Credential,
            BaseReferences<_$VaultDatabase, $CredentialsTable, Credential>,
          ),
          Credential,
          PrefetchHooks Function()
        > {
  $$CredentialsTableTableManager(_$VaultDatabase db, $CredentialsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CredentialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CredentialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CredentialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAtUtcMs = const Value.absent(),
                Value<int> updatedAtUtcMs = const Value.absent(),
                Value<int> lastChangedUtcMs = const Value.absent(),
                Value<int?> rotationPolicyDays = const Value.absent(),
                Value<Uint8List> dataCiphertext = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CredentialsCompanion(
                id: id,
                createdAtUtcMs: createdAtUtcMs,
                updatedAtUtcMs: updatedAtUtcMs,
                lastChangedUtcMs: lastChangedUtcMs,
                rotationPolicyDays: rotationPolicyDays,
                dataCiphertext: dataCiphertext,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAtUtcMs,
                required int updatedAtUtcMs,
                required int lastChangedUtcMs,
                Value<int?> rotationPolicyDays = const Value.absent(),
                required Uint8List dataCiphertext,
                Value<int> rowid = const Value.absent(),
              }) => CredentialsCompanion.insert(
                id: id,
                createdAtUtcMs: createdAtUtcMs,
                updatedAtUtcMs: updatedAtUtcMs,
                lastChangedUtcMs: lastChangedUtcMs,
                rotationPolicyDays: rotationPolicyDays,
                dataCiphertext: dataCiphertext,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CredentialsTable, Credential>(table),
                  BaseReferences<
                    _$VaultDatabase,
                    $CredentialsTable,
                    Credential
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CredentialsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $CredentialsTable,
      Credential,
      $$CredentialsTableFilterComposer,
      $$CredentialsTableOrderingComposer,
      $$CredentialsTableAnnotationComposer,
      $$CredentialsTableCreateCompanionBuilder,
      $$CredentialsTableUpdateCompanionBuilder,
      (
        Credential,
        BaseReferences<_$VaultDatabase, $CredentialsTable, Credential>,
      ),
      Credential,
      PrefetchHooks Function()
    >;
typedef $$VaultMetaTableCreateCompanionBuilder = VaultMetaCompanion Function({
  required String key,
  required Uint8List valueCiphertext,
  Value<int> rowid,
});
typedef $$VaultMetaTableUpdateCompanionBuilder = VaultMetaCompanion Function({
  Value<String> key,
  Value<Uint8List> valueCiphertext,
  Value<int> rowid,
});

class $$VaultMetaTableFilterComposer
    extends Composer<_$VaultDatabase, $VaultMetaTable> {
  $$VaultMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get valueCiphertext => $composableBuilder(
    column: $table.valueCiphertext,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VaultMetaTableOrderingComposer
    extends Composer<_$VaultDatabase, $VaultMetaTable> {
  $$VaultMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get valueCiphertext => $composableBuilder(
    column: $table.valueCiphertext,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VaultMetaTableAnnotationComposer
    extends Composer<_$VaultDatabase, $VaultMetaTable> {
  $$VaultMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<Uint8List> get valueCiphertext => $composableBuilder(
    column: $table.valueCiphertext,
    builder: (column) => column,
  );
}

class $$VaultMetaTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $VaultMetaTable,
          VaultMetaData,
          $$VaultMetaTableFilterComposer,
          $$VaultMetaTableOrderingComposer,
          $$VaultMetaTableAnnotationComposer,
          $$VaultMetaTableCreateCompanionBuilder,
          $$VaultMetaTableUpdateCompanionBuilder,
          (
            VaultMetaData,
            BaseReferences<_$VaultDatabase, $VaultMetaTable, VaultMetaData>,
          ),
          VaultMetaData,
          PrefetchHooks Function()
        > {
  $$VaultMetaTableTableManager(_$VaultDatabase db, $VaultMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaultMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaultMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaultMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<Uint8List> valueCiphertext = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultMetaCompanion(
                key: key,
                valueCiphertext: valueCiphertext,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required Uint8List valueCiphertext,
                Value<int> rowid = const Value.absent(),
              }) => VaultMetaCompanion.insert(
                key: key,
                valueCiphertext: valueCiphertext,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VaultMetaTable, VaultMetaData>(table),
                  BaseReferences<
                    _$VaultDatabase,
                    $VaultMetaTable,
                    VaultMetaData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VaultMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $VaultMetaTable,
      VaultMetaData,
      $$VaultMetaTableFilterComposer,
      $$VaultMetaTableOrderingComposer,
      $$VaultMetaTableAnnotationComposer,
      $$VaultMetaTableCreateCompanionBuilder,
      $$VaultMetaTableUpdateCompanionBuilder,
      (
        VaultMetaData,
        BaseReferences<_$VaultDatabase, $VaultMetaTable, VaultMetaData>,
      ),
      VaultMetaData,
      PrefetchHooks Function()
    >;

class $VaultDatabaseManager {
  final _$VaultDatabase _db;
  $VaultDatabaseManager(this._db);
  $$CredentialsTableTableManager get credentials =>
      $$CredentialsTableTableManager(_db, _db.credentials);
  $$VaultMetaTableTableManager get vaultMeta =>
      $$VaultMetaTableTableManager(_db, _db.vaultMeta);
}
