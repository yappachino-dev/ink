// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $KeySlotsTable extends KeySlots
    with TableInfo<$KeySlotsTable, KeySlotModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeySlotsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<KeyType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<KeyType>($KeySlotsTable.$convertertype);
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<Uint8List> salt = GeneratedColumn<Uint8List>(
    'salt',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wrappedMasterKeyMeta = const VerificationMeta(
    'wrappedMasterKey',
  );
  @override
  late final GeneratedColumn<Uint8List> wrappedMasterKey =
      GeneratedColumn<Uint8List>(
        'wrapped_master_key',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(1),
      ).withConverter<SyncStatus>($KeySlotsTable.$convertersyncStatus);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    type,
    salt,
    wrappedMasterKey,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_slots';
  @override
  VerificationContext validateIntegrity(
    Insertable<KeySlotModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('salt')) {
      context.handle(
        _saltMeta,
        salt.isAcceptableOrUnknown(data['salt']!, _saltMeta),
      );
    } else if (isInserting) {
      context.missing(_saltMeta);
    }
    if (data.containsKey('wrapped_master_key')) {
      context.handle(
        _wrappedMasterKeyMeta,
        wrappedMasterKey.isAcceptableOrUnknown(
          data['wrapped_master_key']!,
          _wrappedMasterKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wrappedMasterKeyMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {type};
  @override
  KeySlotModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeySlotModel(
      type: $KeySlotsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      salt: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}salt'],
      )!,
      wrappedMasterKey: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}wrapped_master_key'],
      )!,
      syncStatus: $KeySlotsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $KeySlotsTable createAlias(String alias) {
    return $KeySlotsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<KeyType, int, int> $convertertype =
      const EnumIndexConverter<KeyType>(KeyType.values);
  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class KeySlotModel extends DataClass implements Insertable<KeySlotModel> {
  final KeyType type;
  final Uint8List salt;
  final Uint8List wrappedMasterKey;
  final SyncStatus syncStatus;
  final DateTime updatedAt;
  const KeySlotModel({
    required this.type,
    required this.salt,
    required this.wrappedMasterKey,
    required this.syncStatus,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['type'] = Variable<int>($KeySlotsTable.$convertertype.toSql(type));
    }
    map['salt'] = Variable<Uint8List>(salt);
    map['wrapped_master_key'] = Variable<Uint8List>(wrappedMasterKey);
    {
      map['sync_status'] = Variable<int>(
        $KeySlotsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  KeySlotsCompanion toCompanion(bool nullToAbsent) {
    return KeySlotsCompanion(
      type: Value(type),
      salt: Value(salt),
      wrappedMasterKey: Value(wrappedMasterKey),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory KeySlotModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeySlotModel(
      type: $KeySlotsTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      salt: serializer.fromJson<Uint8List>(json['salt']),
      wrappedMasterKey: serializer.fromJson<Uint8List>(
        json['wrappedMasterKey'],
      ),
      syncStatus: $KeySlotsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'type': serializer.toJson<int>(
        $KeySlotsTable.$convertertype.toJson(type),
      ),
      'salt': serializer.toJson<Uint8List>(salt),
      'wrappedMasterKey': serializer.toJson<Uint8List>(wrappedMasterKey),
      'syncStatus': serializer.toJson<int>(
        $KeySlotsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  KeySlotModel copyWith({
    KeyType? type,
    Uint8List? salt,
    Uint8List? wrappedMasterKey,
    SyncStatus? syncStatus,
    DateTime? updatedAt,
  }) => KeySlotModel(
    type: type ?? this.type,
    salt: salt ?? this.salt,
    wrappedMasterKey: wrappedMasterKey ?? this.wrappedMasterKey,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  KeySlotModel copyWithCompanion(KeySlotsCompanion data) {
    return KeySlotModel(
      type: data.type.present ? data.type.value : this.type,
      salt: data.salt.present ? data.salt.value : this.salt,
      wrappedMasterKey: data.wrappedMasterKey.present
          ? data.wrappedMasterKey.value
          : this.wrappedMasterKey,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeySlotModel(')
          ..write('type: $type, ')
          ..write('salt: $salt, ')
          ..write('wrappedMasterKey: $wrappedMasterKey, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    type,
    $driftBlobEquality.hash(salt),
    $driftBlobEquality.hash(wrappedMasterKey),
    syncStatus,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeySlotModel &&
          other.type == this.type &&
          $driftBlobEquality.equals(other.salt, this.salt) &&
          $driftBlobEquality.equals(
            other.wrappedMasterKey,
            this.wrappedMasterKey,
          ) &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class KeySlotsCompanion extends UpdateCompanion<KeySlotModel> {
  final Value<KeyType> type;
  final Value<Uint8List> salt;
  final Value<Uint8List> wrappedMasterKey;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> updatedAt;
  const KeySlotsCompanion({
    this.type = const Value.absent(),
    this.salt = const Value.absent(),
    this.wrappedMasterKey = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  KeySlotsCompanion.insert({
    this.type = const Value.absent(),
    required Uint8List salt,
    required Uint8List wrappedMasterKey,
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : salt = Value(salt),
       wrappedMasterKey = Value(wrappedMasterKey);
  static Insertable<KeySlotModel> custom({
    Expression<int>? type,
    Expression<Uint8List>? salt,
    Expression<Uint8List>? wrappedMasterKey,
    Expression<int>? syncStatus,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (type != null) 'type': type,
      if (salt != null) 'salt': salt,
      if (wrappedMasterKey != null) 'wrapped_master_key': wrappedMasterKey,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  KeySlotsCompanion copyWith({
    Value<KeyType>? type,
    Value<Uint8List>? salt,
    Value<Uint8List>? wrappedMasterKey,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? updatedAt,
  }) {
    return KeySlotsCompanion(
      type: type ?? this.type,
      salt: salt ?? this.salt,
      wrappedMasterKey: wrappedMasterKey ?? this.wrappedMasterKey,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (type.present) {
      map['type'] = Variable<int>(
        $KeySlotsTable.$convertertype.toSql(type.value),
      );
    }
    if (salt.present) {
      map['salt'] = Variable<Uint8List>(salt.value);
    }
    if (wrappedMasterKey.present) {
      map['wrapped_master_key'] = Variable<Uint8List>(wrappedMasterKey.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $KeySlotsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeySlotsCompanion(')
          ..write('type: $type, ')
          ..write('salt: $salt, ')
          ..write('wrappedMasterKey: $wrappedMasterKey, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects
    with TableInfo<$ProjectsTable, ProjectModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: const UuidV7().generate,
  );
  static const VerificationMeta _encryptedContentMeta = const VerificationMeta(
    'encryptedContent',
  );
  @override
  late final GeneratedColumn<Uint8List> encryptedContent =
      GeneratedColumn<Uint8List>(
        'encrypted_content',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastSyncedVersionMeta = const VerificationMeta(
    'lastSyncedVersion',
  );
  @override
  late final GeneratedColumn<int> lastSyncedVersion = GeneratedColumn<int>(
    'last_synced_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(1),
      ).withConverter<SyncStatus>($ProjectsTable.$convertersyncStatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    encryptedContent,
    localVersion,
    lastSyncedVersion,
    syncStatus,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('encrypted_content')) {
      context.handle(
        _encryptedContentMeta,
        encryptedContent.isAcceptableOrUnknown(
          data['encrypted_content']!,
          _encryptedContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedContentMeta);
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_version')) {
      context.handle(
        _lastSyncedVersionMeta,
        lastSyncedVersion.isAcceptableOrUnknown(
          data['last_synced_version']!,
          _lastSyncedVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      encryptedContent: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}encrypted_content'],
      )!,
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      lastSyncedVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_version'],
      )!,
      syncStatus: $ProjectsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class ProjectModel extends DataClass implements Insertable<ProjectModel> {
  final String id;
  final Uint8List encryptedContent;
  final int localVersion;
  final int lastSyncedVersion;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ProjectModel({
    required this.id,
    required this.encryptedContent,
    required this.localVersion,
    required this.lastSyncedVersion,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['encrypted_content'] = Variable<Uint8List>(encryptedContent);
    map['local_version'] = Variable<int>(localVersion);
    map['last_synced_version'] = Variable<int>(lastSyncedVersion);
    {
      map['sync_status'] = Variable<int>(
        $ProjectsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      encryptedContent: Value(encryptedContent),
      localVersion: Value(localVersion),
      lastSyncedVersion: Value(lastSyncedVersion),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ProjectModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectModel(
      id: serializer.fromJson<String>(json['id']),
      encryptedContent: serializer.fromJson<Uint8List>(
        json['encryptedContent'],
      ),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      lastSyncedVersion: serializer.fromJson<int>(json['lastSyncedVersion']),
      syncStatus: $ProjectsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'encryptedContent': serializer.toJson<Uint8List>(encryptedContent),
      'localVersion': serializer.toJson<int>(localVersion),
      'lastSyncedVersion': serializer.toJson<int>(lastSyncedVersion),
      'syncStatus': serializer.toJson<int>(
        $ProjectsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ProjectModel copyWith({
    String? id,
    Uint8List? encryptedContent,
    int? localVersion,
    int? lastSyncedVersion,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ProjectModel(
    id: id ?? this.id,
    encryptedContent: encryptedContent ?? this.encryptedContent,
    localVersion: localVersion ?? this.localVersion,
    lastSyncedVersion: lastSyncedVersion ?? this.lastSyncedVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ProjectModel copyWithCompanion(ProjectsCompanion data) {
    return ProjectModel(
      id: data.id.present ? data.id.value : this.id,
      encryptedContent: data.encryptedContent.present
          ? data.encryptedContent.value
          : this.encryptedContent,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      lastSyncedVersion: data.lastSyncedVersion.present
          ? data.lastSyncedVersion.value
          : this.lastSyncedVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectModel(')
          ..write('id: $id, ')
          ..write('encryptedContent: $encryptedContent, ')
          ..write('localVersion: $localVersion, ')
          ..write('lastSyncedVersion: $lastSyncedVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    $driftBlobEquality.hash(encryptedContent),
    localVersion,
    lastSyncedVersion,
    syncStatus,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectModel &&
          other.id == this.id &&
          $driftBlobEquality.equals(
            other.encryptedContent,
            this.encryptedContent,
          ) &&
          other.localVersion == this.localVersion &&
          other.lastSyncedVersion == this.lastSyncedVersion &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ProjectsCompanion extends UpdateCompanion<ProjectModel> {
  final Value<String> id;
  final Value<Uint8List> encryptedContent;
  final Value<int> localVersion;
  final Value<int> lastSyncedVersion;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.encryptedContent = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.lastSyncedVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required Uint8List encryptedContent,
    this.localVersion = const Value.absent(),
    this.lastSyncedVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : encryptedContent = Value(encryptedContent);
  static Insertable<ProjectModel> custom({
    Expression<String>? id,
    Expression<Uint8List>? encryptedContent,
    Expression<int>? localVersion,
    Expression<int>? lastSyncedVersion,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (encryptedContent != null) 'encrypted_content': encryptedContent,
      if (localVersion != null) 'local_version': localVersion,
      if (lastSyncedVersion != null) 'last_synced_version': lastSyncedVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<Uint8List>? encryptedContent,
    Value<int>? localVersion,
    Value<int>? lastSyncedVersion,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      encryptedContent: encryptedContent ?? this.encryptedContent,
      localVersion: localVersion ?? this.localVersion,
      lastSyncedVersion: lastSyncedVersion ?? this.lastSyncedVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (encryptedContent.present) {
      map['encrypted_content'] = Variable<Uint8List>(encryptedContent.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (lastSyncedVersion.present) {
      map['last_synced_version'] = Variable<int>(lastSyncedVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $ProjectsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('encryptedContent: $encryptedContent, ')
          ..write('localVersion: $localVersion, ')
          ..write('lastSyncedVersion: $lastSyncedVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: const UuidV7().generate,
  );
  static const VerificationMeta _encryptedTitleMeta = const VerificationMeta(
    'encryptedTitle',
  );
  @override
  late final GeneratedColumn<Uint8List> encryptedTitle =
      GeneratedColumn<Uint8List>(
        'encrypted_title',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _encryptedContentMeta = const VerificationMeta(
    'encryptedContent',
  );
  @override
  late final GeneratedColumn<Uint8List> encryptedContent =
      GeneratedColumn<Uint8List>(
        'encrypted_content',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastSyncedVersionMeta = const VerificationMeta(
    'lastSyncedVersion',
  );
  @override
  late final GeneratedColumn<int> lastSyncedVersion = GeneratedColumn<int>(
    'last_synced_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(1),
      ).withConverter<SyncStatus>($NotesTable.$convertersyncStatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON UPDATE CASCADE ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    encryptedTitle,
    encryptedContent,
    localVersion,
    lastSyncedVersion,
    syncStatus,
    createdAt,
    updatedAt,
    deletedAt,
    projectId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('encrypted_title')) {
      context.handle(
        _encryptedTitleMeta,
        encryptedTitle.isAcceptableOrUnknown(
          data['encrypted_title']!,
          _encryptedTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedTitleMeta);
    }
    if (data.containsKey('encrypted_content')) {
      context.handle(
        _encryptedContentMeta,
        encryptedContent.isAcceptableOrUnknown(
          data['encrypted_content']!,
          _encryptedContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedContentMeta);
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_version')) {
      context.handle(
        _lastSyncedVersionMeta,
        lastSyncedVersion.isAcceptableOrUnknown(
          data['last_synced_version']!,
          _lastSyncedVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      encryptedTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}encrypted_title'],
      )!,
      encryptedContent: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}encrypted_content'],
      )!,
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      lastSyncedVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_version'],
      )!,
      syncStatus: $NotesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class NoteModel extends DataClass implements Insertable<NoteModel> {
  final String id;
  final Uint8List encryptedTitle;
  final Uint8List encryptedContent;
  final int localVersion;
  final int lastSyncedVersion;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? projectId;
  const NoteModel({
    required this.id,
    required this.encryptedTitle,
    required this.encryptedContent,
    required this.localVersion,
    required this.lastSyncedVersion,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.projectId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['encrypted_title'] = Variable<Uint8List>(encryptedTitle);
    map['encrypted_content'] = Variable<Uint8List>(encryptedContent);
    map['local_version'] = Variable<int>(localVersion);
    map['last_synced_version'] = Variable<int>(lastSyncedVersion);
    {
      map['sync_status'] = Variable<int>(
        $NotesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      encryptedTitle: Value(encryptedTitle),
      encryptedContent: Value(encryptedContent),
      localVersion: Value(localVersion),
      lastSyncedVersion: Value(lastSyncedVersion),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
    );
  }

  factory NoteModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteModel(
      id: serializer.fromJson<String>(json['id']),
      encryptedTitle: serializer.fromJson<Uint8List>(json['encryptedTitle']),
      encryptedContent: serializer.fromJson<Uint8List>(
        json['encryptedContent'],
      ),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      lastSyncedVersion: serializer.fromJson<int>(json['lastSyncedVersion']),
      syncStatus: $NotesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      projectId: serializer.fromJson<String?>(json['projectId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'encryptedTitle': serializer.toJson<Uint8List>(encryptedTitle),
      'encryptedContent': serializer.toJson<Uint8List>(encryptedContent),
      'localVersion': serializer.toJson<int>(localVersion),
      'lastSyncedVersion': serializer.toJson<int>(lastSyncedVersion),
      'syncStatus': serializer.toJson<int>(
        $NotesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'projectId': serializer.toJson<String?>(projectId),
    };
  }

  NoteModel copyWith({
    String? id,
    Uint8List? encryptedTitle,
    Uint8List? encryptedContent,
    int? localVersion,
    int? lastSyncedVersion,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> projectId = const Value.absent(),
  }) => NoteModel(
    id: id ?? this.id,
    encryptedTitle: encryptedTitle ?? this.encryptedTitle,
    encryptedContent: encryptedContent ?? this.encryptedContent,
    localVersion: localVersion ?? this.localVersion,
    lastSyncedVersion: lastSyncedVersion ?? this.lastSyncedVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    projectId: projectId.present ? projectId.value : this.projectId,
  );
  NoteModel copyWithCompanion(NotesCompanion data) {
    return NoteModel(
      id: data.id.present ? data.id.value : this.id,
      encryptedTitle: data.encryptedTitle.present
          ? data.encryptedTitle.value
          : this.encryptedTitle,
      encryptedContent: data.encryptedContent.present
          ? data.encryptedContent.value
          : this.encryptedContent,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      lastSyncedVersion: data.lastSyncedVersion.present
          ? data.lastSyncedVersion.value
          : this.lastSyncedVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteModel(')
          ..write('id: $id, ')
          ..write('encryptedTitle: $encryptedTitle, ')
          ..write('encryptedContent: $encryptedContent, ')
          ..write('localVersion: $localVersion, ')
          ..write('lastSyncedVersion: $lastSyncedVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('projectId: $projectId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    $driftBlobEquality.hash(encryptedTitle),
    $driftBlobEquality.hash(encryptedContent),
    localVersion,
    lastSyncedVersion,
    syncStatus,
    createdAt,
    updatedAt,
    deletedAt,
    projectId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteModel &&
          other.id == this.id &&
          $driftBlobEquality.equals(
            other.encryptedTitle,
            this.encryptedTitle,
          ) &&
          $driftBlobEquality.equals(
            other.encryptedContent,
            this.encryptedContent,
          ) &&
          other.localVersion == this.localVersion &&
          other.lastSyncedVersion == this.lastSyncedVersion &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.projectId == this.projectId);
}

class NotesCompanion extends UpdateCompanion<NoteModel> {
  final Value<String> id;
  final Value<Uint8List> encryptedTitle;
  final Value<Uint8List> encryptedContent;
  final Value<int> localVersion;
  final Value<int> lastSyncedVersion;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> projectId;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.encryptedTitle = const Value.absent(),
    this.encryptedContent = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.lastSyncedVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.projectId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    required Uint8List encryptedTitle,
    required Uint8List encryptedContent,
    this.localVersion = const Value.absent(),
    this.lastSyncedVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.projectId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : encryptedTitle = Value(encryptedTitle),
       encryptedContent = Value(encryptedContent);
  static Insertable<NoteModel> custom({
    Expression<String>? id,
    Expression<Uint8List>? encryptedTitle,
    Expression<Uint8List>? encryptedContent,
    Expression<int>? localVersion,
    Expression<int>? lastSyncedVersion,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? projectId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (encryptedTitle != null) 'encrypted_title': encryptedTitle,
      if (encryptedContent != null) 'encrypted_content': encryptedContent,
      if (localVersion != null) 'local_version': localVersion,
      if (lastSyncedVersion != null) 'last_synced_version': lastSyncedVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (projectId != null) 'project_id': projectId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<Uint8List>? encryptedTitle,
    Value<Uint8List>? encryptedContent,
    Value<int>? localVersion,
    Value<int>? lastSyncedVersion,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? projectId,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      encryptedTitle: encryptedTitle ?? this.encryptedTitle,
      encryptedContent: encryptedContent ?? this.encryptedContent,
      localVersion: localVersion ?? this.localVersion,
      lastSyncedVersion: lastSyncedVersion ?? this.lastSyncedVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      projectId: projectId ?? this.projectId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (encryptedTitle.present) {
      map['encrypted_title'] = Variable<Uint8List>(encryptedTitle.value);
    }
    if (encryptedContent.present) {
      map['encrypted_content'] = Variable<Uint8List>(encryptedContent.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (lastSyncedVersion.present) {
      map['last_synced_version'] = Variable<int>(lastSyncedVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $NotesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('encryptedTitle: $encryptedTitle, ')
          ..write('encryptedContent: $encryptedContent, ')
          ..write('localVersion: $localVersion, ')
          ..write('lastSyncedVersion: $lastSyncedVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('projectId: $projectId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteConflictsTable extends NoteConflicts
    with TableInfo<$NoteConflictsTable, NoteConflictModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _encryptedTitleMeta = const VerificationMeta(
    'encryptedTitle',
  );
  @override
  late final GeneratedColumn<Uint8List> encryptedTitle =
      GeneratedColumn<Uint8List>(
        'encrypted_title',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _encryptedContentMeta = const VerificationMeta(
    'encryptedContent',
  );
  @override
  late final GeneratedColumn<Uint8List> encryptedContent =
      GeneratedColumn<Uint8List>(
        'encrypted_content',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON UPDATE CASCADE ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    encryptedTitle,
    encryptedContent,
    version,
    createdAt,
    updatedAt,
    deletedAt,
    projectId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteConflictModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('encrypted_title')) {
      context.handle(
        _encryptedTitleMeta,
        encryptedTitle.isAcceptableOrUnknown(
          data['encrypted_title']!,
          _encryptedTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedTitleMeta);
    }
    if (data.containsKey('encrypted_content')) {
      context.handle(
        _encryptedContentMeta,
        encryptedContent.isAcceptableOrUnknown(
          data['encrypted_content']!,
          _encryptedContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedContentMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteConflictModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteConflictModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      encryptedTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}encrypted_title'],
      )!,
      encryptedContent: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}encrypted_content'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
    );
  }

  @override
  $NoteConflictsTable createAlias(String alias) {
    return $NoteConflictsTable(attachedDatabase, alias);
  }
}

class NoteConflictModel extends DataClass
    implements Insertable<NoteConflictModel> {
  final String id;
  final Uint8List encryptedTitle;
  final Uint8List encryptedContent;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? projectId;
  const NoteConflictModel({
    required this.id,
    required this.encryptedTitle,
    required this.encryptedContent,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.projectId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['encrypted_title'] = Variable<Uint8List>(encryptedTitle);
    map['encrypted_content'] = Variable<Uint8List>(encryptedContent);
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    return map;
  }

  NoteConflictsCompanion toCompanion(bool nullToAbsent) {
    return NoteConflictsCompanion(
      id: Value(id),
      encryptedTitle: Value(encryptedTitle),
      encryptedContent: Value(encryptedContent),
      version: Value(version),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
    );
  }

  factory NoteConflictModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteConflictModel(
      id: serializer.fromJson<String>(json['id']),
      encryptedTitle: serializer.fromJson<Uint8List>(json['encryptedTitle']),
      encryptedContent: serializer.fromJson<Uint8List>(
        json['encryptedContent'],
      ),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      projectId: serializer.fromJson<String?>(json['projectId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'encryptedTitle': serializer.toJson<Uint8List>(encryptedTitle),
      'encryptedContent': serializer.toJson<Uint8List>(encryptedContent),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'projectId': serializer.toJson<String?>(projectId),
    };
  }

  NoteConflictModel copyWith({
    String? id,
    Uint8List? encryptedTitle,
    Uint8List? encryptedContent,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> projectId = const Value.absent(),
  }) => NoteConflictModel(
    id: id ?? this.id,
    encryptedTitle: encryptedTitle ?? this.encryptedTitle,
    encryptedContent: encryptedContent ?? this.encryptedContent,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    projectId: projectId.present ? projectId.value : this.projectId,
  );
  NoteConflictModel copyWithCompanion(NoteConflictsCompanion data) {
    return NoteConflictModel(
      id: data.id.present ? data.id.value : this.id,
      encryptedTitle: data.encryptedTitle.present
          ? data.encryptedTitle.value
          : this.encryptedTitle,
      encryptedContent: data.encryptedContent.present
          ? data.encryptedContent.value
          : this.encryptedContent,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteConflictModel(')
          ..write('id: $id, ')
          ..write('encryptedTitle: $encryptedTitle, ')
          ..write('encryptedContent: $encryptedContent, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('projectId: $projectId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    $driftBlobEquality.hash(encryptedTitle),
    $driftBlobEquality.hash(encryptedContent),
    version,
    createdAt,
    updatedAt,
    deletedAt,
    projectId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteConflictModel &&
          other.id == this.id &&
          $driftBlobEquality.equals(
            other.encryptedTitle,
            this.encryptedTitle,
          ) &&
          $driftBlobEquality.equals(
            other.encryptedContent,
            this.encryptedContent,
          ) &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.projectId == this.projectId);
}

class NoteConflictsCompanion extends UpdateCompanion<NoteConflictModel> {
  final Value<String> id;
  final Value<Uint8List> encryptedTitle;
  final Value<Uint8List> encryptedContent;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> projectId;
  final Value<int> rowid;
  const NoteConflictsCompanion({
    this.id = const Value.absent(),
    this.encryptedTitle = const Value.absent(),
    this.encryptedContent = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.projectId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteConflictsCompanion.insert({
    required String id,
    required Uint8List encryptedTitle,
    required Uint8List encryptedContent,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.projectId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       encryptedTitle = Value(encryptedTitle),
       encryptedContent = Value(encryptedContent),
       version = Value(version),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NoteConflictModel> custom({
    Expression<String>? id,
    Expression<Uint8List>? encryptedTitle,
    Expression<Uint8List>? encryptedContent,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? projectId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (encryptedTitle != null) 'encrypted_title': encryptedTitle,
      if (encryptedContent != null) 'encrypted_content': encryptedContent,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (projectId != null) 'project_id': projectId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteConflictsCompanion copyWith({
    Value<String>? id,
    Value<Uint8List>? encryptedTitle,
    Value<Uint8List>? encryptedContent,
    Value<int>? version,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? projectId,
    Value<int>? rowid,
  }) {
    return NoteConflictsCompanion(
      id: id ?? this.id,
      encryptedTitle: encryptedTitle ?? this.encryptedTitle,
      encryptedContent: encryptedContent ?? this.encryptedContent,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      projectId: projectId ?? this.projectId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (encryptedTitle.present) {
      map['encrypted_title'] = Variable<Uint8List>(encryptedTitle.value);
    }
    if (encryptedContent.present) {
      map['encrypted_content'] = Variable<Uint8List>(encryptedContent.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteConflictsCompanion(')
          ..write('id: $id, ')
          ..write('encryptedTitle: $encryptedTitle, ')
          ..write('encryptedContent: $encryptedContent, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('projectId: $projectId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $KeySlotsTable keySlots = $KeySlotsTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $NoteConflictsTable noteConflicts = $NoteConflictsTable(this);
  late final KeySlotsDao keySlotsDao = KeySlotsDao(this as AppDatabase);
  late final NotesDao notesDao = NotesDao(this as AppDatabase);
  late final ProjectsDao projectsDao = ProjectsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    keySlots,
    projects,
    notes,
    noteConflicts,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('notes', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('notes', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_conflicts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('note_conflicts', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_conflicts', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('note_conflicts', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$KeySlotsTableCreateCompanionBuilder =
    KeySlotsCompanion Function({
      Value<KeyType> type,
      required Uint8List salt,
      required Uint8List wrappedMasterKey,
      Value<SyncStatus> syncStatus,
      Value<DateTime> updatedAt,
    });
typedef $$KeySlotsTableUpdateCompanionBuilder =
    KeySlotsCompanion Function({
      Value<KeyType> type,
      Value<Uint8List> salt,
      Value<Uint8List> wrappedMasterKey,
      Value<SyncStatus> syncStatus,
      Value<DateTime> updatedAt,
    });

class $$KeySlotsTableFilterComposer
    extends Composer<_$AppDatabase, $KeySlotsTable> {
  $$KeySlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<KeyType, KeyType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<Uint8List> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get wrappedMasterKey => $composableBuilder(
    column: $table.wrappedMasterKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KeySlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $KeySlotsTable> {
  $$KeySlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get wrappedMasterKey => $composableBuilder(
    column: $table.wrappedMasterKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KeySlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $KeySlotsTable> {
  $$KeySlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<KeyType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<Uint8List> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<Uint8List> get wrappedMasterKey => $composableBuilder(
    column: $table.wrappedMasterKey,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$KeySlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KeySlotsTable,
          KeySlotModel,
          $$KeySlotsTableFilterComposer,
          $$KeySlotsTableOrderingComposer,
          $$KeySlotsTableAnnotationComposer,
          $$KeySlotsTableCreateCompanionBuilder,
          $$KeySlotsTableUpdateCompanionBuilder,
          (
            KeySlotModel,
            BaseReferences<_$AppDatabase, $KeySlotsTable, KeySlotModel>,
          ),
          KeySlotModel,
          PrefetchHooks Function()
        > {
  $$KeySlotsTableTableManager(_$AppDatabase db, $KeySlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeySlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeySlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeySlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<KeyType> type = const Value.absent(),
                Value<Uint8List> salt = const Value.absent(),
                Value<Uint8List> wrappedMasterKey = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => KeySlotsCompanion(
                type: type,
                salt: salt,
                wrappedMasterKey: wrappedMasterKey,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<KeyType> type = const Value.absent(),
                required Uint8List salt,
                required Uint8List wrappedMasterKey,
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => KeySlotsCompanion.insert(
                type: type,
                salt: salt,
                wrappedMasterKey: wrappedMasterKey,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KeySlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KeySlotsTable,
      KeySlotModel,
      $$KeySlotsTableFilterComposer,
      $$KeySlotsTableOrderingComposer,
      $$KeySlotsTableAnnotationComposer,
      $$KeySlotsTableCreateCompanionBuilder,
      $$KeySlotsTableUpdateCompanionBuilder,
      (
        KeySlotModel,
        BaseReferences<_$AppDatabase, $KeySlotsTable, KeySlotModel>,
      ),
      KeySlotModel,
      PrefetchHooks Function()
    >;
typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      required Uint8List encryptedContent,
      Value<int> localVersion,
      Value<int> lastSyncedVersion,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      Value<Uint8List> encryptedContent,
      Value<int> localVersion,
      Value<int> lastSyncedVersion,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, ProjectModel> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NotesTable, List<NoteModel>> _notesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.notes,
    aliasName: $_aliasNameGenerator(db.projects.id, db.notes.projectId),
  );

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NoteConflictsTable, List<NoteConflictModel>>
  _noteConflictsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.noteConflicts,
    aliasName: $_aliasNameGenerator(db.projects.id, db.noteConflicts.projectId),
  );

  $$NoteConflictsTableProcessedTableManager get noteConflictsRefs {
    final manager = $$NoteConflictsTableTableManager(
      $_db,
      $_db.noteConflicts,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteConflictsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
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

  ColumnFilters<Uint8List> get encryptedContent => $composableBuilder(
    column: $table.encryptedContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedVersion => $composableBuilder(
    column: $table.lastSyncedVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> notesRefs(
    Expression<bool> Function($$NotesTableFilterComposer f) f,
  ) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> noteConflictsRefs(
    Expression<bool> Function($$NoteConflictsTableFilterComposer f) f,
  ) {
    final $$NoteConflictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteConflicts,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteConflictsTableFilterComposer(
            $db: $db,
            $table: $db.noteConflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get encryptedContent => $composableBuilder(
    column: $table.encryptedContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedVersion => $composableBuilder(
    column: $table.lastSyncedVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get encryptedContent => $composableBuilder(
    column: $table.encryptedContent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedVersion => $composableBuilder(
    column: $table.lastSyncedVersion,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> notesRefs<T extends Object>(
    Expression<T> Function($$NotesTableAnnotationComposer a) f,
  ) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> noteConflictsRefs<T extends Object>(
    Expression<T> Function($$NoteConflictsTableAnnotationComposer a) f,
  ) {
    final $$NoteConflictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteConflicts,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteConflictsTableAnnotationComposer(
            $db: $db,
            $table: $db.noteConflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          ProjectModel,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (ProjectModel, $$ProjectsTableReferences),
          ProjectModel,
          PrefetchHooks Function({bool notesRefs, bool noteConflictsRefs})
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Uint8List> encryptedContent = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<int> lastSyncedVersion = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                encryptedContent: encryptedContent,
                localVersion: localVersion,
                lastSyncedVersion: lastSyncedVersion,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required Uint8List encryptedContent,
                Value<int> localVersion = const Value.absent(),
                Value<int> lastSyncedVersion = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                encryptedContent: encryptedContent,
                localVersion: localVersion,
                lastSyncedVersion: lastSyncedVersion,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({notesRefs = false, noteConflictsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (notesRefs) db.notes,
                    if (noteConflictsRefs) db.noteConflicts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (notesRefs)
                        await $_getPrefetchedData<
                          ProjectModel,
                          $ProjectsTable,
                          NoteModel
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._notesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).notesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (noteConflictsRefs)
                        await $_getPrefetchedData<
                          ProjectModel,
                          $ProjectsTable,
                          NoteConflictModel
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._noteConflictsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).noteConflictsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      ProjectModel,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (ProjectModel, $$ProjectsTableReferences),
      ProjectModel,
      PrefetchHooks Function({bool notesRefs, bool noteConflictsRefs})
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      Value<String> id,
      required Uint8List encryptedTitle,
      required Uint8List encryptedContent,
      Value<int> localVersion,
      Value<int> lastSyncedVersion,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> projectId,
      Value<int> rowid,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<String> id,
      Value<Uint8List> encryptedTitle,
      Value<Uint8List> encryptedContent,
      Value<int> localVersion,
      Value<int> lastSyncedVersion,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> projectId,
      Value<int> rowid,
    });

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, NoteModel> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) => db.projects
      .createAlias($_aliasNameGenerator(db.notes.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$NoteConflictsTable, List<NoteConflictModel>>
  _noteConflictsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.noteConflicts,
    aliasName: $_aliasNameGenerator(db.notes.id, db.noteConflicts.id),
  );

  $$NoteConflictsTableProcessedTableManager get noteConflictsRefs {
    final manager = $$NoteConflictsTableTableManager(
      $_db,
      $_db.noteConflicts,
    ).filter((f) => f.id.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteConflictsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
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

  ColumnFilters<Uint8List> get encryptedTitle => $composableBuilder(
    column: $table.encryptedTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get encryptedContent => $composableBuilder(
    column: $table.encryptedContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedVersion => $composableBuilder(
    column: $table.lastSyncedVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> noteConflictsRefs(
    Expression<bool> Function($$NoteConflictsTableFilterComposer f) f,
  ) {
    final $$NoteConflictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteConflicts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteConflictsTableFilterComposer(
            $db: $db,
            $table: $db.noteConflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get encryptedTitle => $composableBuilder(
    column: $table.encryptedTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get encryptedContent => $composableBuilder(
    column: $table.encryptedContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedVersion => $composableBuilder(
    column: $table.lastSyncedVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get encryptedTitle => $composableBuilder(
    column: $table.encryptedTitle,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get encryptedContent => $composableBuilder(
    column: $table.encryptedContent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedVersion => $composableBuilder(
    column: $table.lastSyncedVersion,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> noteConflictsRefs<T extends Object>(
    Expression<T> Function($$NoteConflictsTableAnnotationComposer a) f,
  ) {
    final $$NoteConflictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteConflicts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteConflictsTableAnnotationComposer(
            $db: $db,
            $table: $db.noteConflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          NoteModel,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (NoteModel, $$NotesTableReferences),
          NoteModel,
          PrefetchHooks Function({bool projectId, bool noteConflictsRefs})
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Uint8List> encryptedTitle = const Value.absent(),
                Value<Uint8List> encryptedContent = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<int> lastSyncedVersion = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                encryptedTitle: encryptedTitle,
                encryptedContent: encryptedContent,
                localVersion: localVersion,
                lastSyncedVersion: lastSyncedVersion,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                projectId: projectId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required Uint8List encryptedTitle,
                required Uint8List encryptedContent,
                Value<int> localVersion = const Value.absent(),
                Value<int> lastSyncedVersion = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                encryptedTitle: encryptedTitle,
                encryptedContent: encryptedContent,
                localVersion: localVersion,
                lastSyncedVersion: lastSyncedVersion,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                projectId: projectId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$NotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({projectId = false, noteConflictsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (noteConflictsRefs) db.noteConflicts,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable: $$NotesTableReferences
                                        ._projectIdTable(db),
                                    referencedColumn: $$NotesTableReferences
                                        ._projectIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (noteConflictsRefs)
                        await $_getPrefetchedData<
                          NoteModel,
                          $NotesTable,
                          NoteConflictModel
                        >(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._noteConflictsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(
                                db,
                                table,
                                p0,
                              ).noteConflictsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) =>
                                  referencedItems.where((e) => e.id == item.id),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      NoteModel,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (NoteModel, $$NotesTableReferences),
      NoteModel,
      PrefetchHooks Function({bool projectId, bool noteConflictsRefs})
    >;
typedef $$NoteConflictsTableCreateCompanionBuilder =
    NoteConflictsCompanion Function({
      required String id,
      required Uint8List encryptedTitle,
      required Uint8List encryptedContent,
      required int version,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> projectId,
      Value<int> rowid,
    });
typedef $$NoteConflictsTableUpdateCompanionBuilder =
    NoteConflictsCompanion Function({
      Value<String> id,
      Value<Uint8List> encryptedTitle,
      Value<Uint8List> encryptedContent,
      Value<int> version,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> projectId,
      Value<int> rowid,
    });

final class $$NoteConflictsTableReferences
    extends
        BaseReferences<_$AppDatabase, $NoteConflictsTable, NoteConflictModel> {
  $$NoteConflictsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NotesTable _idTable(_$AppDatabase db) => db.notes.createAlias(
    $_aliasNameGenerator(db.noteConflicts.id, db.notes.id),
  );

  $$NotesTableProcessedTableManager get id {
    final $_column = $_itemColumn<String>('id')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_idTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
        $_aliasNameGenerator(db.noteConflicts.projectId, db.projects.id),
      );

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoteConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $NoteConflictsTable> {
  $$NoteConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<Uint8List> get encryptedTitle => $composableBuilder(
    column: $table.encryptedTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get encryptedContent => $composableBuilder(
    column: $table.encryptedContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NotesTableFilterComposer get id {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteConflictsTable> {
  $$NoteConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get encryptedTitle => $composableBuilder(
    column: $table.encryptedTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get encryptedContent => $composableBuilder(
    column: $table.encryptedContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotesTableOrderingComposer get id {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteConflictsTable> {
  $$NoteConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<Uint8List> get encryptedTitle => $composableBuilder(
    column: $table.encryptedTitle,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get encryptedContent => $composableBuilder(
    column: $table.encryptedContent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$NotesTableAnnotationComposer get id {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteConflictsTable,
          NoteConflictModel,
          $$NoteConflictsTableFilterComposer,
          $$NoteConflictsTableOrderingComposer,
          $$NoteConflictsTableAnnotationComposer,
          $$NoteConflictsTableCreateCompanionBuilder,
          $$NoteConflictsTableUpdateCompanionBuilder,
          (NoteConflictModel, $$NoteConflictsTableReferences),
          NoteConflictModel,
          PrefetchHooks Function({bool id, bool projectId})
        > {
  $$NoteConflictsTableTableManager(_$AppDatabase db, $NoteConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Uint8List> encryptedTitle = const Value.absent(),
                Value<Uint8List> encryptedContent = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteConflictsCompanion(
                id: id,
                encryptedTitle: encryptedTitle,
                encryptedContent: encryptedContent,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                projectId: projectId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required Uint8List encryptedTitle,
                required Uint8List encryptedContent,
                required int version,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteConflictsCompanion.insert(
                id: id,
                encryptedTitle: encryptedTitle,
                encryptedContent: encryptedContent,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                projectId: projectId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NoteConflictsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({id = false, projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (id) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.id,
                                referencedTable: $$NoteConflictsTableReferences
                                    ._idTable(db),
                                referencedColumn: $$NoteConflictsTableReferences
                                    ._idTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$NoteConflictsTableReferences
                                    ._projectIdTable(db),
                                referencedColumn: $$NoteConflictsTableReferences
                                    ._projectIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NoteConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteConflictsTable,
      NoteConflictModel,
      $$NoteConflictsTableFilterComposer,
      $$NoteConflictsTableOrderingComposer,
      $$NoteConflictsTableAnnotationComposer,
      $$NoteConflictsTableCreateCompanionBuilder,
      $$NoteConflictsTableUpdateCompanionBuilder,
      (NoteConflictModel, $$NoteConflictsTableReferences),
      NoteConflictModel,
      PrefetchHooks Function({bool id, bool projectId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$KeySlotsTableTableManager get keySlots =>
      $$KeySlotsTableTableManager(_db, _db.keySlots);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$NoteConflictsTableTableManager get noteConflicts =>
      $$NoteConflictsTableTableManager(_db, _db.noteConflicts);
}
