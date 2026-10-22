// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChildrenTable extends Children
    with TableInfo<$ChildrenTable, ChildrenData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChildrenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _duolingoUsernameMeta = const VerificationMeta(
    'duolingoUsername',
  );
  @override
  late final GeneratedColumn<String> duolingoUsername = GeneratedColumn<String>(
    'duolingo_username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _duolingoPackageMeta = const VerificationMeta(
    'duolingoPackage',
  );
  @override
  late final GeneratedColumn<String> duolingoPackage = GeneratedColumn<String>(
    'duolingo_package',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('com.duolingo'),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    avatarPath,
    duolingoUsername,
    duolingoPackage,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'children';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChildrenData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('duolingo_username')) {
      context.handle(
        _duolingoUsernameMeta,
        duolingoUsername.isAcceptableOrUnknown(
          data['duolingo_username']!,
          _duolingoUsernameMeta,
        ),
      );
    }
    if (data.containsKey('duolingo_package')) {
      context.handle(
        _duolingoPackageMeta,
        duolingoPackage.isAcceptableOrUnknown(
          data['duolingo_package']!,
          _duolingoPackageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChildrenData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChildrenData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      duolingoUsername: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duolingo_username'],
      ),
      duolingoPackage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duolingo_package'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChildrenTable createAlias(String alias) {
    return $ChildrenTable(attachedDatabase, alias);
  }
}

class ChildrenData extends DataClass implements Insertable<ChildrenData> {
  final int id;
  final String name;
  final String? avatarPath;
  final String? duolingoUsername;
  final String duolingoPackage;
  final DateTime createdAt;
  const ChildrenData({
    required this.id,
    required this.name,
    this.avatarPath,
    this.duolingoUsername,
    required this.duolingoPackage,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    if (!nullToAbsent || duolingoUsername != null) {
      map['duolingo_username'] = Variable<String>(duolingoUsername);
    }
    map['duolingo_package'] = Variable<String>(duolingoPackage);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChildrenCompanion toCompanion(bool nullToAbsent) {
    return ChildrenCompanion(
      id: Value(id),
      name: Value(name),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      duolingoUsername: duolingoUsername == null && nullToAbsent
          ? const Value.absent()
          : Value(duolingoUsername),
      duolingoPackage: Value(duolingoPackage),
      createdAt: Value(createdAt),
    );
  }

  factory ChildrenData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChildrenData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      duolingoUsername: serializer.fromJson<String?>(json['duolingoUsername']),
      duolingoPackage: serializer.fromJson<String>(json['duolingoPackage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'duolingoUsername': serializer.toJson<String?>(duolingoUsername),
      'duolingoPackage': serializer.toJson<String>(duolingoPackage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChildrenData copyWith({
    int? id,
    String? name,
    Value<String?> avatarPath = const Value.absent(),
    Value<String?> duolingoUsername = const Value.absent(),
    String? duolingoPackage,
    DateTime? createdAt,
  }) => ChildrenData(
    id: id ?? this.id,
    name: name ?? this.name,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    duolingoUsername: duolingoUsername.present
        ? duolingoUsername.value
        : this.duolingoUsername,
    duolingoPackage: duolingoPackage ?? this.duolingoPackage,
    createdAt: createdAt ?? this.createdAt,
  );
  ChildrenData copyWithCompanion(ChildrenCompanion data) {
    return ChildrenData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      duolingoUsername: data.duolingoUsername.present
          ? data.duolingoUsername.value
          : this.duolingoUsername,
      duolingoPackage: data.duolingoPackage.present
          ? data.duolingoPackage.value
          : this.duolingoPackage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChildrenData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('duolingoUsername: $duolingoUsername, ')
          ..write('duolingoPackage: $duolingoPackage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    avatarPath,
    duolingoUsername,
    duolingoPackage,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChildrenData &&
          other.id == this.id &&
          other.name == this.name &&
          other.avatarPath == this.avatarPath &&
          other.duolingoUsername == this.duolingoUsername &&
          other.duolingoPackage == this.duolingoPackage &&
          other.createdAt == this.createdAt);
}

class ChildrenCompanion extends UpdateCompanion<ChildrenData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> avatarPath;
  final Value<String?> duolingoUsername;
  final Value<String> duolingoPackage;
  final Value<DateTime> createdAt;
  const ChildrenCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.duolingoUsername = const Value.absent(),
    this.duolingoPackage = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChildrenCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.avatarPath = const Value.absent(),
    this.duolingoUsername = const Value.absent(),
    this.duolingoPackage = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ChildrenData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? avatarPath,
    Expression<String>? duolingoUsername,
    Expression<String>? duolingoPackage,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (duolingoUsername != null) 'duolingo_username': duolingoUsername,
      if (duolingoPackage != null) 'duolingo_package': duolingoPackage,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChildrenCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? avatarPath,
    Value<String?>? duolingoUsername,
    Value<String>? duolingoPackage,
    Value<DateTime>? createdAt,
  }) {
    return ChildrenCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      duolingoUsername: duolingoUsername ?? this.duolingoUsername,
      duolingoPackage: duolingoPackage ?? this.duolingoPackage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (duolingoUsername.present) {
      map['duolingo_username'] = Variable<String>(duolingoUsername.value);
    }
    if (duolingoPackage.present) {
      map['duolingo_package'] = Variable<String>(duolingoPackage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildrenCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('duolingoUsername: $duolingoUsername, ')
          ..write('duolingoPackage: $duolingoPackage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    name,
    iconKey,
    colorValue,
    sortOrder,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;

  /// 'praise'(칭찬) 또는 'misdeed'(잘못)
  final String kind;
  final String name;
  final String iconKey;
  final int colorValue;
  final int sortOrder;
  final bool isActive;
  const Category({
    required this.id,
    required this.kind,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    required this.sortOrder,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['name'] = Variable<String>(name);
    map['icon_key'] = Variable<String>(iconKey);
    map['color_value'] = Variable<int>(colorValue);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      kind: Value(kind),
      name: Value(name),
      iconKey: Value(iconKey),
      colorValue: Value(colorValue),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      name: serializer.fromJson<String>(json['name']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'name': serializer.toJson<String>(name),
      'iconKey': serializer.toJson<String>(iconKey),
      'colorValue': serializer.toJson<int>(colorValue),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Category copyWith({
    int? id,
    String? kind,
    String? name,
    String? iconKey,
    int? colorValue,
    int? sortOrder,
    bool? isActive,
  }) => Category(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    iconKey: iconKey ?? this.iconKey,
    colorValue: colorValue ?? this.colorValue,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, name, iconKey, colorValue, sortOrder, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.iconKey == this.iconKey &&
          other.colorValue == this.colorValue &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String> name;
  final Value<String> iconKey;
  final Value<int> colorValue;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required String name,
    required String iconKey,
    required int colorValue,
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : kind = Value(kind),
       name = Value(name),
       iconKey = Value(iconKey),
       colorValue = Value(colorValue);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<String>? iconKey,
    Expression<int>? colorValue,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (iconKey != null) 'icon_key': iconKey,
      if (colorValue != null) 'color_value': colorValue,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String>? name,
    Value<String>? iconKey,
    Value<int>? colorValue,
    Value<int>? sortOrder,
    Value<bool>? isActive,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $RewardsTable extends Rewards with TableInfo<$RewardsTable, Reward> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RewardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<int> cost = GeneratedColumn<int>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    cost,
    imagePath,
    sortOrder,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rewards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reward> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reward map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reward(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $RewardsTable createAlias(String alias) {
    return $RewardsTable(attachedDatabase, alias);
  }
}

class Reward extends DataClass implements Insertable<Reward> {
  final int id;
  final String name;
  final int cost;
  final String? imagePath;
  final int sortOrder;
  final bool isActive;
  const Reward({
    required this.id,
    required this.name,
    required this.cost,
    this.imagePath,
    required this.sortOrder,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['cost'] = Variable<int>(cost);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  RewardsCompanion toCompanion(bool nullToAbsent) {
    return RewardsCompanion(
      id: Value(id),
      name: Value(name),
      cost: Value(cost),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
    );
  }

  factory Reward.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reward(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cost: serializer.fromJson<int>(json['cost']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'cost': serializer.toJson<int>(cost),
      'imagePath': serializer.toJson<String?>(imagePath),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Reward copyWith({
    int? id,
    String? name,
    int? cost,
    Value<String?> imagePath = const Value.absent(),
    int? sortOrder,
    bool? isActive,
  }) => Reward(
    id: id ?? this.id,
    name: name ?? this.name,
    cost: cost ?? this.cost,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
  );
  Reward copyWithCompanion(RewardsCompanion data) {
    return Reward(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cost: data.cost.present ? data.cost.value : this.cost,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reward(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cost: $cost, ')
          ..write('imagePath: $imagePath, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, cost, imagePath, sortOrder, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reward &&
          other.id == this.id &&
          other.name == this.name &&
          other.cost == this.cost &&
          other.imagePath == this.imagePath &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive);
}

class RewardsCompanion extends UpdateCompanion<Reward> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> cost;
  final Value<String?> imagePath;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  const RewardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cost = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  RewardsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int cost,
    this.imagePath = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : name = Value(name),
       cost = Value(cost);
  static Insertable<Reward> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? cost,
    Expression<String>? imagePath,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cost != null) 'cost': cost,
      if (imagePath != null) 'image_path': imagePath,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
    });
  }

  RewardsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? cost,
    Value<String?>? imagePath,
    Value<int>? sortOrder,
    Value<bool>? isActive,
  }) {
    return RewardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      imagePath: imagePath ?? this.imagePath,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cost.present) {
      map['cost'] = Variable<int>(cost.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RewardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cost: $cost, ')
          ..write('imagePath: $imagePath, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $StickerEventsTable extends StickerEvents
    with TableInfo<$StickerEventsTable, StickerEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StickerEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id)',
    ),
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextPromiseMeta = const VerificationMeta(
    'nextPromise',
  );
  @override
  late final GeneratedColumn<String> nextPromise = GeneratedColumn<String>(
    'next_promise',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rewardIdMeta = const VerificationMeta(
    'rewardId',
  );
  @override
  late final GeneratedColumn<int> rewardId = GeneratedColumn<int>(
    'reward_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rewards (id)',
    ),
  );
  static const VerificationMeta _relatedEventIdMeta = const VerificationMeta(
    'relatedEventId',
  );
  @override
  late final GeneratedColumn<int> relatedEventId = GeneratedColumn<int>(
    'related_event_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    eventType,
    amount,
    categoryId,
    memo,
    nextPromise,
    rewardId,
    relatedEventId,
    createdAt,
    localDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sticker_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<StickerEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('next_promise')) {
      context.handle(
        _nextPromiseMeta,
        nextPromise.isAcceptableOrUnknown(
          data['next_promise']!,
          _nextPromiseMeta,
        ),
      );
    }
    if (data.containsKey('reward_id')) {
      context.handle(
        _rewardIdMeta,
        rewardId.isAcceptableOrUnknown(data['reward_id']!, _rewardIdMeta),
      );
    }
    if (data.containsKey('related_event_id')) {
      context.handle(
        _relatedEventIdMeta,
        relatedEventId.isAcceptableOrUnknown(
          data['related_event_id']!,
          _relatedEventIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StickerEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StickerEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      nextPromise: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_promise'],
      ),
      rewardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward_id'],
      ),
      relatedEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}related_event_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
    );
  }

  @override
  $StickerEventsTable createAlias(String alias) {
    return $StickerEventsTable(attachedDatabase, alias);
  }
}

class StickerEvent extends DataClass implements Insertable<StickerEvent> {
  final int id;
  final int childId;

  /// earn | remove | warn | redeem | undo | adjust | bonus
  final String eventType;

  /// 받으면 양수, 빼거나 교환하면 음수. 잔액 = 이 값들의 합.
  final int amount;
  final int? categoryId;
  final String? memo;
  final String? nextPromise;
  final int? rewardId;
  final int? relatedEventId;
  final DateTime createdAt;

  /// 기기 시간대 기준 'YYYY-MM-DD'. 달력 집계용.
  final String localDate;
  const StickerEvent({
    required this.id,
    required this.childId,
    required this.eventType,
    required this.amount,
    this.categoryId,
    this.memo,
    this.nextPromise,
    this.rewardId,
    this.relatedEventId,
    required this.createdAt,
    required this.localDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['child_id'] = Variable<int>(childId);
    map['type'] = Variable<String>(eventType);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    if (!nullToAbsent || nextPromise != null) {
      map['next_promise'] = Variable<String>(nextPromise);
    }
    if (!nullToAbsent || rewardId != null) {
      map['reward_id'] = Variable<int>(rewardId);
    }
    if (!nullToAbsent || relatedEventId != null) {
      map['related_event_id'] = Variable<int>(relatedEventId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['local_date'] = Variable<String>(localDate);
    return map;
  }

  StickerEventsCompanion toCompanion(bool nullToAbsent) {
    return StickerEventsCompanion(
      id: Value(id),
      childId: Value(childId),
      eventType: Value(eventType),
      amount: Value(amount),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      nextPromise: nextPromise == null && nullToAbsent
          ? const Value.absent()
          : Value(nextPromise),
      rewardId: rewardId == null && nullToAbsent
          ? const Value.absent()
          : Value(rewardId),
      relatedEventId: relatedEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedEventId),
      createdAt: Value(createdAt),
      localDate: Value(localDate),
    );
  }

  factory StickerEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StickerEvent(
      id: serializer.fromJson<int>(json['id']),
      childId: serializer.fromJson<int>(json['childId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      amount: serializer.fromJson<int>(json['amount']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      memo: serializer.fromJson<String?>(json['memo']),
      nextPromise: serializer.fromJson<String?>(json['nextPromise']),
      rewardId: serializer.fromJson<int?>(json['rewardId']),
      relatedEventId: serializer.fromJson<int?>(json['relatedEventId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      localDate: serializer.fromJson<String>(json['localDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childId': serializer.toJson<int>(childId),
      'eventType': serializer.toJson<String>(eventType),
      'amount': serializer.toJson<int>(amount),
      'categoryId': serializer.toJson<int?>(categoryId),
      'memo': serializer.toJson<String?>(memo),
      'nextPromise': serializer.toJson<String?>(nextPromise),
      'rewardId': serializer.toJson<int?>(rewardId),
      'relatedEventId': serializer.toJson<int?>(relatedEventId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'localDate': serializer.toJson<String>(localDate),
    };
  }

  StickerEvent copyWith({
    int? id,
    int? childId,
    String? eventType,
    int? amount,
    Value<int?> categoryId = const Value.absent(),
    Value<String?> memo = const Value.absent(),
    Value<String?> nextPromise = const Value.absent(),
    Value<int?> rewardId = const Value.absent(),
    Value<int?> relatedEventId = const Value.absent(),
    DateTime? createdAt,
    String? localDate,
  }) => StickerEvent(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    eventType: eventType ?? this.eventType,
    amount: amount ?? this.amount,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    memo: memo.present ? memo.value : this.memo,
    nextPromise: nextPromise.present ? nextPromise.value : this.nextPromise,
    rewardId: rewardId.present ? rewardId.value : this.rewardId,
    relatedEventId: relatedEventId.present
        ? relatedEventId.value
        : this.relatedEventId,
    createdAt: createdAt ?? this.createdAt,
    localDate: localDate ?? this.localDate,
  );
  StickerEvent copyWithCompanion(StickerEventsCompanion data) {
    return StickerEvent(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      memo: data.memo.present ? data.memo.value : this.memo,
      nextPromise: data.nextPromise.present
          ? data.nextPromise.value
          : this.nextPromise,
      rewardId: data.rewardId.present ? data.rewardId.value : this.rewardId,
      relatedEventId: data.relatedEventId.present
          ? data.relatedEventId.value
          : this.relatedEventId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StickerEvent(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('eventType: $eventType, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('memo: $memo, ')
          ..write('nextPromise: $nextPromise, ')
          ..write('rewardId: $rewardId, ')
          ..write('relatedEventId: $relatedEventId, ')
          ..write('createdAt: $createdAt, ')
          ..write('localDate: $localDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    eventType,
    amount,
    categoryId,
    memo,
    nextPromise,
    rewardId,
    relatedEventId,
    createdAt,
    localDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StickerEvent &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.eventType == this.eventType &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.memo == this.memo &&
          other.nextPromise == this.nextPromise &&
          other.rewardId == this.rewardId &&
          other.relatedEventId == this.relatedEventId &&
          other.createdAt == this.createdAt &&
          other.localDate == this.localDate);
}

class StickerEventsCompanion extends UpdateCompanion<StickerEvent> {
  final Value<int> id;
  final Value<int> childId;
  final Value<String> eventType;
  final Value<int> amount;
  final Value<int?> categoryId;
  final Value<String?> memo;
  final Value<String?> nextPromise;
  final Value<int?> rewardId;
  final Value<int?> relatedEventId;
  final Value<DateTime> createdAt;
  final Value<String> localDate;
  const StickerEventsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.memo = const Value.absent(),
    this.nextPromise = const Value.absent(),
    this.rewardId = const Value.absent(),
    this.relatedEventId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.localDate = const Value.absent(),
  });
  StickerEventsCompanion.insert({
    this.id = const Value.absent(),
    required int childId,
    required String eventType,
    required int amount,
    this.categoryId = const Value.absent(),
    this.memo = const Value.absent(),
    this.nextPromise = const Value.absent(),
    this.rewardId = const Value.absent(),
    this.relatedEventId = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String localDate,
  }) : childId = Value(childId),
       eventType = Value(eventType),
       amount = Value(amount),
       localDate = Value(localDate);
  static Insertable<StickerEvent> custom({
    Expression<int>? id,
    Expression<int>? childId,
    Expression<String>? eventType,
    Expression<int>? amount,
    Expression<int>? categoryId,
    Expression<String>? memo,
    Expression<String>? nextPromise,
    Expression<int>? rewardId,
    Expression<int>? relatedEventId,
    Expression<DateTime>? createdAt,
    Expression<String>? localDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (eventType != null) 'type': eventType,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (memo != null) 'memo': memo,
      if (nextPromise != null) 'next_promise': nextPromise,
      if (rewardId != null) 'reward_id': rewardId,
      if (relatedEventId != null) 'related_event_id': relatedEventId,
      if (createdAt != null) 'created_at': createdAt,
      if (localDate != null) 'local_date': localDate,
    });
  }

  StickerEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? childId,
    Value<String>? eventType,
    Value<int>? amount,
    Value<int?>? categoryId,
    Value<String?>? memo,
    Value<String?>? nextPromise,
    Value<int?>? rewardId,
    Value<int?>? relatedEventId,
    Value<DateTime>? createdAt,
    Value<String>? localDate,
  }) {
    return StickerEventsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      eventType: eventType ?? this.eventType,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      memo: memo ?? this.memo,
      nextPromise: nextPromise ?? this.nextPromise,
      rewardId: rewardId ?? this.rewardId,
      relatedEventId: relatedEventId ?? this.relatedEventId,
      createdAt: createdAt ?? this.createdAt,
      localDate: localDate ?? this.localDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (eventType.present) {
      map['type'] = Variable<String>(eventType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (nextPromise.present) {
      map['next_promise'] = Variable<String>(nextPromise.value);
    }
    if (rewardId.present) {
      map['reward_id'] = Variable<int>(rewardId.value);
    }
    if (relatedEventId.present) {
      map['related_event_id'] = Variable<int>(relatedEventId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StickerEventsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('eventType: $eventType, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('memo: $memo, ')
          ..write('nextPromise: $nextPromise, ')
          ..write('rewardId: $rewardId, ')
          ..write('relatedEventId: $relatedEventId, ')
          ..write('createdAt: $createdAt, ')
          ..write('localDate: $localDate')
          ..write(')'))
        .toString();
  }
}

class $RedemptionsTable extends Redemptions
    with TableInfo<$RedemptionsTable, Redemption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RedemptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id)',
    ),
  );
  static const VerificationMeta _rewardIdMeta = const VerificationMeta(
    'rewardId',
  );
  @override
  late final GeneratedColumn<int> rewardId = GeneratedColumn<int>(
    'reward_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rewards (id)',
    ),
  );
  static const VerificationMeta _voucherNoMeta = const VerificationMeta(
    'voucherNo',
  );
  @override
  late final GeneratedColumn<String> voucherNo = GeneratedColumn<String>(
    'voucher_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<int> cost = GeneratedColumn<int>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sticker_events (id)',
    ),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deliveredAtMeta = const VerificationMeta(
    'deliveredAt',
  );
  @override
  late final GeneratedColumn<DateTime> deliveredAt = GeneratedColumn<DateTime>(
    'delivered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    rewardId,
    voucherNo,
    cost,
    eventId,
    createdAt,
    deliveredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'redemptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Redemption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('reward_id')) {
      context.handle(
        _rewardIdMeta,
        rewardId.isAcceptableOrUnknown(data['reward_id']!, _rewardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rewardIdMeta);
    }
    if (data.containsKey('voucher_no')) {
      context.handle(
        _voucherNoMeta,
        voucherNo.isAcceptableOrUnknown(data['voucher_no']!, _voucherNoMeta),
      );
    } else if (isInserting) {
      context.missing(_voucherNoMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('delivered_at')) {
      context.handle(
        _deliveredAtMeta,
        deliveredAt.isAcceptableOrUnknown(
          data['delivered_at']!,
          _deliveredAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Redemption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Redemption(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      rewardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward_id'],
      )!,
      voucherNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voucher_no'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deliveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}delivered_at'],
      ),
    );
  }

  @override
  $RedemptionsTable createAlias(String alias) {
    return $RedemptionsTable(attachedDatabase, alias);
  }
}

class Redemption extends DataClass implements Insertable<Redemption> {
  final int id;
  final int childId;
  final int rewardId;
  final String voucherNo;
  final int cost;
  final int eventId;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  const Redemption({
    required this.id,
    required this.childId,
    required this.rewardId,
    required this.voucherNo,
    required this.cost,
    required this.eventId,
    required this.createdAt,
    this.deliveredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['child_id'] = Variable<int>(childId);
    map['reward_id'] = Variable<int>(rewardId);
    map['voucher_no'] = Variable<String>(voucherNo);
    map['cost'] = Variable<int>(cost);
    map['event_id'] = Variable<int>(eventId);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deliveredAt != null) {
      map['delivered_at'] = Variable<DateTime>(deliveredAt);
    }
    return map;
  }

  RedemptionsCompanion toCompanion(bool nullToAbsent) {
    return RedemptionsCompanion(
      id: Value(id),
      childId: Value(childId),
      rewardId: Value(rewardId),
      voucherNo: Value(voucherNo),
      cost: Value(cost),
      eventId: Value(eventId),
      createdAt: Value(createdAt),
      deliveredAt: deliveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAt),
    );
  }

  factory Redemption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Redemption(
      id: serializer.fromJson<int>(json['id']),
      childId: serializer.fromJson<int>(json['childId']),
      rewardId: serializer.fromJson<int>(json['rewardId']),
      voucherNo: serializer.fromJson<String>(json['voucherNo']),
      cost: serializer.fromJson<int>(json['cost']),
      eventId: serializer.fromJson<int>(json['eventId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deliveredAt: serializer.fromJson<DateTime?>(json['deliveredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childId': serializer.toJson<int>(childId),
      'rewardId': serializer.toJson<int>(rewardId),
      'voucherNo': serializer.toJson<String>(voucherNo),
      'cost': serializer.toJson<int>(cost),
      'eventId': serializer.toJson<int>(eventId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deliveredAt': serializer.toJson<DateTime?>(deliveredAt),
    };
  }

  Redemption copyWith({
    int? id,
    int? childId,
    int? rewardId,
    String? voucherNo,
    int? cost,
    int? eventId,
    DateTime? createdAt,
    Value<DateTime?> deliveredAt = const Value.absent(),
  }) => Redemption(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    rewardId: rewardId ?? this.rewardId,
    voucherNo: voucherNo ?? this.voucherNo,
    cost: cost ?? this.cost,
    eventId: eventId ?? this.eventId,
    createdAt: createdAt ?? this.createdAt,
    deliveredAt: deliveredAt.present ? deliveredAt.value : this.deliveredAt,
  );
  Redemption copyWithCompanion(RedemptionsCompanion data) {
    return Redemption(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      rewardId: data.rewardId.present ? data.rewardId.value : this.rewardId,
      voucherNo: data.voucherNo.present ? data.voucherNo.value : this.voucherNo,
      cost: data.cost.present ? data.cost.value : this.cost,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deliveredAt: data.deliveredAt.present
          ? data.deliveredAt.value
          : this.deliveredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Redemption(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('rewardId: $rewardId, ')
          ..write('voucherNo: $voucherNo, ')
          ..write('cost: $cost, ')
          ..write('eventId: $eventId, ')
          ..write('createdAt: $createdAt, ')
          ..write('deliveredAt: $deliveredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    rewardId,
    voucherNo,
    cost,
    eventId,
    createdAt,
    deliveredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Redemption &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.rewardId == this.rewardId &&
          other.voucherNo == this.voucherNo &&
          other.cost == this.cost &&
          other.eventId == this.eventId &&
          other.createdAt == this.createdAt &&
          other.deliveredAt == this.deliveredAt);
}

class RedemptionsCompanion extends UpdateCompanion<Redemption> {
  final Value<int> id;
  final Value<int> childId;
  final Value<int> rewardId;
  final Value<String> voucherNo;
  final Value<int> cost;
  final Value<int> eventId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deliveredAt;
  const RedemptionsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.rewardId = const Value.absent(),
    this.voucherNo = const Value.absent(),
    this.cost = const Value.absent(),
    this.eventId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deliveredAt = const Value.absent(),
  });
  RedemptionsCompanion.insert({
    this.id = const Value.absent(),
    required int childId,
    required int rewardId,
    required String voucherNo,
    required int cost,
    required int eventId,
    this.createdAt = const Value.absent(),
    this.deliveredAt = const Value.absent(),
  }) : childId = Value(childId),
       rewardId = Value(rewardId),
       voucherNo = Value(voucherNo),
       cost = Value(cost),
       eventId = Value(eventId);
  static Insertable<Redemption> custom({
    Expression<int>? id,
    Expression<int>? childId,
    Expression<int>? rewardId,
    Expression<String>? voucherNo,
    Expression<int>? cost,
    Expression<int>? eventId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deliveredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (rewardId != null) 'reward_id': rewardId,
      if (voucherNo != null) 'voucher_no': voucherNo,
      if (cost != null) 'cost': cost,
      if (eventId != null) 'event_id': eventId,
      if (createdAt != null) 'created_at': createdAt,
      if (deliveredAt != null) 'delivered_at': deliveredAt,
    });
  }

  RedemptionsCompanion copyWith({
    Value<int>? id,
    Value<int>? childId,
    Value<int>? rewardId,
    Value<String>? voucherNo,
    Value<int>? cost,
    Value<int>? eventId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deliveredAt,
  }) {
    return RedemptionsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      rewardId: rewardId ?? this.rewardId,
      voucherNo: voucherNo ?? this.voucherNo,
      cost: cost ?? this.cost,
      eventId: eventId ?? this.eventId,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (rewardId.present) {
      map['reward_id'] = Variable<int>(rewardId.value);
    }
    if (voucherNo.present) {
      map['voucher_no'] = Variable<String>(voucherNo.value);
    }
    if (cost.present) {
      map['cost'] = Variable<int>(cost.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deliveredAt.present) {
      map['delivered_at'] = Variable<DateTime>(deliveredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RedemptionsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('rewardId: $rewardId, ')
          ..write('voucherNo: $voucherNo, ')
          ..write('cost: $cost, ')
          ..write('eventId: $eventId, ')
          ..write('createdAt: $createdAt, ')
          ..write('deliveredAt: $deliveredAt')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTable extends Routines with TableInfo<$RoutinesTable, Routine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timerMinutesMeta = const VerificationMeta(
    'timerMinutes',
  );
  @override
  late final GeneratedColumn<int> timerMinutes = GeneratedColumn<int>(
    'timer_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _daysMaskMeta = const VerificationMeta(
    'daysMask',
  );
  @override
  late final GeneratedColumn<int> daysMask = GeneratedColumn<int>(
    'days_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(127),
  );
  static const VerificationMeta _timeSlotMeta = const VerificationMeta(
    'timeSlot',
  );
  @override
  late final GeneratedColumn<String> timeSlot = GeneratedColumn<String>(
    'time_slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    title,
    iconKey,
    kind,
    timerMinutes,
    daysMask,
    timeSlot,
    sortOrder,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<Routine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('timer_minutes')) {
      context.handle(
        _timerMinutesMeta,
        timerMinutes.isAcceptableOrUnknown(
          data['timer_minutes']!,
          _timerMinutesMeta,
        ),
      );
    }
    if (data.containsKey('days_mask')) {
      context.handle(
        _daysMaskMeta,
        daysMask.isAcceptableOrUnknown(data['days_mask']!, _daysMaskMeta),
      );
    }
    if (data.containsKey('time_slot')) {
      context.handle(
        _timeSlotMeta,
        timeSlot.isAcceptableOrUnknown(data['time_slot']!, _timeSlotMeta),
      );
    } else if (isInserting) {
      context.missing(_timeSlotMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Routine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Routine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      timerMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timer_minutes'],
      ),
      daysMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_mask'],
      )!,
      timeSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_slot'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }
}

class Routine extends DataClass implements Insertable<Routine> {
  final int id;
  final int childId;
  final String title;
  final String iconKey;

  /// normal | parent_check | duolingo | diary | timer
  final String kind;
  final int? timerMinutes;

  /// 월~일을 비트로 저장 (월=1, 화=2, … 일=64). 127이면 매일.
  final int daysMask;

  /// morning | afternoon | evening
  final String timeSlot;
  final int sortOrder;
  final bool isActive;
  const Routine({
    required this.id,
    required this.childId,
    required this.title,
    required this.iconKey,
    required this.kind,
    this.timerMinutes,
    required this.daysMask,
    required this.timeSlot,
    required this.sortOrder,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['child_id'] = Variable<int>(childId);
    map['title'] = Variable<String>(title);
    map['icon_key'] = Variable<String>(iconKey);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || timerMinutes != null) {
      map['timer_minutes'] = Variable<int>(timerMinutes);
    }
    map['days_mask'] = Variable<int>(daysMask);
    map['time_slot'] = Variable<String>(timeSlot);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: Value(id),
      childId: Value(childId),
      title: Value(title),
      iconKey: Value(iconKey),
      kind: Value(kind),
      timerMinutes: timerMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(timerMinutes),
      daysMask: Value(daysMask),
      timeSlot: Value(timeSlot),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
    );
  }

  factory Routine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Routine(
      id: serializer.fromJson<int>(json['id']),
      childId: serializer.fromJson<int>(json['childId']),
      title: serializer.fromJson<String>(json['title']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      kind: serializer.fromJson<String>(json['kind']),
      timerMinutes: serializer.fromJson<int?>(json['timerMinutes']),
      daysMask: serializer.fromJson<int>(json['daysMask']),
      timeSlot: serializer.fromJson<String>(json['timeSlot']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childId': serializer.toJson<int>(childId),
      'title': serializer.toJson<String>(title),
      'iconKey': serializer.toJson<String>(iconKey),
      'kind': serializer.toJson<String>(kind),
      'timerMinutes': serializer.toJson<int?>(timerMinutes),
      'daysMask': serializer.toJson<int>(daysMask),
      'timeSlot': serializer.toJson<String>(timeSlot),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Routine copyWith({
    int? id,
    int? childId,
    String? title,
    String? iconKey,
    String? kind,
    Value<int?> timerMinutes = const Value.absent(),
    int? daysMask,
    String? timeSlot,
    int? sortOrder,
    bool? isActive,
  }) => Routine(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    title: title ?? this.title,
    iconKey: iconKey ?? this.iconKey,
    kind: kind ?? this.kind,
    timerMinutes: timerMinutes.present ? timerMinutes.value : this.timerMinutes,
    daysMask: daysMask ?? this.daysMask,
    timeSlot: timeSlot ?? this.timeSlot,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
  );
  Routine copyWithCompanion(RoutinesCompanion data) {
    return Routine(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      title: data.title.present ? data.title.value : this.title,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      kind: data.kind.present ? data.kind.value : this.kind,
      timerMinutes: data.timerMinutes.present
          ? data.timerMinutes.value
          : this.timerMinutes,
      daysMask: data.daysMask.present ? data.daysMask.value : this.daysMask,
      timeSlot: data.timeSlot.present ? data.timeSlot.value : this.timeSlot,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Routine(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('title: $title, ')
          ..write('iconKey: $iconKey, ')
          ..write('kind: $kind, ')
          ..write('timerMinutes: $timerMinutes, ')
          ..write('daysMask: $daysMask, ')
          ..write('timeSlot: $timeSlot, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    title,
    iconKey,
    kind,
    timerMinutes,
    daysMask,
    timeSlot,
    sortOrder,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Routine &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.title == this.title &&
          other.iconKey == this.iconKey &&
          other.kind == this.kind &&
          other.timerMinutes == this.timerMinutes &&
          other.daysMask == this.daysMask &&
          other.timeSlot == this.timeSlot &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive);
}

class RoutinesCompanion extends UpdateCompanion<Routine> {
  final Value<int> id;
  final Value<int> childId;
  final Value<String> title;
  final Value<String> iconKey;
  final Value<String> kind;
  final Value<int?> timerMinutes;
  final Value<int> daysMask;
  final Value<String> timeSlot;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  const RoutinesCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.title = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.kind = const Value.absent(),
    this.timerMinutes = const Value.absent(),
    this.daysMask = const Value.absent(),
    this.timeSlot = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  RoutinesCompanion.insert({
    this.id = const Value.absent(),
    required int childId,
    required String title,
    required String iconKey,
    required String kind,
    this.timerMinutes = const Value.absent(),
    this.daysMask = const Value.absent(),
    required String timeSlot,
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : childId = Value(childId),
       title = Value(title),
       iconKey = Value(iconKey),
       kind = Value(kind),
       timeSlot = Value(timeSlot);
  static Insertable<Routine> custom({
    Expression<int>? id,
    Expression<int>? childId,
    Expression<String>? title,
    Expression<String>? iconKey,
    Expression<String>? kind,
    Expression<int>? timerMinutes,
    Expression<int>? daysMask,
    Expression<String>? timeSlot,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (title != null) 'title': title,
      if (iconKey != null) 'icon_key': iconKey,
      if (kind != null) 'kind': kind,
      if (timerMinutes != null) 'timer_minutes': timerMinutes,
      if (daysMask != null) 'days_mask': daysMask,
      if (timeSlot != null) 'time_slot': timeSlot,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
    });
  }

  RoutinesCompanion copyWith({
    Value<int>? id,
    Value<int>? childId,
    Value<String>? title,
    Value<String>? iconKey,
    Value<String>? kind,
    Value<int?>? timerMinutes,
    Value<int>? daysMask,
    Value<String>? timeSlot,
    Value<int>? sortOrder,
    Value<bool>? isActive,
  }) {
    return RoutinesCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      title: title ?? this.title,
      iconKey: iconKey ?? this.iconKey,
      kind: kind ?? this.kind,
      timerMinutes: timerMinutes ?? this.timerMinutes,
      daysMask: daysMask ?? this.daysMask,
      timeSlot: timeSlot ?? this.timeSlot,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (timerMinutes.present) {
      map['timer_minutes'] = Variable<int>(timerMinutes.value);
    }
    if (daysMask.present) {
      map['days_mask'] = Variable<int>(daysMask.value);
    }
    if (timeSlot.present) {
      map['time_slot'] = Variable<String>(timeSlot.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('title: $title, ')
          ..write('iconKey: $iconKey, ')
          ..write('kind: $kind, ')
          ..write('timerMinutes: $timerMinutes, ')
          ..write('daysMask: $daysMask, ')
          ..write('timeSlot: $timeSlot, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $RoutineLogsTable extends RoutineLogs
    with TableInfo<$RoutineLogsTable, RoutineLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<int> routineId = GeneratedColumn<int>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id)',
    ),
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<DateTime> doneAt = GeneratedColumn<DateTime>(
    'done_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    localDate,
    doneAt,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('done_at')) {
      context.handle(
        _doneAtMeta,
        doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {routineId, localDate},
  ];
  @override
  RoutineLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_id'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      doneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}done_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $RoutineLogsTable createAlias(String alias) {
    return $RoutineLogsTable(attachedDatabase, alias);
  }
}

class RoutineLog extends DataClass implements Insertable<RoutineLog> {
  final int id;
  final int routineId;
  final String localDate;
  final DateTime doneAt;

  /// child | parent | auto
  final String source;
  const RoutineLog({
    required this.id,
    required this.routineId,
    required this.localDate,
    required this.doneAt,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['routine_id'] = Variable<int>(routineId);
    map['local_date'] = Variable<String>(localDate);
    map['done_at'] = Variable<DateTime>(doneAt);
    map['source'] = Variable<String>(source);
    return map;
  }

  RoutineLogsCompanion toCompanion(bool nullToAbsent) {
    return RoutineLogsCompanion(
      id: Value(id),
      routineId: Value(routineId),
      localDate: Value(localDate),
      doneAt: Value(doneAt),
      source: Value(source),
    );
  }

  factory RoutineLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineLog(
      id: serializer.fromJson<int>(json['id']),
      routineId: serializer.fromJson<int>(json['routineId']),
      localDate: serializer.fromJson<String>(json['localDate']),
      doneAt: serializer.fromJson<DateTime>(json['doneAt']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routineId': serializer.toJson<int>(routineId),
      'localDate': serializer.toJson<String>(localDate),
      'doneAt': serializer.toJson<DateTime>(doneAt),
      'source': serializer.toJson<String>(source),
    };
  }

  RoutineLog copyWith({
    int? id,
    int? routineId,
    String? localDate,
    DateTime? doneAt,
    String? source,
  }) => RoutineLog(
    id: id ?? this.id,
    routineId: routineId ?? this.routineId,
    localDate: localDate ?? this.localDate,
    doneAt: doneAt ?? this.doneAt,
    source: source ?? this.source,
  );
  RoutineLog copyWithCompanion(RoutineLogsCompanion data) {
    return RoutineLog(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineLog(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('localDate: $localDate, ')
          ..write('doneAt: $doneAt, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, routineId, localDate, doneAt, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineLog &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.localDate == this.localDate &&
          other.doneAt == this.doneAt &&
          other.source == this.source);
}

class RoutineLogsCompanion extends UpdateCompanion<RoutineLog> {
  final Value<int> id;
  final Value<int> routineId;
  final Value<String> localDate;
  final Value<DateTime> doneAt;
  final Value<String> source;
  const RoutineLogsCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.localDate = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.source = const Value.absent(),
  });
  RoutineLogsCompanion.insert({
    this.id = const Value.absent(),
    required int routineId,
    required String localDate,
    this.doneAt = const Value.absent(),
    required String source,
  }) : routineId = Value(routineId),
       localDate = Value(localDate),
       source = Value(source);
  static Insertable<RoutineLog> custom({
    Expression<int>? id,
    Expression<int>? routineId,
    Expression<String>? localDate,
    Expression<DateTime>? doneAt,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (localDate != null) 'local_date': localDate,
      if (doneAt != null) 'done_at': doneAt,
      if (source != null) 'source': source,
    });
  }

  RoutineLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? routineId,
    Value<String>? localDate,
    Value<DateTime>? doneAt,
    Value<String>? source,
  }) {
    return RoutineLogsCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      localDate: localDate ?? this.localDate,
      doneAt: doneAt ?? this.doneAt,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<int>(routineId.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<DateTime>(doneAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineLogsCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('localDate: $localDate, ')
          ..write('doneAt: $doneAt, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $DailyClearsTable extends DailyClears
    with TableInfo<$DailyClearsTable, DailyClear> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyClearsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id)',
    ),
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clearedAtMeta = const VerificationMeta(
    'clearedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clearedAt = GeneratedColumn<DateTime>(
    'cleared_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _bonusStatusMeta = const VerificationMeta(
    'bonusStatus',
  );
  @override
  late final GeneratedColumn<String> bonusStatus = GeneratedColumn<String>(
    'bonus_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    localDate,
    clearedAt,
    bonusStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_clears';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyClear> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('cleared_at')) {
      context.handle(
        _clearedAtMeta,
        clearedAt.isAcceptableOrUnknown(data['cleared_at']!, _clearedAtMeta),
      );
    }
    if (data.containsKey('bonus_status')) {
      context.handle(
        _bonusStatusMeta,
        bonusStatus.isAcceptableOrUnknown(
          data['bonus_status']!,
          _bonusStatusMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {childId, localDate},
  ];
  @override
  DailyClear map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyClear(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      clearedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cleared_at'],
      )!,
      bonusStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bonus_status'],
      )!,
    );
  }

  @override
  $DailyClearsTable createAlias(String alias) {
    return $DailyClearsTable(attachedDatabase, alias);
  }
}

class DailyClear extends DataClass implements Insertable<DailyClear> {
  final int id;
  final int childId;
  final String localDate;
  final DateTime clearedAt;

  /// none | pending | granted
  final String bonusStatus;
  const DailyClear({
    required this.id,
    required this.childId,
    required this.localDate,
    required this.clearedAt,
    required this.bonusStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['child_id'] = Variable<int>(childId);
    map['local_date'] = Variable<String>(localDate);
    map['cleared_at'] = Variable<DateTime>(clearedAt);
    map['bonus_status'] = Variable<String>(bonusStatus);
    return map;
  }

  DailyClearsCompanion toCompanion(bool nullToAbsent) {
    return DailyClearsCompanion(
      id: Value(id),
      childId: Value(childId),
      localDate: Value(localDate),
      clearedAt: Value(clearedAt),
      bonusStatus: Value(bonusStatus),
    );
  }

  factory DailyClear.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyClear(
      id: serializer.fromJson<int>(json['id']),
      childId: serializer.fromJson<int>(json['childId']),
      localDate: serializer.fromJson<String>(json['localDate']),
      clearedAt: serializer.fromJson<DateTime>(json['clearedAt']),
      bonusStatus: serializer.fromJson<String>(json['bonusStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childId': serializer.toJson<int>(childId),
      'localDate': serializer.toJson<String>(localDate),
      'clearedAt': serializer.toJson<DateTime>(clearedAt),
      'bonusStatus': serializer.toJson<String>(bonusStatus),
    };
  }

  DailyClear copyWith({
    int? id,
    int? childId,
    String? localDate,
    DateTime? clearedAt,
    String? bonusStatus,
  }) => DailyClear(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    localDate: localDate ?? this.localDate,
    clearedAt: clearedAt ?? this.clearedAt,
    bonusStatus: bonusStatus ?? this.bonusStatus,
  );
  DailyClear copyWithCompanion(DailyClearsCompanion data) {
    return DailyClear(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      clearedAt: data.clearedAt.present ? data.clearedAt.value : this.clearedAt,
      bonusStatus: data.bonusStatus.present
          ? data.bonusStatus.value
          : this.bonusStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyClear(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('localDate: $localDate, ')
          ..write('clearedAt: $clearedAt, ')
          ..write('bonusStatus: $bonusStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, childId, localDate, clearedAt, bonusStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyClear &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.localDate == this.localDate &&
          other.clearedAt == this.clearedAt &&
          other.bonusStatus == this.bonusStatus);
}

class DailyClearsCompanion extends UpdateCompanion<DailyClear> {
  final Value<int> id;
  final Value<int> childId;
  final Value<String> localDate;
  final Value<DateTime> clearedAt;
  final Value<String> bonusStatus;
  const DailyClearsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.localDate = const Value.absent(),
    this.clearedAt = const Value.absent(),
    this.bonusStatus = const Value.absent(),
  });
  DailyClearsCompanion.insert({
    this.id = const Value.absent(),
    required int childId,
    required String localDate,
    this.clearedAt = const Value.absent(),
    this.bonusStatus = const Value.absent(),
  }) : childId = Value(childId),
       localDate = Value(localDate);
  static Insertable<DailyClear> custom({
    Expression<int>? id,
    Expression<int>? childId,
    Expression<String>? localDate,
    Expression<DateTime>? clearedAt,
    Expression<String>? bonusStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (localDate != null) 'local_date': localDate,
      if (clearedAt != null) 'cleared_at': clearedAt,
      if (bonusStatus != null) 'bonus_status': bonusStatus,
    });
  }

  DailyClearsCompanion copyWith({
    Value<int>? id,
    Value<int>? childId,
    Value<String>? localDate,
    Value<DateTime>? clearedAt,
    Value<String>? bonusStatus,
  }) {
    return DailyClearsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      localDate: localDate ?? this.localDate,
      clearedAt: clearedAt ?? this.clearedAt,
      bonusStatus: bonusStatus ?? this.bonusStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (clearedAt.present) {
      map['cleared_at'] = Variable<DateTime>(clearedAt.value);
    }
    if (bonusStatus.present) {
      map['bonus_status'] = Variable<String>(bonusStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyClearsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('localDate: $localDate, ')
          ..write('clearedAt: $clearedAt, ')
          ..write('bonusStatus: $bonusStatus')
          ..write(')'))
        .toString();
  }
}

class $DiaryEntriesTable extends DiaryEntries
    with TableInfo<$DiaryEntriesTable, DiaryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id)',
    ),
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _weatherMeta = const VerificationMeta(
    'weather',
  );
  @override
  late final GeneratedColumn<String> weather = GeneratedColumn<String>(
    'weather',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _parentReplyMeta = const VerificationMeta(
    'parentReply',
  );
  @override
  late final GeneratedColumn<String> parentReply = GeneratedColumn<String>(
    'parent_reply',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentRepliedAtMeta = const VerificationMeta(
    'parentRepliedAt',
  );
  @override
  late final GeneratedColumn<DateTime> parentRepliedAt =
      GeneratedColumn<DateTime>(
        'parent_replied_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    localDate,
    weather,
    mood,
    title,
    body,
    parentReply,
    parentRepliedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiaryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('weather')) {
      context.handle(
        _weatherMeta,
        weather.isAcceptableOrUnknown(data['weather']!, _weatherMeta),
      );
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('parent_reply')) {
      context.handle(
        _parentReplyMeta,
        parentReply.isAcceptableOrUnknown(
          data['parent_reply']!,
          _parentReplyMeta,
        ),
      );
    }
    if (data.containsKey('parent_replied_at')) {
      context.handle(
        _parentRepliedAtMeta,
        parentRepliedAt.isAcceptableOrUnknown(
          data['parent_replied_at']!,
          _parentRepliedAtMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiaryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiaryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      weather: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather'],
      ),
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      parentReply: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_reply'],
      ),
      parentRepliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}parent_replied_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DiaryEntriesTable createAlias(String alias) {
    return $DiaryEntriesTable(attachedDatabase, alias);
  }
}

class DiaryEntry extends DataClass implements Insertable<DiaryEntry> {
  final int id;
  final int childId;
  final String localDate;
  final String? weather;

  /// 1(화남)~5(최고)
  final int? mood;
  final String title;
  final String body;
  final String? parentReply;
  final DateTime? parentRepliedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DiaryEntry({
    required this.id,
    required this.childId,
    required this.localDate,
    this.weather,
    this.mood,
    required this.title,
    required this.body,
    this.parentReply,
    this.parentRepliedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['child_id'] = Variable<int>(childId);
    map['local_date'] = Variable<String>(localDate);
    if (!nullToAbsent || weather != null) {
      map['weather'] = Variable<String>(weather);
    }
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<int>(mood);
    }
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || parentReply != null) {
      map['parent_reply'] = Variable<String>(parentReply);
    }
    if (!nullToAbsent || parentRepliedAt != null) {
      map['parent_replied_at'] = Variable<DateTime>(parentRepliedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DiaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return DiaryEntriesCompanion(
      id: Value(id),
      childId: Value(childId),
      localDate: Value(localDate),
      weather: weather == null && nullToAbsent
          ? const Value.absent()
          : Value(weather),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      title: Value(title),
      body: Value(body),
      parentReply: parentReply == null && nullToAbsent
          ? const Value.absent()
          : Value(parentReply),
      parentRepliedAt: parentRepliedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(parentRepliedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DiaryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiaryEntry(
      id: serializer.fromJson<int>(json['id']),
      childId: serializer.fromJson<int>(json['childId']),
      localDate: serializer.fromJson<String>(json['localDate']),
      weather: serializer.fromJson<String?>(json['weather']),
      mood: serializer.fromJson<int?>(json['mood']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      parentReply: serializer.fromJson<String?>(json['parentReply']),
      parentRepliedAt: serializer.fromJson<DateTime?>(json['parentRepliedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childId': serializer.toJson<int>(childId),
      'localDate': serializer.toJson<String>(localDate),
      'weather': serializer.toJson<String?>(weather),
      'mood': serializer.toJson<int?>(mood),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'parentReply': serializer.toJson<String?>(parentReply),
      'parentRepliedAt': serializer.toJson<DateTime?>(parentRepliedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DiaryEntry copyWith({
    int? id,
    int? childId,
    String? localDate,
    Value<String?> weather = const Value.absent(),
    Value<int?> mood = const Value.absent(),
    String? title,
    String? body,
    Value<String?> parentReply = const Value.absent(),
    Value<DateTime?> parentRepliedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DiaryEntry(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    localDate: localDate ?? this.localDate,
    weather: weather.present ? weather.value : this.weather,
    mood: mood.present ? mood.value : this.mood,
    title: title ?? this.title,
    body: body ?? this.body,
    parentReply: parentReply.present ? parentReply.value : this.parentReply,
    parentRepliedAt: parentRepliedAt.present
        ? parentRepliedAt.value
        : this.parentRepliedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DiaryEntry copyWithCompanion(DiaryEntriesCompanion data) {
    return DiaryEntry(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      weather: data.weather.present ? data.weather.value : this.weather,
      mood: data.mood.present ? data.mood.value : this.mood,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      parentReply: data.parentReply.present
          ? data.parentReply.value
          : this.parentReply,
      parentRepliedAt: data.parentRepliedAt.present
          ? data.parentRepliedAt.value
          : this.parentRepliedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntry(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('localDate: $localDate, ')
          ..write('weather: $weather, ')
          ..write('mood: $mood, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('parentReply: $parentReply, ')
          ..write('parentRepliedAt: $parentRepliedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    localDate,
    weather,
    mood,
    title,
    body,
    parentReply,
    parentRepliedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiaryEntry &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.localDate == this.localDate &&
          other.weather == this.weather &&
          other.mood == this.mood &&
          other.title == this.title &&
          other.body == this.body &&
          other.parentReply == this.parentReply &&
          other.parentRepliedAt == this.parentRepliedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DiaryEntriesCompanion extends UpdateCompanion<DiaryEntry> {
  final Value<int> id;
  final Value<int> childId;
  final Value<String> localDate;
  final Value<String?> weather;
  final Value<int?> mood;
  final Value<String> title;
  final Value<String> body;
  final Value<String?> parentReply;
  final Value<DateTime?> parentRepliedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DiaryEntriesCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.localDate = const Value.absent(),
    this.weather = const Value.absent(),
    this.mood = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.parentReply = const Value.absent(),
    this.parentRepliedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DiaryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int childId,
    required String localDate,
    this.weather = const Value.absent(),
    this.mood = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.parentReply = const Value.absent(),
    this.parentRepliedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : childId = Value(childId),
       localDate = Value(localDate);
  static Insertable<DiaryEntry> custom({
    Expression<int>? id,
    Expression<int>? childId,
    Expression<String>? localDate,
    Expression<String>? weather,
    Expression<int>? mood,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? parentReply,
    Expression<DateTime>? parentRepliedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (localDate != null) 'local_date': localDate,
      if (weather != null) 'weather': weather,
      if (mood != null) 'mood': mood,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (parentReply != null) 'parent_reply': parentReply,
      if (parentRepliedAt != null) 'parent_replied_at': parentRepliedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DiaryEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? childId,
    Value<String>? localDate,
    Value<String?>? weather,
    Value<int?>? mood,
    Value<String>? title,
    Value<String>? body,
    Value<String?>? parentReply,
    Value<DateTime?>? parentRepliedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DiaryEntriesCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      localDate: localDate ?? this.localDate,
      weather: weather ?? this.weather,
      mood: mood ?? this.mood,
      title: title ?? this.title,
      body: body ?? this.body,
      parentReply: parentReply ?? this.parentReply,
      parentRepliedAt: parentRepliedAt ?? this.parentRepliedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (weather.present) {
      map['weather'] = Variable<String>(weather.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (parentReply.present) {
      map['parent_reply'] = Variable<String>(parentReply.value);
    }
    if (parentRepliedAt.present) {
      map['parent_replied_at'] = Variable<DateTime>(parentRepliedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('localDate: $localDate, ')
          ..write('weather: $weather, ')
          ..write('mood: $mood, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('parentReply: $parentReply, ')
          ..write('parentRepliedAt: $parentRepliedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BadgesTable extends Badges with TableInfo<$BadgesTable, Badge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BadgesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleJsonMeta = const VerificationMeta(
    'ruleJson',
  );
  @override
  late final GeneratedColumn<String> ruleJson = GeneratedColumn<String>(
    'rule_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _bonusAmountMeta = const VerificationMeta(
    'bonusAmount',
  );
  @override
  late final GeneratedColumn<int> bonusAmount = GeneratedColumn<int>(
    'bonus_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    category,
    name,
    iconKey,
    colorValue,
    ruleJson,
    isHidden,
    isActive,
    bonusAmount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'badges';
  @override
  VerificationContext validateIntegrity(
    Insertable<Badge> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('rule_json')) {
      context.handle(
        _ruleJsonMeta,
        ruleJson.isAcceptableOrUnknown(data['rule_json']!, _ruleJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleJsonMeta);
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('bonus_amount')) {
      context.handle(
        _bonusAmountMeta,
        bonusAmount.isAcceptableOrUnknown(
          data['bonus_amount']!,
          _bonusAmountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  Badge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Badge(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      ruleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_json'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      bonusAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bonus_amount'],
      )!,
    );
  }

  @override
  $BadgesTable createAlias(String alias) {
    return $BadgesTable(attachedDatabase, alias);
  }
}

class Badge extends DataClass implements Insertable<Badge> {
  /// 배지 식별자 (예: first_sticker)
  final String code;
  final String category;
  final String name;
  final String iconKey;
  final int colorValue;

  /// 조건을 JSON 문자열로 저장한다. 판정 로직은 P8에서 만든다.
  final String ruleJson;
  final bool isHidden;
  final bool isActive;
  final int bonusAmount;
  const Badge({
    required this.code,
    required this.category,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    required this.ruleJson,
    required this.isHidden,
    required this.isActive,
    required this.bonusAmount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['category'] = Variable<String>(category);
    map['name'] = Variable<String>(name);
    map['icon_key'] = Variable<String>(iconKey);
    map['color_value'] = Variable<int>(colorValue);
    map['rule_json'] = Variable<String>(ruleJson);
    map['is_hidden'] = Variable<bool>(isHidden);
    map['is_active'] = Variable<bool>(isActive);
    map['bonus_amount'] = Variable<int>(bonusAmount);
    return map;
  }

  BadgesCompanion toCompanion(bool nullToAbsent) {
    return BadgesCompanion(
      code: Value(code),
      category: Value(category),
      name: Value(name),
      iconKey: Value(iconKey),
      colorValue: Value(colorValue),
      ruleJson: Value(ruleJson),
      isHidden: Value(isHidden),
      isActive: Value(isActive),
      bonusAmount: Value(bonusAmount),
    );
  }

  factory Badge.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Badge(
      code: serializer.fromJson<String>(json['code']),
      category: serializer.fromJson<String>(json['category']),
      name: serializer.fromJson<String>(json['name']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      ruleJson: serializer.fromJson<String>(json['ruleJson']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      bonusAmount: serializer.fromJson<int>(json['bonusAmount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'category': serializer.toJson<String>(category),
      'name': serializer.toJson<String>(name),
      'iconKey': serializer.toJson<String>(iconKey),
      'colorValue': serializer.toJson<int>(colorValue),
      'ruleJson': serializer.toJson<String>(ruleJson),
      'isHidden': serializer.toJson<bool>(isHidden),
      'isActive': serializer.toJson<bool>(isActive),
      'bonusAmount': serializer.toJson<int>(bonusAmount),
    };
  }

  Badge copyWith({
    String? code,
    String? category,
    String? name,
    String? iconKey,
    int? colorValue,
    String? ruleJson,
    bool? isHidden,
    bool? isActive,
    int? bonusAmount,
  }) => Badge(
    code: code ?? this.code,
    category: category ?? this.category,
    name: name ?? this.name,
    iconKey: iconKey ?? this.iconKey,
    colorValue: colorValue ?? this.colorValue,
    ruleJson: ruleJson ?? this.ruleJson,
    isHidden: isHidden ?? this.isHidden,
    isActive: isActive ?? this.isActive,
    bonusAmount: bonusAmount ?? this.bonusAmount,
  );
  Badge copyWithCompanion(BadgesCompanion data) {
    return Badge(
      code: data.code.present ? data.code.value : this.code,
      category: data.category.present ? data.category.value : this.category,
      name: data.name.present ? data.name.value : this.name,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      ruleJson: data.ruleJson.present ? data.ruleJson.value : this.ruleJson,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      bonusAmount: data.bonusAmount.present
          ? data.bonusAmount.value
          : this.bonusAmount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Badge(')
          ..write('code: $code, ')
          ..write('category: $category, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorValue: $colorValue, ')
          ..write('ruleJson: $ruleJson, ')
          ..write('isHidden: $isHidden, ')
          ..write('isActive: $isActive, ')
          ..write('bonusAmount: $bonusAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    code,
    category,
    name,
    iconKey,
    colorValue,
    ruleJson,
    isHidden,
    isActive,
    bonusAmount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Badge &&
          other.code == this.code &&
          other.category == this.category &&
          other.name == this.name &&
          other.iconKey == this.iconKey &&
          other.colorValue == this.colorValue &&
          other.ruleJson == this.ruleJson &&
          other.isHidden == this.isHidden &&
          other.isActive == this.isActive &&
          other.bonusAmount == this.bonusAmount);
}

class BadgesCompanion extends UpdateCompanion<Badge> {
  final Value<String> code;
  final Value<String> category;
  final Value<String> name;
  final Value<String> iconKey;
  final Value<int> colorValue;
  final Value<String> ruleJson;
  final Value<bool> isHidden;
  final Value<bool> isActive;
  final Value<int> bonusAmount;
  final Value<int> rowid;
  const BadgesCompanion({
    this.code = const Value.absent(),
    this.category = const Value.absent(),
    this.name = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.ruleJson = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.isActive = const Value.absent(),
    this.bonusAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BadgesCompanion.insert({
    required String code,
    required String category,
    required String name,
    required String iconKey,
    required int colorValue,
    required String ruleJson,
    this.isHidden = const Value.absent(),
    this.isActive = const Value.absent(),
    this.bonusAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       category = Value(category),
       name = Value(name),
       iconKey = Value(iconKey),
       colorValue = Value(colorValue),
       ruleJson = Value(ruleJson);
  static Insertable<Badge> custom({
    Expression<String>? code,
    Expression<String>? category,
    Expression<String>? name,
    Expression<String>? iconKey,
    Expression<int>? colorValue,
    Expression<String>? ruleJson,
    Expression<bool>? isHidden,
    Expression<bool>? isActive,
    Expression<int>? bonusAmount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (category != null) 'category': category,
      if (name != null) 'name': name,
      if (iconKey != null) 'icon_key': iconKey,
      if (colorValue != null) 'color_value': colorValue,
      if (ruleJson != null) 'rule_json': ruleJson,
      if (isHidden != null) 'is_hidden': isHidden,
      if (isActive != null) 'is_active': isActive,
      if (bonusAmount != null) 'bonus_amount': bonusAmount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BadgesCompanion copyWith({
    Value<String>? code,
    Value<String>? category,
    Value<String>? name,
    Value<String>? iconKey,
    Value<int>? colorValue,
    Value<String>? ruleJson,
    Value<bool>? isHidden,
    Value<bool>? isActive,
    Value<int>? bonusAmount,
    Value<int>? rowid,
  }) {
    return BadgesCompanion(
      code: code ?? this.code,
      category: category ?? this.category,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      ruleJson: ruleJson ?? this.ruleJson,
      isHidden: isHidden ?? this.isHidden,
      isActive: isActive ?? this.isActive,
      bonusAmount: bonusAmount ?? this.bonusAmount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (ruleJson.present) {
      map['rule_json'] = Variable<String>(ruleJson.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (bonusAmount.present) {
      map['bonus_amount'] = Variable<int>(bonusAmount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BadgesCompanion(')
          ..write('code: $code, ')
          ..write('category: $category, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorValue: $colorValue, ')
          ..write('ruleJson: $ruleJson, ')
          ..write('isHidden: $isHidden, ')
          ..write('isActive: $isActive, ')
          ..write('bonusAmount: $bonusAmount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BadgeAwardsTable extends BadgeAwards
    with TableInfo<$BadgeAwardsTable, BadgeAward> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BadgeAwardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _badgeCodeMeta = const VerificationMeta(
    'badgeCode',
  );
  @override
  late final GeneratedColumn<String> badgeCode = GeneratedColumn<String>(
    'badge_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES badges (code)',
    ),
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id)',
    ),
  );
  static const VerificationMeta _awardedAtMeta = const VerificationMeta(
    'awardedAt',
  );
  @override
  late final GeneratedColumn<DateTime> awardedAt = GeneratedColumn<DateTime>(
    'awarded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _eventRefMeta = const VerificationMeta(
    'eventRef',
  );
  @override
  late final GeneratedColumn<String> eventRef = GeneratedColumn<String>(
    'event_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    badgeCode,
    childId,
    awardedAt,
    eventRef,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'badge_awards';
  @override
  VerificationContext validateIntegrity(
    Insertable<BadgeAward> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('badge_code')) {
      context.handle(
        _badgeCodeMeta,
        badgeCode.isAcceptableOrUnknown(data['badge_code']!, _badgeCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_badgeCodeMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('awarded_at')) {
      context.handle(
        _awardedAtMeta,
        awardedAt.isAcceptableOrUnknown(data['awarded_at']!, _awardedAtMeta),
      );
    }
    if (data.containsKey('event_ref')) {
      context.handle(
        _eventRefMeta,
        eventRef.isAcceptableOrUnknown(data['event_ref']!, _eventRefMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {badgeCode, childId},
  ];
  @override
  BadgeAward map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BadgeAward(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      badgeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}badge_code'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      awardedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}awarded_at'],
      )!,
      eventRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_ref'],
      ),
    );
  }

  @override
  $BadgeAwardsTable createAlias(String alias) {
    return $BadgeAwardsTable(attachedDatabase, alias);
  }
}

class BadgeAward extends DataClass implements Insertable<BadgeAward> {
  final int id;
  final String badgeCode;
  final int childId;
  final DateTime awardedAt;
  final String? eventRef;
  const BadgeAward({
    required this.id,
    required this.badgeCode,
    required this.childId,
    required this.awardedAt,
    this.eventRef,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['badge_code'] = Variable<String>(badgeCode);
    map['child_id'] = Variable<int>(childId);
    map['awarded_at'] = Variable<DateTime>(awardedAt);
    if (!nullToAbsent || eventRef != null) {
      map['event_ref'] = Variable<String>(eventRef);
    }
    return map;
  }

  BadgeAwardsCompanion toCompanion(bool nullToAbsent) {
    return BadgeAwardsCompanion(
      id: Value(id),
      badgeCode: Value(badgeCode),
      childId: Value(childId),
      awardedAt: Value(awardedAt),
      eventRef: eventRef == null && nullToAbsent
          ? const Value.absent()
          : Value(eventRef),
    );
  }

  factory BadgeAward.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BadgeAward(
      id: serializer.fromJson<int>(json['id']),
      badgeCode: serializer.fromJson<String>(json['badgeCode']),
      childId: serializer.fromJson<int>(json['childId']),
      awardedAt: serializer.fromJson<DateTime>(json['awardedAt']),
      eventRef: serializer.fromJson<String?>(json['eventRef']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'badgeCode': serializer.toJson<String>(badgeCode),
      'childId': serializer.toJson<int>(childId),
      'awardedAt': serializer.toJson<DateTime>(awardedAt),
      'eventRef': serializer.toJson<String?>(eventRef),
    };
  }

  BadgeAward copyWith({
    int? id,
    String? badgeCode,
    int? childId,
    DateTime? awardedAt,
    Value<String?> eventRef = const Value.absent(),
  }) => BadgeAward(
    id: id ?? this.id,
    badgeCode: badgeCode ?? this.badgeCode,
    childId: childId ?? this.childId,
    awardedAt: awardedAt ?? this.awardedAt,
    eventRef: eventRef.present ? eventRef.value : this.eventRef,
  );
  BadgeAward copyWithCompanion(BadgeAwardsCompanion data) {
    return BadgeAward(
      id: data.id.present ? data.id.value : this.id,
      badgeCode: data.badgeCode.present ? data.badgeCode.value : this.badgeCode,
      childId: data.childId.present ? data.childId.value : this.childId,
      awardedAt: data.awardedAt.present ? data.awardedAt.value : this.awardedAt,
      eventRef: data.eventRef.present ? data.eventRef.value : this.eventRef,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BadgeAward(')
          ..write('id: $id, ')
          ..write('badgeCode: $badgeCode, ')
          ..write('childId: $childId, ')
          ..write('awardedAt: $awardedAt, ')
          ..write('eventRef: $eventRef')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, badgeCode, childId, awardedAt, eventRef);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BadgeAward &&
          other.id == this.id &&
          other.badgeCode == this.badgeCode &&
          other.childId == this.childId &&
          other.awardedAt == this.awardedAt &&
          other.eventRef == this.eventRef);
}

class BadgeAwardsCompanion extends UpdateCompanion<BadgeAward> {
  final Value<int> id;
  final Value<String> badgeCode;
  final Value<int> childId;
  final Value<DateTime> awardedAt;
  final Value<String?> eventRef;
  const BadgeAwardsCompanion({
    this.id = const Value.absent(),
    this.badgeCode = const Value.absent(),
    this.childId = const Value.absent(),
    this.awardedAt = const Value.absent(),
    this.eventRef = const Value.absent(),
  });
  BadgeAwardsCompanion.insert({
    this.id = const Value.absent(),
    required String badgeCode,
    required int childId,
    this.awardedAt = const Value.absent(),
    this.eventRef = const Value.absent(),
  }) : badgeCode = Value(badgeCode),
       childId = Value(childId);
  static Insertable<BadgeAward> custom({
    Expression<int>? id,
    Expression<String>? badgeCode,
    Expression<int>? childId,
    Expression<DateTime>? awardedAt,
    Expression<String>? eventRef,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (badgeCode != null) 'badge_code': badgeCode,
      if (childId != null) 'child_id': childId,
      if (awardedAt != null) 'awarded_at': awardedAt,
      if (eventRef != null) 'event_ref': eventRef,
    });
  }

  BadgeAwardsCompanion copyWith({
    Value<int>? id,
    Value<String>? badgeCode,
    Value<int>? childId,
    Value<DateTime>? awardedAt,
    Value<String?>? eventRef,
  }) {
    return BadgeAwardsCompanion(
      id: id ?? this.id,
      badgeCode: badgeCode ?? this.badgeCode,
      childId: childId ?? this.childId,
      awardedAt: awardedAt ?? this.awardedAt,
      eventRef: eventRef ?? this.eventRef,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (badgeCode.present) {
      map['badge_code'] = Variable<String>(badgeCode.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (awardedAt.present) {
      map['awarded_at'] = Variable<DateTime>(awardedAt.value);
    }
    if (eventRef.present) {
      map['event_ref'] = Variable<String>(eventRef.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BadgeAwardsCompanion(')
          ..write('id: $id, ')
          ..write('badgeCode: $badgeCode, ')
          ..write('childId: $childId, ')
          ..write('awardedAt: $awardedAt, ')
          ..write('eventRef: $eventRef')
          ..write(')'))
        .toString();
  }
}

class $ReportCommentsTable extends ReportComments
    with TableInfo<$ReportCommentsTable, ReportComment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportCommentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id)',
    ),
  );
  static const VerificationMeta _periodTypeMeta = const VerificationMeta(
    'periodType',
  );
  @override
  late final GeneratedColumn<String> periodType = GeneratedColumn<String>(
    'period_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodKeyMeta = const VerificationMeta(
    'periodKey',
  );
  @override
  late final GeneratedColumn<String> periodKey = GeneratedColumn<String>(
    'period_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    periodType,
    periodKey,
    content,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'report_comments';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReportComment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('period_type')) {
      context.handle(
        _periodTypeMeta,
        periodType.isAcceptableOrUnknown(data['period_type']!, _periodTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_periodTypeMeta);
    }
    if (data.containsKey('period_key')) {
      context.handle(
        _periodKeyMeta,
        periodKey.isAcceptableOrUnknown(data['period_key']!, _periodKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_periodKeyMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['text']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReportComment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReportComment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      periodType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_type'],
      )!,
      periodKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_key'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ReportCommentsTable createAlias(String alias) {
    return $ReportCommentsTable(attachedDatabase, alias);
  }
}

class ReportComment extends DataClass implements Insertable<ReportComment> {
  final int id;
  final int childId;

  /// week | month | all
  final String periodType;
  final String periodKey;
  final String content;
  final DateTime updatedAt;
  const ReportComment({
    required this.id,
    required this.childId,
    required this.periodType,
    required this.periodKey,
    required this.content,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['child_id'] = Variable<int>(childId);
    map['period_type'] = Variable<String>(periodType);
    map['period_key'] = Variable<String>(periodKey);
    map['text'] = Variable<String>(content);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReportCommentsCompanion toCompanion(bool nullToAbsent) {
    return ReportCommentsCompanion(
      id: Value(id),
      childId: Value(childId),
      periodType: Value(periodType),
      periodKey: Value(periodKey),
      content: Value(content),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReportComment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReportComment(
      id: serializer.fromJson<int>(json['id']),
      childId: serializer.fromJson<int>(json['childId']),
      periodType: serializer.fromJson<String>(json['periodType']),
      periodKey: serializer.fromJson<String>(json['periodKey']),
      content: serializer.fromJson<String>(json['content']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childId': serializer.toJson<int>(childId),
      'periodType': serializer.toJson<String>(periodType),
      'periodKey': serializer.toJson<String>(periodKey),
      'content': serializer.toJson<String>(content),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReportComment copyWith({
    int? id,
    int? childId,
    String? periodType,
    String? periodKey,
    String? content,
    DateTime? updatedAt,
  }) => ReportComment(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    periodType: periodType ?? this.periodType,
    periodKey: periodKey ?? this.periodKey,
    content: content ?? this.content,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReportComment copyWithCompanion(ReportCommentsCompanion data) {
    return ReportComment(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      periodType: data.periodType.present
          ? data.periodType.value
          : this.periodType,
      periodKey: data.periodKey.present ? data.periodKey.value : this.periodKey,
      content: data.content.present ? data.content.value : this.content,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReportComment(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('periodType: $periodType, ')
          ..write('periodKey: $periodKey, ')
          ..write('content: $content, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, childId, periodType, periodKey, content, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReportComment &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.periodType == this.periodType &&
          other.periodKey == this.periodKey &&
          other.content == this.content &&
          other.updatedAt == this.updatedAt);
}

class ReportCommentsCompanion extends UpdateCompanion<ReportComment> {
  final Value<int> id;
  final Value<int> childId;
  final Value<String> periodType;
  final Value<String> periodKey;
  final Value<String> content;
  final Value<DateTime> updatedAt;
  const ReportCommentsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.periodType = const Value.absent(),
    this.periodKey = const Value.absent(),
    this.content = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ReportCommentsCompanion.insert({
    this.id = const Value.absent(),
    required int childId,
    required String periodType,
    required String periodKey,
    required String content,
    this.updatedAt = const Value.absent(),
  }) : childId = Value(childId),
       periodType = Value(periodType),
       periodKey = Value(periodKey),
       content = Value(content);
  static Insertable<ReportComment> custom({
    Expression<int>? id,
    Expression<int>? childId,
    Expression<String>? periodType,
    Expression<String>? periodKey,
    Expression<String>? content,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (periodType != null) 'period_type': periodType,
      if (periodKey != null) 'period_key': periodKey,
      if (content != null) 'text': content,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ReportCommentsCompanion copyWith({
    Value<int>? id,
    Value<int>? childId,
    Value<String>? periodType,
    Value<String>? periodKey,
    Value<String>? content,
    Value<DateTime>? updatedAt,
  }) {
    return ReportCommentsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      periodType: periodType ?? this.periodType,
      periodKey: periodKey ?? this.periodKey,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (periodType.present) {
      map['period_type'] = Variable<String>(periodType.value);
    }
    if (periodKey.present) {
      map['period_key'] = Variable<String>(periodKey.value);
    }
    if (content.present) {
      map['text'] = Variable<String>(content.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportCommentsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('periodType: $periodType, ')
          ..write('periodKey: $periodKey, ')
          ..write('content: $content, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DuolingoSnapshotsTable extends DuolingoSnapshots
    with TableInfo<$DuolingoSnapshotsTable, DuolingoSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DuolingoSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id)',
    ),
  );
  static const VerificationMeta _checkedAtMeta = const VerificationMeta(
    'checkedAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkedAt = GeneratedColumn<DateTime>(
    'checked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _totalXpMeta = const VerificationMeta(
    'totalXp',
  );
  @override
  late final GeneratedColumn<int> totalXp = GeneratedColumn<int>(
    'total_xp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _streakMeta = const VerificationMeta('streak');
  @override
  late final GeneratedColumn<int> streak = GeneratedColumn<int>(
    'streak',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _streakEndDateMeta = const VerificationMeta(
    'streakEndDate',
  );
  @override
  late final GeneratedColumn<String> streakEndDate = GeneratedColumn<String>(
    'streak_end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _okMeta = const VerificationMeta('ok');
  @override
  late final GeneratedColumn<bool> ok = GeneratedColumn<bool>(
    'ok',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ok" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    checkedAt,
    totalXp,
    streak,
    streakEndDate,
    method,
    ok,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'duolingo_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<DuolingoSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('checked_at')) {
      context.handle(
        _checkedAtMeta,
        checkedAt.isAcceptableOrUnknown(data['checked_at']!, _checkedAtMeta),
      );
    }
    if (data.containsKey('total_xp')) {
      context.handle(
        _totalXpMeta,
        totalXp.isAcceptableOrUnknown(data['total_xp']!, _totalXpMeta),
      );
    }
    if (data.containsKey('streak')) {
      context.handle(
        _streakMeta,
        streak.isAcceptableOrUnknown(data['streak']!, _streakMeta),
      );
    }
    if (data.containsKey('streak_end_date')) {
      context.handle(
        _streakEndDateMeta,
        streakEndDate.isAcceptableOrUnknown(
          data['streak_end_date']!,
          _streakEndDateMeta,
        ),
      );
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('ok')) {
      context.handle(_okMeta, ok.isAcceptableOrUnknown(data['ok']!, _okMeta));
    } else if (isInserting) {
      context.missing(_okMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DuolingoSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DuolingoSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      checkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checked_at'],
      )!,
      totalXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_xp'],
      ),
      streak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak'],
      ),
      streakEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}streak_end_date'],
      ),
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      ok: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ok'],
      )!,
    );
  }

  @override
  $DuolingoSnapshotsTable createAlias(String alias) {
    return $DuolingoSnapshotsTable(attachedDatabase, alias);
  }
}

class DuolingoSnapshot extends DataClass
    implements Insertable<DuolingoSnapshot> {
  final int id;
  final int childId;
  final DateTime checkedAt;
  final int? totalXp;
  final int? streak;
  final String? streakEndDate;

  /// web | usage | manual
  final String method;
  final bool ok;
  const DuolingoSnapshot({
    required this.id,
    required this.childId,
    required this.checkedAt,
    this.totalXp,
    this.streak,
    this.streakEndDate,
    required this.method,
    required this.ok,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['child_id'] = Variable<int>(childId);
    map['checked_at'] = Variable<DateTime>(checkedAt);
    if (!nullToAbsent || totalXp != null) {
      map['total_xp'] = Variable<int>(totalXp);
    }
    if (!nullToAbsent || streak != null) {
      map['streak'] = Variable<int>(streak);
    }
    if (!nullToAbsent || streakEndDate != null) {
      map['streak_end_date'] = Variable<String>(streakEndDate);
    }
    map['method'] = Variable<String>(method);
    map['ok'] = Variable<bool>(ok);
    return map;
  }

  DuolingoSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return DuolingoSnapshotsCompanion(
      id: Value(id),
      childId: Value(childId),
      checkedAt: Value(checkedAt),
      totalXp: totalXp == null && nullToAbsent
          ? const Value.absent()
          : Value(totalXp),
      streak: streak == null && nullToAbsent
          ? const Value.absent()
          : Value(streak),
      streakEndDate: streakEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(streakEndDate),
      method: Value(method),
      ok: Value(ok),
    );
  }

  factory DuolingoSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DuolingoSnapshot(
      id: serializer.fromJson<int>(json['id']),
      childId: serializer.fromJson<int>(json['childId']),
      checkedAt: serializer.fromJson<DateTime>(json['checkedAt']),
      totalXp: serializer.fromJson<int?>(json['totalXp']),
      streak: serializer.fromJson<int?>(json['streak']),
      streakEndDate: serializer.fromJson<String?>(json['streakEndDate']),
      method: serializer.fromJson<String>(json['method']),
      ok: serializer.fromJson<bool>(json['ok']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childId': serializer.toJson<int>(childId),
      'checkedAt': serializer.toJson<DateTime>(checkedAt),
      'totalXp': serializer.toJson<int?>(totalXp),
      'streak': serializer.toJson<int?>(streak),
      'streakEndDate': serializer.toJson<String?>(streakEndDate),
      'method': serializer.toJson<String>(method),
      'ok': serializer.toJson<bool>(ok),
    };
  }

  DuolingoSnapshot copyWith({
    int? id,
    int? childId,
    DateTime? checkedAt,
    Value<int?> totalXp = const Value.absent(),
    Value<int?> streak = const Value.absent(),
    Value<String?> streakEndDate = const Value.absent(),
    String? method,
    bool? ok,
  }) => DuolingoSnapshot(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    checkedAt: checkedAt ?? this.checkedAt,
    totalXp: totalXp.present ? totalXp.value : this.totalXp,
    streak: streak.present ? streak.value : this.streak,
    streakEndDate: streakEndDate.present
        ? streakEndDate.value
        : this.streakEndDate,
    method: method ?? this.method,
    ok: ok ?? this.ok,
  );
  DuolingoSnapshot copyWithCompanion(DuolingoSnapshotsCompanion data) {
    return DuolingoSnapshot(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      checkedAt: data.checkedAt.present ? data.checkedAt.value : this.checkedAt,
      totalXp: data.totalXp.present ? data.totalXp.value : this.totalXp,
      streak: data.streak.present ? data.streak.value : this.streak,
      streakEndDate: data.streakEndDate.present
          ? data.streakEndDate.value
          : this.streakEndDate,
      method: data.method.present ? data.method.value : this.method,
      ok: data.ok.present ? data.ok.value : this.ok,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DuolingoSnapshot(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('totalXp: $totalXp, ')
          ..write('streak: $streak, ')
          ..write('streakEndDate: $streakEndDate, ')
          ..write('method: $method, ')
          ..write('ok: $ok')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    checkedAt,
    totalXp,
    streak,
    streakEndDate,
    method,
    ok,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DuolingoSnapshot &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.checkedAt == this.checkedAt &&
          other.totalXp == this.totalXp &&
          other.streak == this.streak &&
          other.streakEndDate == this.streakEndDate &&
          other.method == this.method &&
          other.ok == this.ok);
}

class DuolingoSnapshotsCompanion extends UpdateCompanion<DuolingoSnapshot> {
  final Value<int> id;
  final Value<int> childId;
  final Value<DateTime> checkedAt;
  final Value<int?> totalXp;
  final Value<int?> streak;
  final Value<String?> streakEndDate;
  final Value<String> method;
  final Value<bool> ok;
  const DuolingoSnapshotsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.checkedAt = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.streak = const Value.absent(),
    this.streakEndDate = const Value.absent(),
    this.method = const Value.absent(),
    this.ok = const Value.absent(),
  });
  DuolingoSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required int childId,
    this.checkedAt = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.streak = const Value.absent(),
    this.streakEndDate = const Value.absent(),
    required String method,
    required bool ok,
  }) : childId = Value(childId),
       method = Value(method),
       ok = Value(ok);
  static Insertable<DuolingoSnapshot> custom({
    Expression<int>? id,
    Expression<int>? childId,
    Expression<DateTime>? checkedAt,
    Expression<int>? totalXp,
    Expression<int>? streak,
    Expression<String>? streakEndDate,
    Expression<String>? method,
    Expression<bool>? ok,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (checkedAt != null) 'checked_at': checkedAt,
      if (totalXp != null) 'total_xp': totalXp,
      if (streak != null) 'streak': streak,
      if (streakEndDate != null) 'streak_end_date': streakEndDate,
      if (method != null) 'method': method,
      if (ok != null) 'ok': ok,
    });
  }

  DuolingoSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<int>? childId,
    Value<DateTime>? checkedAt,
    Value<int?>? totalXp,
    Value<int?>? streak,
    Value<String?>? streakEndDate,
    Value<String>? method,
    Value<bool>? ok,
  }) {
    return DuolingoSnapshotsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      checkedAt: checkedAt ?? this.checkedAt,
      totalXp: totalXp ?? this.totalXp,
      streak: streak ?? this.streak,
      streakEndDate: streakEndDate ?? this.streakEndDate,
      method: method ?? this.method,
      ok: ok ?? this.ok,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (checkedAt.present) {
      map['checked_at'] = Variable<DateTime>(checkedAt.value);
    }
    if (totalXp.present) {
      map['total_xp'] = Variable<int>(totalXp.value);
    }
    if (streak.present) {
      map['streak'] = Variable<int>(streak.value);
    }
    if (streakEndDate.present) {
      map['streak_end_date'] = Variable<String>(streakEndDate.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (ok.present) {
      map['ok'] = Variable<bool>(ok.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DuolingoSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('totalXp: $totalXp, ')
          ..write('streak: $streak, ')
          ..write('streakEndDate: $streakEndDate, ')
          ..write('method: $method, ')
          ..write('ok: $ok')
          ..write(')'))
        .toString();
  }
}

class $PraiseTemplatesTable extends PraiseTemplates
    with TableInfo<$PraiseTemplatesTable, PraiseTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PraiseTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, content, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'praise_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<PraiseTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('text')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['text']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PraiseTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PraiseTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $PraiseTemplatesTable createAlias(String alias) {
    return $PraiseTemplatesTable(attachedDatabase, alias);
  }
}

class PraiseTemplate extends DataClass implements Insertable<PraiseTemplate> {
  final int id;
  final String content;
  final int sortOrder;
  const PraiseTemplate({
    required this.id,
    required this.content,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['text'] = Variable<String>(content);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PraiseTemplatesCompanion toCompanion(bool nullToAbsent) {
    return PraiseTemplatesCompanion(
      id: Value(id),
      content: Value(content),
      sortOrder: Value(sortOrder),
    );
  }

  factory PraiseTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PraiseTemplate(
      id: serializer.fromJson<int>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'content': serializer.toJson<String>(content),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  PraiseTemplate copyWith({int? id, String? content, int? sortOrder}) =>
      PraiseTemplate(
        id: id ?? this.id,
        content: content ?? this.content,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  PraiseTemplate copyWithCompanion(PraiseTemplatesCompanion data) {
    return PraiseTemplate(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PraiseTemplate(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, content, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PraiseTemplate &&
          other.id == this.id &&
          other.content == this.content &&
          other.sortOrder == this.sortOrder);
}

class PraiseTemplatesCompanion extends UpdateCompanion<PraiseTemplate> {
  final Value<int> id;
  final Value<String> content;
  final Value<int> sortOrder;
  const PraiseTemplatesCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  PraiseTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String content,
    this.sortOrder = const Value.absent(),
  }) : content = Value(content);
  static Insertable<PraiseTemplate> custom({
    Expression<int>? id,
    Expression<String>? content,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'text': content,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  PraiseTemplatesCompanion copyWith({
    Value<int>? id,
    Value<String>? content,
    Value<int>? sortOrder,
  }) {
    return PraiseTemplatesCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (content.present) {
      map['text'] = Variable<String>(content.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PraiseTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
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
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChildrenTable children = $ChildrenTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $RewardsTable rewards = $RewardsTable(this);
  late final $StickerEventsTable stickerEvents = $StickerEventsTable(this);
  late final $RedemptionsTable redemptions = $RedemptionsTable(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $RoutineLogsTable routineLogs = $RoutineLogsTable(this);
  late final $DailyClearsTable dailyClears = $DailyClearsTable(this);
  late final $DiaryEntriesTable diaryEntries = $DiaryEntriesTable(this);
  late final $BadgesTable badges = $BadgesTable(this);
  late final $BadgeAwardsTable badgeAwards = $BadgeAwardsTable(this);
  late final $ReportCommentsTable reportComments = $ReportCommentsTable(this);
  late final $DuolingoSnapshotsTable duolingoSnapshots =
      $DuolingoSnapshotsTable(this);
  late final $PraiseTemplatesTable praiseTemplates = $PraiseTemplatesTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    children,
    categories,
    rewards,
    stickerEvents,
    redemptions,
    routines,
    routineLogs,
    dailyClears,
    diaryEntries,
    badges,
    badgeAwards,
    reportComments,
    duolingoSnapshots,
    praiseTemplates,
    appSettings,
  ];
}

typedef $$ChildrenTableCreateCompanionBuilder = ChildrenCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> avatarPath,
  Value<String?> duolingoUsername,
  Value<String> duolingoPackage,
  Value<DateTime> createdAt,
});
typedef $$ChildrenTableUpdateCompanionBuilder = ChildrenCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> avatarPath,
  Value<String?> duolingoUsername,
  Value<String> duolingoPackage,
  Value<DateTime> createdAt,
});

final class $$ChildrenTableReferences
    extends BaseReferences<_$AppDatabase, $ChildrenTable, ChildrenData> {
  $$ChildrenTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StickerEventsTable, List<StickerEvent>>
  _stickerEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stickerEvents,
    aliasName: 'children__id__sticker_events__child_id',
  );

  $$StickerEventsTableProcessedTableManager get stickerEventsRefs {
    final manager = $$StickerEventsTableTableManager(
      $_db,
      $_db.stickerEvents,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_stickerEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RedemptionsTable, List<Redemption>>
  _redemptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.redemptions,
    aliasName: 'children__id__redemptions__child_id',
  );

  $$RedemptionsTableProcessedTableManager get redemptionsRefs {
    final manager = $$RedemptionsTableTableManager(
      $_db,
      $_db.redemptions,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_redemptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RoutinesTable, List<Routine>> _routinesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.routines,
    aliasName: 'children__id__routines__child_id',
  );

  $$RoutinesTableProcessedTableManager get routinesRefs {
    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DailyClearsTable, List<DailyClear>>
  _dailyClearsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dailyClears,
    aliasName: 'children__id__daily_clears__child_id',
  );

  $$DailyClearsTableProcessedTableManager get dailyClearsRefs {
    final manager = $$DailyClearsTableTableManager(
      $_db,
      $_db.dailyClears,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dailyClearsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DiaryEntriesTable, List<DiaryEntry>>
  _diaryEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.diaryEntries,
    aliasName: 'children__id__diary_entries__child_id',
  );

  $$DiaryEntriesTableProcessedTableManager get diaryEntriesRefs {
    final manager = $$DiaryEntriesTableTableManager(
      $_db,
      $_db.diaryEntries,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_diaryEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BadgeAwardsTable, List<BadgeAward>>
  _badgeAwardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.badgeAwards,
    aliasName: 'children__id__badge_awards__child_id',
  );

  $$BadgeAwardsTableProcessedTableManager get badgeAwardsRefs {
    final manager = $$BadgeAwardsTableTableManager(
      $_db,
      $_db.badgeAwards,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_badgeAwardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReportCommentsTable, List<ReportComment>>
  _reportCommentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reportComments,
    aliasName: 'children__id__report_comments__child_id',
  );

  $$ReportCommentsTableProcessedTableManager get reportCommentsRefs {
    final manager = $$ReportCommentsTableTableManager(
      $_db,
      $_db.reportComments,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reportCommentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DuolingoSnapshotsTable, List<DuolingoSnapshot>>
  _duolingoSnapshotsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.duolingoSnapshots,
        aliasName: 'children__id__duolingo_snapshots__child_id',
      );

  $$DuolingoSnapshotsTableProcessedTableManager get duolingoSnapshotsRefs {
    final manager = $$DuolingoSnapshotsTableTableManager(
      $_db,
      $_db.duolingoSnapshots,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _duolingoSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChildrenTableFilterComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get duolingoUsername => $composableBuilder(
    column: $table.duolingoUsername,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get duolingoPackage => $composableBuilder(
    column: $table.duolingoPackage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> stickerEventsRefs(
    Expression<bool> Function($$StickerEventsTableFilterComposer f) f,
  ) {
    final $$StickerEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stickerEvents,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StickerEventsTableFilterComposer(
            $db: $db,
            $table: $db.stickerEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> redemptionsRefs(
    Expression<bool> Function($$RedemptionsTableFilterComposer f) f,
  ) {
    final $$RedemptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.redemptions,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RedemptionsTableFilterComposer(
            $db: $db,
            $table: $db.redemptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> routinesRefs(
    Expression<bool> Function($$RoutinesTableFilterComposer f) f,
  ) {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dailyClearsRefs(
    Expression<bool> Function($$DailyClearsTableFilterComposer f) f,
  ) {
    final $$DailyClearsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyClears,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyClearsTableFilterComposer(
            $db: $db,
            $table: $db.dailyClears,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> diaryEntriesRefs(
    Expression<bool> Function($$DiaryEntriesTableFilterComposer f) f,
  ) {
    final $$DiaryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diaryEntries,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiaryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.diaryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> badgeAwardsRefs(
    Expression<bool> Function($$BadgeAwardsTableFilterComposer f) f,
  ) {
    final $$BadgeAwardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.badgeAwards,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadgeAwardsTableFilterComposer(
            $db: $db,
            $table: $db.badgeAwards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reportCommentsRefs(
    Expression<bool> Function($$ReportCommentsTableFilterComposer f) f,
  ) {
    final $$ReportCommentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reportComments,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReportCommentsTableFilterComposer(
            $db: $db,
            $table: $db.reportComments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> duolingoSnapshotsRefs(
    Expression<bool> Function($$DuolingoSnapshotsTableFilterComposer f) f,
  ) {
    final $$DuolingoSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.duolingoSnapshots,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DuolingoSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.duolingoSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChildrenTableOrderingComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get duolingoUsername => $composableBuilder(
    column: $table.duolingoUsername,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get duolingoPackage => $composableBuilder(
    column: $table.duolingoPackage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChildrenTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get duolingoUsername => $composableBuilder(
    column: $table.duolingoUsername,
    builder: (column) => column,
  );

  GeneratedColumn<String> get duolingoPackage => $composableBuilder(
    column: $table.duolingoPackage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> stickerEventsRefs<T extends Object>(
    Expression<T> Function($$StickerEventsTableAnnotationComposer a) f,
  ) {
    final $$StickerEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stickerEvents,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StickerEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.stickerEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> redemptionsRefs<T extends Object>(
    Expression<T> Function($$RedemptionsTableAnnotationComposer a) f,
  ) {
    final $$RedemptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.redemptions,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RedemptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.redemptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> routinesRefs<T extends Object>(
    Expression<T> Function($$RoutinesTableAnnotationComposer a) f,
  ) {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dailyClearsRefs<T extends Object>(
    Expression<T> Function($$DailyClearsTableAnnotationComposer a) f,
  ) {
    final $$DailyClearsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyClears,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyClearsTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyClears,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> diaryEntriesRefs<T extends Object>(
    Expression<T> Function($$DiaryEntriesTableAnnotationComposer a) f,
  ) {
    final $$DiaryEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diaryEntries,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiaryEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.diaryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> badgeAwardsRefs<T extends Object>(
    Expression<T> Function($$BadgeAwardsTableAnnotationComposer a) f,
  ) {
    final $$BadgeAwardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.badgeAwards,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadgeAwardsTableAnnotationComposer(
            $db: $db,
            $table: $db.badgeAwards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reportCommentsRefs<T extends Object>(
    Expression<T> Function($$ReportCommentsTableAnnotationComposer a) f,
  ) {
    final $$ReportCommentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reportComments,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReportCommentsTableAnnotationComposer(
            $db: $db,
            $table: $db.reportComments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> duolingoSnapshotsRefs<T extends Object>(
    Expression<T> Function($$DuolingoSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$DuolingoSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.duolingoSnapshots,
          getReferencedColumn: (t) => t.childId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DuolingoSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.duolingoSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ChildrenTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChildrenTable,
          ChildrenData,
          $$ChildrenTableFilterComposer,
          $$ChildrenTableOrderingComposer,
          $$ChildrenTableAnnotationComposer,
          $$ChildrenTableCreateCompanionBuilder,
          $$ChildrenTableUpdateCompanionBuilder,
          (ChildrenData, $$ChildrenTableReferences),
          ChildrenData,
          PrefetchHooks Function({
            bool stickerEventsRefs,
            bool redemptionsRefs,
            bool routinesRefs,
            bool dailyClearsRefs,
            bool diaryEntriesRefs,
            bool badgeAwardsRefs,
            bool reportCommentsRefs,
            bool duolingoSnapshotsRefs,
          })
        > {
  $$ChildrenTableTableManager(_$AppDatabase db, $ChildrenTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChildrenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChildrenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChildrenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> duolingoUsername = const Value.absent(),
                Value<String> duolingoPackage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChildrenCompanion(
                id: id,
                name: name,
                avatarPath: avatarPath,
                duolingoUsername: duolingoUsername,
                duolingoPackage: duolingoPackage,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> duolingoUsername = const Value.absent(),
                Value<String> duolingoPackage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChildrenCompanion.insert(
                id: id,
                name: name,
                avatarPath: avatarPath,
                duolingoUsername: duolingoUsername,
                duolingoPackage: duolingoPackage,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChildrenTable, ChildrenData>(table),
                  $$ChildrenTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                stickerEventsRefs = false,
                redemptionsRefs = false,
                routinesRefs = false,
                dailyClearsRefs = false,
                diaryEntriesRefs = false,
                badgeAwardsRefs = false,
                reportCommentsRefs = false,
                duolingoSnapshotsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stickerEventsRefs) db.stickerEvents,
                    if (redemptionsRefs) db.redemptions,
                    if (routinesRefs) db.routines,
                    if (dailyClearsRefs) db.dailyClears,
                    if (diaryEntriesRefs) db.diaryEntries,
                    if (badgeAwardsRefs) db.badgeAwards,
                    if (reportCommentsRefs) db.reportComments,
                    if (duolingoSnapshotsRefs) db.duolingoSnapshots,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stickerEventsRefs)
                        await $_getPrefetchedData<
                          ChildrenData,
                          $ChildrenTable,
                          StickerEvent
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._stickerEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).stickerEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (redemptionsRefs)
                        await $_getPrefetchedData<
                          ChildrenData,
                          $ChildrenTable,
                          Redemption
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._redemptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).redemptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (routinesRefs)
                        await $_getPrefetchedData<
                          ChildrenData,
                          $ChildrenTable,
                          Routine
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._routinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).routinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dailyClearsRefs)
                        await $_getPrefetchedData<
                          ChildrenData,
                          $ChildrenTable,
                          DailyClear
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._dailyClearsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).dailyClearsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (diaryEntriesRefs)
                        await $_getPrefetchedData<
                          ChildrenData,
                          $ChildrenTable,
                          DiaryEntry
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._diaryEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).diaryEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (badgeAwardsRefs)
                        await $_getPrefetchedData<
                          ChildrenData,
                          $ChildrenTable,
                          BadgeAward
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._badgeAwardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).badgeAwardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reportCommentsRefs)
                        await $_getPrefetchedData<
                          ChildrenData,
                          $ChildrenTable,
                          ReportComment
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._reportCommentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).reportCommentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (duolingoSnapshotsRefs)
                        await $_getPrefetchedData<
                          ChildrenData,
                          $ChildrenTable,
                          DuolingoSnapshot
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._duolingoSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).duolingoSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
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

typedef $$ChildrenTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChildrenTable,
      ChildrenData,
      $$ChildrenTableFilterComposer,
      $$ChildrenTableOrderingComposer,
      $$ChildrenTableAnnotationComposer,
      $$ChildrenTableCreateCompanionBuilder,
      $$ChildrenTableUpdateCompanionBuilder,
      (ChildrenData, $$ChildrenTableReferences),
      ChildrenData,
      PrefetchHooks Function({
        bool stickerEventsRefs,
        bool redemptionsRefs,
        bool routinesRefs,
        bool dailyClearsRefs,
        bool diaryEntriesRefs,
        bool badgeAwardsRefs,
        bool reportCommentsRefs,
        bool duolingoSnapshotsRefs,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String kind,
  required String name,
  required String iconKey,
  required int colorValue,
  Value<int> sortOrder,
  Value<bool> isActive,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> kind,
  Value<String> name,
  Value<String> iconKey,
  Value<int> colorValue,
  Value<int> sortOrder,
  Value<bool> isActive,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StickerEventsTable, List<StickerEvent>>
  _stickerEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stickerEvents,
    aliasName: 'categories__id__sticker_events__category_id',
  );

  $$StickerEventsTableProcessedTableManager get stickerEventsRefs {
    final manager = $$StickerEventsTableTableManager(
      $_db,
      $_db.stickerEvents,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_stickerEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> stickerEventsRefs(
    Expression<bool> Function($$StickerEventsTableFilterComposer f) f,
  ) {
    final $$StickerEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stickerEvents,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StickerEventsTableFilterComposer(
            $db: $db,
            $table: $db.stickerEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> stickerEventsRefs<T extends Object>(
    Expression<T> Function($$StickerEventsTableAnnotationComposer a) f,
  ) {
    final $$StickerEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stickerEvents,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StickerEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.stickerEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool stickerEventsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                kind: kind,
                name: name,
                iconKey: iconKey,
                colorValue: colorValue,
                sortOrder: sortOrder,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required String name,
                required String iconKey,
                required int colorValue,
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                kind: kind,
                name: name,
                iconKey: iconKey,
                colorValue: colorValue,
                sortOrder: sortOrder,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, Category>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stickerEventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (stickerEventsRefs) db.stickerEvents,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (stickerEventsRefs)
                    await $_getPrefetchedData<
                      Category,
                      $CategoriesTable,
                      StickerEvent
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._stickerEventsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).stickerEventsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool stickerEventsRefs})
    >;
typedef $$RewardsTableCreateCompanionBuilder = RewardsCompanion Function({
  Value<int> id,
  required String name,
  required int cost,
  Value<String?> imagePath,
  Value<int> sortOrder,
  Value<bool> isActive,
});
typedef $$RewardsTableUpdateCompanionBuilder = RewardsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> cost,
  Value<String?> imagePath,
  Value<int> sortOrder,
  Value<bool> isActive,
});

final class $$RewardsTableReferences
    extends BaseReferences<_$AppDatabase, $RewardsTable, Reward> {
  $$RewardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StickerEventsTable, List<StickerEvent>>
  _stickerEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stickerEvents,
    aliasName: 'rewards__id__sticker_events__reward_id',
  );

  $$StickerEventsTableProcessedTableManager get stickerEventsRefs {
    final manager = $$StickerEventsTableTableManager(
      $_db,
      $_db.stickerEvents,
    ).filter((f) => f.rewardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_stickerEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RedemptionsTable, List<Redemption>>
  _redemptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.redemptions,
    aliasName: 'rewards__id__redemptions__reward_id',
  );

  $$RedemptionsTableProcessedTableManager get redemptionsRefs {
    final manager = $$RedemptionsTableTableManager(
      $_db,
      $_db.redemptions,
    ).filter((f) => f.rewardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_redemptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RewardsTableFilterComposer
    extends Composer<_$AppDatabase, $RewardsTable> {
  $$RewardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> stickerEventsRefs(
    Expression<bool> Function($$StickerEventsTableFilterComposer f) f,
  ) {
    final $$StickerEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stickerEvents,
      getReferencedColumn: (t) => t.rewardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StickerEventsTableFilterComposer(
            $db: $db,
            $table: $db.stickerEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> redemptionsRefs(
    Expression<bool> Function($$RedemptionsTableFilterComposer f) f,
  ) {
    final $$RedemptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.redemptions,
      getReferencedColumn: (t) => t.rewardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RedemptionsTableFilterComposer(
            $db: $db,
            $table: $db.redemptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RewardsTableOrderingComposer
    extends Composer<_$AppDatabase, $RewardsTable> {
  $$RewardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RewardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RewardsTable> {
  $$RewardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> stickerEventsRefs<T extends Object>(
    Expression<T> Function($$StickerEventsTableAnnotationComposer a) f,
  ) {
    final $$StickerEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stickerEvents,
      getReferencedColumn: (t) => t.rewardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StickerEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.stickerEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> redemptionsRefs<T extends Object>(
    Expression<T> Function($$RedemptionsTableAnnotationComposer a) f,
  ) {
    final $$RedemptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.redemptions,
      getReferencedColumn: (t) => t.rewardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RedemptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.redemptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RewardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RewardsTable,
          Reward,
          $$RewardsTableFilterComposer,
          $$RewardsTableOrderingComposer,
          $$RewardsTableAnnotationComposer,
          $$RewardsTableCreateCompanionBuilder,
          $$RewardsTableUpdateCompanionBuilder,
          (Reward, $$RewardsTableReferences),
          Reward,
          PrefetchHooks Function({bool stickerEventsRefs, bool redemptionsRefs})
        > {
  $$RewardsTableTableManager(_$AppDatabase db, $RewardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RewardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RewardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RewardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> cost = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => RewardsCompanion(
                id: id,
                name: name,
                cost: cost,
                imagePath: imagePath,
                sortOrder: sortOrder,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int cost,
                Value<String?> imagePath = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => RewardsCompanion.insert(
                id: id,
                name: name,
                cost: cost,
                imagePath: imagePath,
                sortOrder: sortOrder,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RewardsTable, Reward>(table),
                  $$RewardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({stickerEventsRefs = false, redemptionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stickerEventsRefs) db.stickerEvents,
                    if (redemptionsRefs) db.redemptions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stickerEventsRefs)
                        await $_getPrefetchedData<
                          Reward,
                          $RewardsTable,
                          StickerEvent
                        >(
                          currentTable: table,
                          referencedTable: $$RewardsTableReferences
                              ._stickerEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RewardsTableReferences(
                                db,
                                table,
                                p0,
                              ).stickerEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rewardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (redemptionsRefs)
                        await $_getPrefetchedData<
                          Reward,
                          $RewardsTable,
                          Redemption
                        >(
                          currentTable: table,
                          referencedTable: $$RewardsTableReferences
                              ._redemptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RewardsTableReferences(
                                db,
                                table,
                                p0,
                              ).redemptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rewardId == item.id,
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

typedef $$RewardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RewardsTable,
      Reward,
      $$RewardsTableFilterComposer,
      $$RewardsTableOrderingComposer,
      $$RewardsTableAnnotationComposer,
      $$RewardsTableCreateCompanionBuilder,
      $$RewardsTableUpdateCompanionBuilder,
      (Reward, $$RewardsTableReferences),
      Reward,
      PrefetchHooks Function({bool stickerEventsRefs, bool redemptionsRefs})
    >;
typedef $$StickerEventsTableCreateCompanionBuilder =
    StickerEventsCompanion Function({
      Value<int> id,
      required int childId,
      required String eventType,
      required int amount,
      Value<int?> categoryId,
      Value<String?> memo,
      Value<String?> nextPromise,
      Value<int?> rewardId,
      Value<int?> relatedEventId,
      Value<DateTime> createdAt,
      required String localDate,
    });
typedef $$StickerEventsTableUpdateCompanionBuilder =
    StickerEventsCompanion Function({
      Value<int> id,
      Value<int> childId,
      Value<String> eventType,
      Value<int> amount,
      Value<int?> categoryId,
      Value<String?> memo,
      Value<String?> nextPromise,
      Value<int?> rewardId,
      Value<int?> relatedEventId,
      Value<DateTime> createdAt,
      Value<String> localDate,
    });

final class $$StickerEventsTableReferences
    extends BaseReferences<_$AppDatabase, $StickerEventsTable, StickerEvent> {
  $$StickerEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('sticker_events__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('sticker_events__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RewardsTable _rewardIdTable(_$AppDatabase db) =>
      db.rewards.createAlias('sticker_events__reward_id__rewards__id');

  $$RewardsTableProcessedTableManager? get rewardId {
    final $_column = $_itemColumn<int>('reward_id');
    if ($_column == null) return null;
    final manager = $$RewardsTableTableManager(
      $_db,
      $_db.rewards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rewardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RedemptionsTable, List<Redemption>>
  _redemptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.redemptions,
    aliasName: 'sticker_events__id__redemptions__event_id',
  );

  $$RedemptionsTableProcessedTableManager get redemptionsRefs {
    final manager = $$RedemptionsTableTableManager(
      $_db,
      $_db.redemptions,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_redemptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StickerEventsTableFilterComposer
    extends Composer<_$AppDatabase, $StickerEventsTable> {
  $$StickerEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextPromise => $composableBuilder(
    column: $table.nextPromise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get relatedEventId => $composableBuilder(
    column: $table.relatedEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RewardsTableFilterComposer get rewardId {
    final $$RewardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rewardId,
      referencedTable: $db.rewards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RewardsTableFilterComposer(
            $db: $db,
            $table: $db.rewards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> redemptionsRefs(
    Expression<bool> Function($$RedemptionsTableFilterComposer f) f,
  ) {
    final $$RedemptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.redemptions,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RedemptionsTableFilterComposer(
            $db: $db,
            $table: $db.redemptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StickerEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $StickerEventsTable> {
  $$StickerEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextPromise => $composableBuilder(
    column: $table.nextPromise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get relatedEventId => $composableBuilder(
    column: $table.relatedEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RewardsTableOrderingComposer get rewardId {
    final $$RewardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rewardId,
      referencedTable: $db.rewards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RewardsTableOrderingComposer(
            $db: $db,
            $table: $db.rewards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StickerEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StickerEventsTable> {
  $$StickerEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get nextPromise => $composableBuilder(
    column: $table.nextPromise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get relatedEventId => $composableBuilder(
    column: $table.relatedEventId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RewardsTableAnnotationComposer get rewardId {
    final $$RewardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rewardId,
      referencedTable: $db.rewards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RewardsTableAnnotationComposer(
            $db: $db,
            $table: $db.rewards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> redemptionsRefs<T extends Object>(
    Expression<T> Function($$RedemptionsTableAnnotationComposer a) f,
  ) {
    final $$RedemptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.redemptions,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RedemptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.redemptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StickerEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StickerEventsTable,
          StickerEvent,
          $$StickerEventsTableFilterComposer,
          $$StickerEventsTableOrderingComposer,
          $$StickerEventsTableAnnotationComposer,
          $$StickerEventsTableCreateCompanionBuilder,
          $$StickerEventsTableUpdateCompanionBuilder,
          (StickerEvent, $$StickerEventsTableReferences),
          StickerEvent,
          PrefetchHooks Function({
            bool childId,
            bool categoryId,
            bool rewardId,
            bool redemptionsRefs,
          })
        > {
  $$StickerEventsTableTableManager(_$AppDatabase db, $StickerEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StickerEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StickerEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StickerEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String?> nextPromise = const Value.absent(),
                Value<int?> rewardId = const Value.absent(),
                Value<int?> relatedEventId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> localDate = const Value.absent(),
              }) => StickerEventsCompanion(
                id: id,
                childId: childId,
                eventType: eventType,
                amount: amount,
                categoryId: categoryId,
                memo: memo,
                nextPromise: nextPromise,
                rewardId: rewardId,
                relatedEventId: relatedEventId,
                createdAt: createdAt,
                localDate: localDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int childId,
                required String eventType,
                required int amount,
                Value<int?> categoryId = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String?> nextPromise = const Value.absent(),
                Value<int?> rewardId = const Value.absent(),
                Value<int?> relatedEventId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String localDate,
              }) => StickerEventsCompanion.insert(
                id: id,
                childId: childId,
                eventType: eventType,
                amount: amount,
                categoryId: categoryId,
                memo: memo,
                nextPromise: nextPromise,
                rewardId: rewardId,
                relatedEventId: relatedEventId,
                createdAt: createdAt,
                localDate: localDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StickerEventsTable, StickerEvent>(table),
                  $$StickerEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                childId = false,
                categoryId = false,
                rewardId = false,
                redemptionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (redemptionsRefs) db.redemptions,
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
                        if (childId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.childId,
                            referencedTable: $$StickerEventsTableReferences
                                ._childIdTable(db),
                            referencedColumn: $$StickerEventsTableReferences
                                ._childIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$StickerEventsTableReferences
                                ._categoryIdTable(db),
                            referencedColumn: $$StickerEventsTableReferences
                                ._categoryIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (rewardId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.rewardId,
                            referencedTable: $$StickerEventsTableReferences
                                ._rewardIdTable(db),
                            referencedColumn: $$StickerEventsTableReferences
                                ._rewardIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (redemptionsRefs)
                        await $_getPrefetchedData<
                          StickerEvent,
                          $StickerEventsTable,
                          Redemption
                        >(
                          currentTable: table,
                          referencedTable: $$StickerEventsTableReferences
                              ._redemptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StickerEventsTableReferences(
                                db,
                                table,
                                p0,
                              ).redemptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
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

typedef $$StickerEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StickerEventsTable,
      StickerEvent,
      $$StickerEventsTableFilterComposer,
      $$StickerEventsTableOrderingComposer,
      $$StickerEventsTableAnnotationComposer,
      $$StickerEventsTableCreateCompanionBuilder,
      $$StickerEventsTableUpdateCompanionBuilder,
      (StickerEvent, $$StickerEventsTableReferences),
      StickerEvent,
      PrefetchHooks Function({
        bool childId,
        bool categoryId,
        bool rewardId,
        bool redemptionsRefs,
      })
    >;
typedef $$RedemptionsTableCreateCompanionBuilder =
    RedemptionsCompanion Function({
      Value<int> id,
      required int childId,
      required int rewardId,
      required String voucherNo,
      required int cost,
      required int eventId,
      Value<DateTime> createdAt,
      Value<DateTime?> deliveredAt,
    });
typedef $$RedemptionsTableUpdateCompanionBuilder =
    RedemptionsCompanion Function({
      Value<int> id,
      Value<int> childId,
      Value<int> rewardId,
      Value<String> voucherNo,
      Value<int> cost,
      Value<int> eventId,
      Value<DateTime> createdAt,
      Value<DateTime?> deliveredAt,
    });

final class $$RedemptionsTableReferences
    extends BaseReferences<_$AppDatabase, $RedemptionsTable, Redemption> {
  $$RedemptionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('redemptions__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RewardsTable _rewardIdTable(_$AppDatabase db) =>
      db.rewards.createAlias('redemptions__reward_id__rewards__id');

  $$RewardsTableProcessedTableManager get rewardId {
    final $_column = $_itemColumn<int>('reward_id')!;

    final manager = $$RewardsTableTableManager(
      $_db,
      $_db.rewards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rewardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StickerEventsTable _eventIdTable(_$AppDatabase db) =>
      db.stickerEvents.createAlias('redemptions__event_id__sticker_events__id');

  $$StickerEventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<int>('event_id')!;

    final manager = $$StickerEventsTableTableManager(
      $_db,
      $_db.stickerEvents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RedemptionsTableFilterComposer
    extends Composer<_$AppDatabase, $RedemptionsTable> {
  $$RedemptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voucherNo => $composableBuilder(
    column: $table.voucherNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RewardsTableFilterComposer get rewardId {
    final $$RewardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rewardId,
      referencedTable: $db.rewards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RewardsTableFilterComposer(
            $db: $db,
            $table: $db.rewards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StickerEventsTableFilterComposer get eventId {
    final $$StickerEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.stickerEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StickerEventsTableFilterComposer(
            $db: $db,
            $table: $db.stickerEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RedemptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RedemptionsTable> {
  $$RedemptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voucherNo => $composableBuilder(
    column: $table.voucherNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RewardsTableOrderingComposer get rewardId {
    final $$RewardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rewardId,
      referencedTable: $db.rewards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RewardsTableOrderingComposer(
            $db: $db,
            $table: $db.rewards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StickerEventsTableOrderingComposer get eventId {
    final $$StickerEventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.stickerEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StickerEventsTableOrderingComposer(
            $db: $db,
            $table: $db.stickerEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RedemptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RedemptionsTable> {
  $$RedemptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get voucherNo =>
      $composableBuilder(column: $table.voucherNo, builder: (column) => column);

  GeneratedColumn<int> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => column,
  );

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RewardsTableAnnotationComposer get rewardId {
    final $$RewardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rewardId,
      referencedTable: $db.rewards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RewardsTableAnnotationComposer(
            $db: $db,
            $table: $db.rewards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StickerEventsTableAnnotationComposer get eventId {
    final $$StickerEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.stickerEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StickerEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.stickerEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RedemptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RedemptionsTable,
          Redemption,
          $$RedemptionsTableFilterComposer,
          $$RedemptionsTableOrderingComposer,
          $$RedemptionsTableAnnotationComposer,
          $$RedemptionsTableCreateCompanionBuilder,
          $$RedemptionsTableUpdateCompanionBuilder,
          (Redemption, $$RedemptionsTableReferences),
          Redemption,
          PrefetchHooks Function({bool childId, bool rewardId, bool eventId})
        > {
  $$RedemptionsTableTableManager(_$AppDatabase db, $RedemptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RedemptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RedemptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RedemptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<int> rewardId = const Value.absent(),
                Value<String> voucherNo = const Value.absent(),
                Value<int> cost = const Value.absent(),
                Value<int> eventId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deliveredAt = const Value.absent(),
              }) => RedemptionsCompanion(
                id: id,
                childId: childId,
                rewardId: rewardId,
                voucherNo: voucherNo,
                cost: cost,
                eventId: eventId,
                createdAt: createdAt,
                deliveredAt: deliveredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int childId,
                required int rewardId,
                required String voucherNo,
                required int cost,
                required int eventId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deliveredAt = const Value.absent(),
              }) => RedemptionsCompanion.insert(
                id: id,
                childId: childId,
                rewardId: rewardId,
                voucherNo: voucherNo,
                cost: cost,
                eventId: eventId,
                createdAt: createdAt,
                deliveredAt: deliveredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RedemptionsTable, Redemption>(table),
                  $$RedemptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({childId = false, rewardId = false, eventId = false}) {
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
                        if (childId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.childId,
                            referencedTable: $$RedemptionsTableReferences
                                ._childIdTable(db),
                            referencedColumn: $$RedemptionsTableReferences
                                ._childIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (rewardId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.rewardId,
                            referencedTable: $$RedemptionsTableReferences
                                ._rewardIdTable(db),
                            referencedColumn: $$RedemptionsTableReferences
                                ._rewardIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (eventId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.eventId,
                            referencedTable: $$RedemptionsTableReferences
                                ._eventIdTable(db),
                            referencedColumn: $$RedemptionsTableReferences
                                ._eventIdTable(db)
                                .id,
                          ) as T;
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

typedef $$RedemptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RedemptionsTable,
      Redemption,
      $$RedemptionsTableFilterComposer,
      $$RedemptionsTableOrderingComposer,
      $$RedemptionsTableAnnotationComposer,
      $$RedemptionsTableCreateCompanionBuilder,
      $$RedemptionsTableUpdateCompanionBuilder,
      (Redemption, $$RedemptionsTableReferences),
      Redemption,
      PrefetchHooks Function({bool childId, bool rewardId, bool eventId})
    >;
typedef $$RoutinesTableCreateCompanionBuilder = RoutinesCompanion Function({
  Value<int> id,
  required int childId,
  required String title,
  required String iconKey,
  required String kind,
  Value<int?> timerMinutes,
  Value<int> daysMask,
  required String timeSlot,
  Value<int> sortOrder,
  Value<bool> isActive,
});
typedef $$RoutinesTableUpdateCompanionBuilder = RoutinesCompanion Function({
  Value<int> id,
  Value<int> childId,
  Value<String> title,
  Value<String> iconKey,
  Value<String> kind,
  Value<int?> timerMinutes,
  Value<int> daysMask,
  Value<String> timeSlot,
  Value<int> sortOrder,
  Value<bool> isActive,
});

final class $$RoutinesTableReferences
    extends BaseReferences<_$AppDatabase, $RoutinesTable, Routine> {
  $$RoutinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('routines__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RoutineLogsTable, List<RoutineLog>>
  _routineLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routineLogs,
    aliasName: 'routines__id__routine_logs__routine_id',
  );

  $$RoutineLogsTableProcessedTableManager get routineLogsRefs {
    final manager = $$RoutineLogsTableTableManager(
      $_db,
      $_db.routineLogs,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutinesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timerMinutes => $composableBuilder(
    column: $table.timerMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysMask => $composableBuilder(
    column: $table.daysMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeSlot => $composableBuilder(
    column: $table.timeSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> routineLogsRefs(
    Expression<bool> Function($$RoutineLogsTableFilterComposer f) f,
  ) {
    final $$RoutineLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineLogs,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineLogsTableFilterComposer(
            $db: $db,
            $table: $db.routineLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timerMinutes => $composableBuilder(
    column: $table.timerMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysMask => $composableBuilder(
    column: $table.daysMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeSlot => $composableBuilder(
    column: $table.timeSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get timerMinutes => $composableBuilder(
    column: $table.timerMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get daysMask =>
      $composableBuilder(column: $table.daysMask, builder: (column) => column);

  GeneratedColumn<String> get timeSlot =>
      $composableBuilder(column: $table.timeSlot, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> routineLogsRefs<T extends Object>(
    Expression<T> Function($$RoutineLogsTableAnnotationComposer a) f,
  ) {
    final $$RoutineLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineLogs,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutinesTable,
          Routine,
          $$RoutinesTableFilterComposer,
          $$RoutinesTableOrderingComposer,
          $$RoutinesTableAnnotationComposer,
          $$RoutinesTableCreateCompanionBuilder,
          $$RoutinesTableUpdateCompanionBuilder,
          (Routine, $$RoutinesTableReferences),
          Routine,
          PrefetchHooks Function({bool childId, bool routineLogsRefs})
        > {
  $$RoutinesTableTableManager(_$AppDatabase db, $RoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> timerMinutes = const Value.absent(),
                Value<int> daysMask = const Value.absent(),
                Value<String> timeSlot = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => RoutinesCompanion(
                id: id,
                childId: childId,
                title: title,
                iconKey: iconKey,
                kind: kind,
                timerMinutes: timerMinutes,
                daysMask: daysMask,
                timeSlot: timeSlot,
                sortOrder: sortOrder,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int childId,
                required String title,
                required String iconKey,
                required String kind,
                Value<int?> timerMinutes = const Value.absent(),
                Value<int> daysMask = const Value.absent(),
                required String timeSlot,
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => RoutinesCompanion.insert(
                id: id,
                childId: childId,
                title: title,
                iconKey: iconKey,
                kind: kind,
                timerMinutes: timerMinutes,
                daysMask: daysMask,
                timeSlot: timeSlot,
                sortOrder: sortOrder,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutinesTable, Routine>(table),
                  $$RoutinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false, routineLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routineLogsRefs) db.routineLogs],
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
                    if (childId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.childId,
                        referencedTable: $$RoutinesTableReferences
                            ._childIdTable(db),
                        referencedColumn: $$RoutinesTableReferences
                            ._childIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routineLogsRefs)
                    await $_getPrefetchedData<
                      Routine,
                      $RoutinesTable,
                      RoutineLog
                    >(
                      currentTable: table,
                      referencedTable: $$RoutinesTableReferences
                          ._routineLogsRefsTable(db),
                      managerFromTypedResult: (p0) => $$RoutinesTableReferences(
                        db,
                        table,
                        p0,
                      ).routineLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.routineId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutinesTable,
      Routine,
      $$RoutinesTableFilterComposer,
      $$RoutinesTableOrderingComposer,
      $$RoutinesTableAnnotationComposer,
      $$RoutinesTableCreateCompanionBuilder,
      $$RoutinesTableUpdateCompanionBuilder,
      (Routine, $$RoutinesTableReferences),
      Routine,
      PrefetchHooks Function({bool childId, bool routineLogsRefs})
    >;
typedef $$RoutineLogsTableCreateCompanionBuilder =
    RoutineLogsCompanion Function({
      Value<int> id,
      required int routineId,
      required String localDate,
      Value<DateTime> doneAt,
      required String source,
    });
typedef $$RoutineLogsTableUpdateCompanionBuilder =
    RoutineLogsCompanion Function({
      Value<int> id,
      Value<int> routineId,
      Value<String> localDate,
      Value<DateTime> doneAt,
      Value<String> source,
    });

final class $$RoutineLogsTableReferences
    extends BaseReferences<_$AppDatabase, $RoutineLogsTable, RoutineLog> {
  $$RoutineLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutinesTable _routineIdTable(_$AppDatabase db) =>
      db.routines.createAlias('routine_logs__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<int>('routine_id')!;

    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutineLogsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineLogsTable> {
  $$RoutineLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineLogsTable> {
  $$RoutineLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineLogsTable> {
  $$RoutineLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<DateTime> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineLogsTable,
          RoutineLog,
          $$RoutineLogsTableFilterComposer,
          $$RoutineLogsTableOrderingComposer,
          $$RoutineLogsTableAnnotationComposer,
          $$RoutineLogsTableCreateCompanionBuilder,
          $$RoutineLogsTableUpdateCompanionBuilder,
          (RoutineLog, $$RoutineLogsTableReferences),
          RoutineLog,
          PrefetchHooks Function({bool routineId})
        > {
  $$RoutineLogsTableTableManager(_$AppDatabase db, $RoutineLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> routineId = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<DateTime> doneAt = const Value.absent(),
                Value<String> source = const Value.absent(),
              }) => RoutineLogsCompanion(
                id: id,
                routineId: routineId,
                localDate: localDate,
                doneAt: doneAt,
                source: source,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int routineId,
                required String localDate,
                Value<DateTime> doneAt = const Value.absent(),
                required String source,
              }) => RoutineLogsCompanion.insert(
                id: id,
                routineId: routineId,
                localDate: localDate,
                doneAt: doneAt,
                source: source,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutineLogsTable, RoutineLog>(table),
                  $$RoutineLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routineId = false}) {
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
                    if (routineId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.routineId,
                        referencedTable: $$RoutineLogsTableReferences
                            ._routineIdTable(db),
                        referencedColumn: $$RoutineLogsTableReferences
                            ._routineIdTable(db)
                            .id,
                      ) as T;
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

typedef $$RoutineLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineLogsTable,
      RoutineLog,
      $$RoutineLogsTableFilterComposer,
      $$RoutineLogsTableOrderingComposer,
      $$RoutineLogsTableAnnotationComposer,
      $$RoutineLogsTableCreateCompanionBuilder,
      $$RoutineLogsTableUpdateCompanionBuilder,
      (RoutineLog, $$RoutineLogsTableReferences),
      RoutineLog,
      PrefetchHooks Function({bool routineId})
    >;
typedef $$DailyClearsTableCreateCompanionBuilder =
    DailyClearsCompanion Function({
      Value<int> id,
      required int childId,
      required String localDate,
      Value<DateTime> clearedAt,
      Value<String> bonusStatus,
    });
typedef $$DailyClearsTableUpdateCompanionBuilder =
    DailyClearsCompanion Function({
      Value<int> id,
      Value<int> childId,
      Value<String> localDate,
      Value<DateTime> clearedAt,
      Value<String> bonusStatus,
    });

final class $$DailyClearsTableReferences
    extends BaseReferences<_$AppDatabase, $DailyClearsTable, DailyClear> {
  $$DailyClearsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('daily_clears__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DailyClearsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyClearsTable> {
  $$DailyClearsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clearedAt => $composableBuilder(
    column: $table.clearedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bonusStatus => $composableBuilder(
    column: $table.bonusStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyClearsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyClearsTable> {
  $$DailyClearsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clearedAt => $composableBuilder(
    column: $table.clearedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bonusStatus => $composableBuilder(
    column: $table.bonusStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyClearsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyClearsTable> {
  $$DailyClearsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<DateTime> get clearedAt =>
      $composableBuilder(column: $table.clearedAt, builder: (column) => column);

  GeneratedColumn<String> get bonusStatus => $composableBuilder(
    column: $table.bonusStatus,
    builder: (column) => column,
  );

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyClearsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyClearsTable,
          DailyClear,
          $$DailyClearsTableFilterComposer,
          $$DailyClearsTableOrderingComposer,
          $$DailyClearsTableAnnotationComposer,
          $$DailyClearsTableCreateCompanionBuilder,
          $$DailyClearsTableUpdateCompanionBuilder,
          (DailyClear, $$DailyClearsTableReferences),
          DailyClear,
          PrefetchHooks Function({bool childId})
        > {
  $$DailyClearsTableTableManager(_$AppDatabase db, $DailyClearsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyClearsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyClearsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyClearsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<DateTime> clearedAt = const Value.absent(),
                Value<String> bonusStatus = const Value.absent(),
              }) => DailyClearsCompanion(
                id: id,
                childId: childId,
                localDate: localDate,
                clearedAt: clearedAt,
                bonusStatus: bonusStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int childId,
                required String localDate,
                Value<DateTime> clearedAt = const Value.absent(),
                Value<String> bonusStatus = const Value.absent(),
              }) => DailyClearsCompanion.insert(
                id: id,
                childId: childId,
                localDate: localDate,
                clearedAt: clearedAt,
                bonusStatus: bonusStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyClearsTable, DailyClear>(table),
                  $$DailyClearsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
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
                    if (childId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.childId,
                        referencedTable: $$DailyClearsTableReferences
                            ._childIdTable(db),
                        referencedColumn: $$DailyClearsTableReferences
                            ._childIdTable(db)
                            .id,
                      ) as T;
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

typedef $$DailyClearsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyClearsTable,
      DailyClear,
      $$DailyClearsTableFilterComposer,
      $$DailyClearsTableOrderingComposer,
      $$DailyClearsTableAnnotationComposer,
      $$DailyClearsTableCreateCompanionBuilder,
      $$DailyClearsTableUpdateCompanionBuilder,
      (DailyClear, $$DailyClearsTableReferences),
      DailyClear,
      PrefetchHooks Function({bool childId})
    >;
typedef $$DiaryEntriesTableCreateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<int> id,
      required int childId,
      required String localDate,
      Value<String?> weather,
      Value<int?> mood,
      Value<String> title,
      Value<String> body,
      Value<String?> parentReply,
      Value<DateTime?> parentRepliedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$DiaryEntriesTableUpdateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<int> id,
      Value<int> childId,
      Value<String> localDate,
      Value<String?> weather,
      Value<int?> mood,
      Value<String> title,
      Value<String> body,
      Value<String?> parentReply,
      Value<DateTime?> parentRepliedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$DiaryEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $DiaryEntriesTable, DiaryEntry> {
  $$DiaryEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('diary_entries__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DiaryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weather => $composableBuilder(
    column: $table.weather,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentReply => $composableBuilder(
    column: $table.parentReply,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get parentRepliedAt => $composableBuilder(
    column: $table.parentRepliedAt,
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

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiaryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weather => $composableBuilder(
    column: $table.weather,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentReply => $composableBuilder(
    column: $table.parentReply,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get parentRepliedAt => $composableBuilder(
    column: $table.parentRepliedAt,
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

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiaryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get weather =>
      $composableBuilder(column: $table.weather, builder: (column) => column);

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get parentReply => $composableBuilder(
    column: $table.parentReply,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get parentRepliedAt => $composableBuilder(
    column: $table.parentRepliedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiaryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiaryEntriesTable,
          DiaryEntry,
          $$DiaryEntriesTableFilterComposer,
          $$DiaryEntriesTableOrderingComposer,
          $$DiaryEntriesTableAnnotationComposer,
          $$DiaryEntriesTableCreateCompanionBuilder,
          $$DiaryEntriesTableUpdateCompanionBuilder,
          (DiaryEntry, $$DiaryEntriesTableReferences),
          DiaryEntry,
          PrefetchHooks Function({bool childId})
        > {
  $$DiaryEntriesTableTableManager(_$AppDatabase db, $DiaryEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiaryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiaryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiaryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<String?> weather = const Value.absent(),
                Value<int?> mood = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> parentReply = const Value.absent(),
                Value<DateTime?> parentRepliedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DiaryEntriesCompanion(
                id: id,
                childId: childId,
                localDate: localDate,
                weather: weather,
                mood: mood,
                title: title,
                body: body,
                parentReply: parentReply,
                parentRepliedAt: parentRepliedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int childId,
                required String localDate,
                Value<String?> weather = const Value.absent(),
                Value<int?> mood = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> parentReply = const Value.absent(),
                Value<DateTime?> parentRepliedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DiaryEntriesCompanion.insert(
                id: id,
                childId: childId,
                localDate: localDate,
                weather: weather,
                mood: mood,
                title: title,
                body: body,
                parentReply: parentReply,
                parentRepliedAt: parentRepliedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DiaryEntriesTable, DiaryEntry>(table),
                  $$DiaryEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
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
                    if (childId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.childId,
                        referencedTable: $$DiaryEntriesTableReferences
                            ._childIdTable(db),
                        referencedColumn: $$DiaryEntriesTableReferences
                            ._childIdTable(db)
                            .id,
                      ) as T;
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

typedef $$DiaryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiaryEntriesTable,
      DiaryEntry,
      $$DiaryEntriesTableFilterComposer,
      $$DiaryEntriesTableOrderingComposer,
      $$DiaryEntriesTableAnnotationComposer,
      $$DiaryEntriesTableCreateCompanionBuilder,
      $$DiaryEntriesTableUpdateCompanionBuilder,
      (DiaryEntry, $$DiaryEntriesTableReferences),
      DiaryEntry,
      PrefetchHooks Function({bool childId})
    >;
typedef $$BadgesTableCreateCompanionBuilder = BadgesCompanion Function({
  required String code,
  required String category,
  required String name,
  required String iconKey,
  required int colorValue,
  required String ruleJson,
  Value<bool> isHidden,
  Value<bool> isActive,
  Value<int> bonusAmount,
  Value<int> rowid,
});
typedef $$BadgesTableUpdateCompanionBuilder = BadgesCompanion Function({
  Value<String> code,
  Value<String> category,
  Value<String> name,
  Value<String> iconKey,
  Value<int> colorValue,
  Value<String> ruleJson,
  Value<bool> isHidden,
  Value<bool> isActive,
  Value<int> bonusAmount,
  Value<int> rowid,
});

final class $$BadgesTableReferences
    extends BaseReferences<_$AppDatabase, $BadgesTable, Badge> {
  $$BadgesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BadgeAwardsTable, List<BadgeAward>>
  _badgeAwardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.badgeAwards,
    aliasName: 'badges__code__badge_awards__badge_code',
  );

  $$BadgeAwardsTableProcessedTableManager get badgeAwardsRefs {
    final manager = $$BadgeAwardsTableTableManager(
      $_db,
      $_db.badgeAwards,
    ).filter((f) => f.badgeCode.code.sqlEquals($_itemColumn<String>('code')!));

    final cache = $_typedResult.readTableOrNull(_badgeAwardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BadgesTableFilterComposer
    extends Composer<_$AppDatabase, $BadgesTable> {
  $$BadgesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleJson => $composableBuilder(
    column: $table.ruleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bonusAmount => $composableBuilder(
    column: $table.bonusAmount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> badgeAwardsRefs(
    Expression<bool> Function($$BadgeAwardsTableFilterComposer f) f,
  ) {
    final $$BadgeAwardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.badgeAwards,
      getReferencedColumn: (t) => t.badgeCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadgeAwardsTableFilterComposer(
            $db: $db,
            $table: $db.badgeAwards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BadgesTableOrderingComposer
    extends Composer<_$AppDatabase, $BadgesTable> {
  $$BadgesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleJson => $composableBuilder(
    column: $table.ruleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bonusAmount => $composableBuilder(
    column: $table.bonusAmount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BadgesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BadgesTable> {
  $$BadgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ruleJson =>
      $composableBuilder(column: $table.ruleJson, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get bonusAmount => $composableBuilder(
    column: $table.bonusAmount,
    builder: (column) => column,
  );

  Expression<T> badgeAwardsRefs<T extends Object>(
    Expression<T> Function($$BadgeAwardsTableAnnotationComposer a) f,
  ) {
    final $$BadgeAwardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.badgeAwards,
      getReferencedColumn: (t) => t.badgeCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadgeAwardsTableAnnotationComposer(
            $db: $db,
            $table: $db.badgeAwards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BadgesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BadgesTable,
          Badge,
          $$BadgesTableFilterComposer,
          $$BadgesTableOrderingComposer,
          $$BadgesTableAnnotationComposer,
          $$BadgesTableCreateCompanionBuilder,
          $$BadgesTableUpdateCompanionBuilder,
          (Badge, $$BadgesTableReferences),
          Badge,
          PrefetchHooks Function({bool badgeAwardsRefs})
        > {
  $$BadgesTableTableManager(_$AppDatabase db, $BadgesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BadgesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BadgesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BadgesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<String> ruleJson = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> bonusAmount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BadgesCompanion(
                code: code,
                category: category,
                name: name,
                iconKey: iconKey,
                colorValue: colorValue,
                ruleJson: ruleJson,
                isHidden: isHidden,
                isActive: isActive,
                bonusAmount: bonusAmount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String category,
                required String name,
                required String iconKey,
                required int colorValue,
                required String ruleJson,
                Value<bool> isHidden = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> bonusAmount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BadgesCompanion.insert(
                code: code,
                category: category,
                name: name,
                iconKey: iconKey,
                colorValue: colorValue,
                ruleJson: ruleJson,
                isHidden: isHidden,
                isActive: isActive,
                bonusAmount: bonusAmount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BadgesTable, Badge>(table),
                  $$BadgesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({badgeAwardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (badgeAwardsRefs) db.badgeAwards],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (badgeAwardsRefs)
                    await $_getPrefetchedData<Badge, $BadgesTable, BadgeAward>(
                      currentTable: table,
                      referencedTable: $$BadgesTableReferences
                          ._badgeAwardsRefsTable(db),
                      managerFromTypedResult: (p0) => $$BadgesTableReferences(
                        db,
                        table,
                        p0,
                      ).badgeAwardsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.badgeCode == item.code,
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

typedef $$BadgesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BadgesTable,
      Badge,
      $$BadgesTableFilterComposer,
      $$BadgesTableOrderingComposer,
      $$BadgesTableAnnotationComposer,
      $$BadgesTableCreateCompanionBuilder,
      $$BadgesTableUpdateCompanionBuilder,
      (Badge, $$BadgesTableReferences),
      Badge,
      PrefetchHooks Function({bool badgeAwardsRefs})
    >;
typedef $$BadgeAwardsTableCreateCompanionBuilder =
    BadgeAwardsCompanion Function({
      Value<int> id,
      required String badgeCode,
      required int childId,
      Value<DateTime> awardedAt,
      Value<String?> eventRef,
    });
typedef $$BadgeAwardsTableUpdateCompanionBuilder =
    BadgeAwardsCompanion Function({
      Value<int> id,
      Value<String> badgeCode,
      Value<int> childId,
      Value<DateTime> awardedAt,
      Value<String?> eventRef,
    });

final class $$BadgeAwardsTableReferences
    extends BaseReferences<_$AppDatabase, $BadgeAwardsTable, BadgeAward> {
  $$BadgeAwardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BadgesTable _badgeCodeTable(_$AppDatabase db) =>
      db.badges.createAlias('badge_awards__badge_code__badges__code');

  $$BadgesTableProcessedTableManager get badgeCode {
    final $_column = $_itemColumn<String>('badge_code')!;

    final manager = $$BadgesTableTableManager(
      $_db,
      $_db.badges,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_badgeCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('badge_awards__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BadgeAwardsTableFilterComposer
    extends Composer<_$AppDatabase, $BadgeAwardsTable> {
  $$BadgeAwardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get awardedAt => $composableBuilder(
    column: $table.awardedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventRef => $composableBuilder(
    column: $table.eventRef,
    builder: (column) => ColumnFilters(column),
  );

  $$BadgesTableFilterComposer get badgeCode {
    final $$BadgesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.badgeCode,
      referencedTable: $db.badges,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadgesTableFilterComposer(
            $db: $db,
            $table: $db.badges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BadgeAwardsTableOrderingComposer
    extends Composer<_$AppDatabase, $BadgeAwardsTable> {
  $$BadgeAwardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get awardedAt => $composableBuilder(
    column: $table.awardedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventRef => $composableBuilder(
    column: $table.eventRef,
    builder: (column) => ColumnOrderings(column),
  );

  $$BadgesTableOrderingComposer get badgeCode {
    final $$BadgesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.badgeCode,
      referencedTable: $db.badges,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadgesTableOrderingComposer(
            $db: $db,
            $table: $db.badges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BadgeAwardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BadgeAwardsTable> {
  $$BadgeAwardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get awardedAt =>
      $composableBuilder(column: $table.awardedAt, builder: (column) => column);

  GeneratedColumn<String> get eventRef =>
      $composableBuilder(column: $table.eventRef, builder: (column) => column);

  $$BadgesTableAnnotationComposer get badgeCode {
    final $$BadgesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.badgeCode,
      referencedTable: $db.badges,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadgesTableAnnotationComposer(
            $db: $db,
            $table: $db.badges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BadgeAwardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BadgeAwardsTable,
          BadgeAward,
          $$BadgeAwardsTableFilterComposer,
          $$BadgeAwardsTableOrderingComposer,
          $$BadgeAwardsTableAnnotationComposer,
          $$BadgeAwardsTableCreateCompanionBuilder,
          $$BadgeAwardsTableUpdateCompanionBuilder,
          (BadgeAward, $$BadgeAwardsTableReferences),
          BadgeAward,
          PrefetchHooks Function({bool badgeCode, bool childId})
        > {
  $$BadgeAwardsTableTableManager(_$AppDatabase db, $BadgeAwardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BadgeAwardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BadgeAwardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BadgeAwardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> badgeCode = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<DateTime> awardedAt = const Value.absent(),
                Value<String?> eventRef = const Value.absent(),
              }) => BadgeAwardsCompanion(
                id: id,
                badgeCode: badgeCode,
                childId: childId,
                awardedAt: awardedAt,
                eventRef: eventRef,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String badgeCode,
                required int childId,
                Value<DateTime> awardedAt = const Value.absent(),
                Value<String?> eventRef = const Value.absent(),
              }) => BadgeAwardsCompanion.insert(
                id: id,
                badgeCode: badgeCode,
                childId: childId,
                awardedAt: awardedAt,
                eventRef: eventRef,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BadgeAwardsTable, BadgeAward>(table),
                  $$BadgeAwardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({badgeCode = false, childId = false}) {
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
                    if (badgeCode) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.badgeCode,
                        referencedTable: $$BadgeAwardsTableReferences
                            ._badgeCodeTable(db),
                        referencedColumn: $$BadgeAwardsTableReferences
                            ._badgeCodeTable(db)
                            .code,
                      ) as T;
                    }
                    if (childId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.childId,
                        referencedTable: $$BadgeAwardsTableReferences
                            ._childIdTable(db),
                        referencedColumn: $$BadgeAwardsTableReferences
                            ._childIdTable(db)
                            .id,
                      ) as T;
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

typedef $$BadgeAwardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BadgeAwardsTable,
      BadgeAward,
      $$BadgeAwardsTableFilterComposer,
      $$BadgeAwardsTableOrderingComposer,
      $$BadgeAwardsTableAnnotationComposer,
      $$BadgeAwardsTableCreateCompanionBuilder,
      $$BadgeAwardsTableUpdateCompanionBuilder,
      (BadgeAward, $$BadgeAwardsTableReferences),
      BadgeAward,
      PrefetchHooks Function({bool badgeCode, bool childId})
    >;
typedef $$ReportCommentsTableCreateCompanionBuilder =
    ReportCommentsCompanion Function({
      Value<int> id,
      required int childId,
      required String periodType,
      required String periodKey,
      required String content,
      Value<DateTime> updatedAt,
    });
typedef $$ReportCommentsTableUpdateCompanionBuilder =
    ReportCommentsCompanion Function({
      Value<int> id,
      Value<int> childId,
      Value<String> periodType,
      Value<String> periodKey,
      Value<String> content,
      Value<DateTime> updatedAt,
    });

final class $$ReportCommentsTableReferences
    extends BaseReferences<_$AppDatabase, $ReportCommentsTable, ReportComment> {
  $$ReportCommentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('report_comments__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReportCommentsTableFilterComposer
    extends Composer<_$AppDatabase, $ReportCommentsTable> {
  $$ReportCommentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReportCommentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportCommentsTable> {
  $$ReportCommentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReportCommentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportCommentsTable> {
  $$ReportCommentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get periodKey =>
      $composableBuilder(column: $table.periodKey, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReportCommentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReportCommentsTable,
          ReportComment,
          $$ReportCommentsTableFilterComposer,
          $$ReportCommentsTableOrderingComposer,
          $$ReportCommentsTableAnnotationComposer,
          $$ReportCommentsTableCreateCompanionBuilder,
          $$ReportCommentsTableUpdateCompanionBuilder,
          (ReportComment, $$ReportCommentsTableReferences),
          ReportComment,
          PrefetchHooks Function({bool childId})
        > {
  $$ReportCommentsTableTableManager(
    _$AppDatabase db,
    $ReportCommentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportCommentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportCommentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportCommentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<String> periodType = const Value.absent(),
                Value<String> periodKey = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReportCommentsCompanion(
                id: id,
                childId: childId,
                periodType: periodType,
                periodKey: periodKey,
                content: content,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int childId,
                required String periodType,
                required String periodKey,
                required String content,
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReportCommentsCompanion.insert(
                id: id,
                childId: childId,
                periodType: periodType,
                periodKey: periodKey,
                content: content,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReportCommentsTable, ReportComment>(table),
                  $$ReportCommentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
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
                    if (childId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.childId,
                        referencedTable: $$ReportCommentsTableReferences
                            ._childIdTable(db),
                        referencedColumn: $$ReportCommentsTableReferences
                            ._childIdTable(db)
                            .id,
                      ) as T;
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

typedef $$ReportCommentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReportCommentsTable,
      ReportComment,
      $$ReportCommentsTableFilterComposer,
      $$ReportCommentsTableOrderingComposer,
      $$ReportCommentsTableAnnotationComposer,
      $$ReportCommentsTableCreateCompanionBuilder,
      $$ReportCommentsTableUpdateCompanionBuilder,
      (ReportComment, $$ReportCommentsTableReferences),
      ReportComment,
      PrefetchHooks Function({bool childId})
    >;
typedef $$DuolingoSnapshotsTableCreateCompanionBuilder =
    DuolingoSnapshotsCompanion Function({
      Value<int> id,
      required int childId,
      Value<DateTime> checkedAt,
      Value<int?> totalXp,
      Value<int?> streak,
      Value<String?> streakEndDate,
      required String method,
      required bool ok,
    });
typedef $$DuolingoSnapshotsTableUpdateCompanionBuilder =
    DuolingoSnapshotsCompanion Function({
      Value<int> id,
      Value<int> childId,
      Value<DateTime> checkedAt,
      Value<int?> totalXp,
      Value<int?> streak,
      Value<String?> streakEndDate,
      Value<String> method,
      Value<bool> ok,
    });

final class $$DuolingoSnapshotsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DuolingoSnapshotsTable,
          DuolingoSnapshot
        > {
  $$DuolingoSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('duolingo_snapshots__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DuolingoSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $DuolingoSnapshotsTable> {
  $$DuolingoSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streakEndDate => $composableBuilder(
    column: $table.streakEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ok => $composableBuilder(
    column: $table.ok,
    builder: (column) => ColumnFilters(column),
  );

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DuolingoSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $DuolingoSnapshotsTable> {
  $$DuolingoSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streakEndDate => $composableBuilder(
    column: $table.streakEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ok => $composableBuilder(
    column: $table.ok,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DuolingoSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DuolingoSnapshotsTable> {
  $$DuolingoSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get checkedAt =>
      $composableBuilder(column: $table.checkedAt, builder: (column) => column);

  GeneratedColumn<int> get totalXp =>
      $composableBuilder(column: $table.totalXp, builder: (column) => column);

  GeneratedColumn<int> get streak =>
      $composableBuilder(column: $table.streak, builder: (column) => column);

  GeneratedColumn<String> get streakEndDate => $composableBuilder(
    column: $table.streakEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<bool> get ok =>
      $composableBuilder(column: $table.ok, builder: (column) => column);

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DuolingoSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DuolingoSnapshotsTable,
          DuolingoSnapshot,
          $$DuolingoSnapshotsTableFilterComposer,
          $$DuolingoSnapshotsTableOrderingComposer,
          $$DuolingoSnapshotsTableAnnotationComposer,
          $$DuolingoSnapshotsTableCreateCompanionBuilder,
          $$DuolingoSnapshotsTableUpdateCompanionBuilder,
          (DuolingoSnapshot, $$DuolingoSnapshotsTableReferences),
          DuolingoSnapshot,
          PrefetchHooks Function({bool childId})
        > {
  $$DuolingoSnapshotsTableTableManager(
    _$AppDatabase db,
    $DuolingoSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DuolingoSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DuolingoSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DuolingoSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<DateTime> checkedAt = const Value.absent(),
                Value<int?> totalXp = const Value.absent(),
                Value<int?> streak = const Value.absent(),
                Value<String?> streakEndDate = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<bool> ok = const Value.absent(),
              }) => DuolingoSnapshotsCompanion(
                id: id,
                childId: childId,
                checkedAt: checkedAt,
                totalXp: totalXp,
                streak: streak,
                streakEndDate: streakEndDate,
                method: method,
                ok: ok,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int childId,
                Value<DateTime> checkedAt = const Value.absent(),
                Value<int?> totalXp = const Value.absent(),
                Value<int?> streak = const Value.absent(),
                Value<String?> streakEndDate = const Value.absent(),
                required String method,
                required bool ok,
              }) => DuolingoSnapshotsCompanion.insert(
                id: id,
                childId: childId,
                checkedAt: checkedAt,
                totalXp: totalXp,
                streak: streak,
                streakEndDate: streakEndDate,
                method: method,
                ok: ok,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DuolingoSnapshotsTable, DuolingoSnapshot>(table),
                  $$DuolingoSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
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
                    if (childId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.childId,
                        referencedTable: $$DuolingoSnapshotsTableReferences
                            ._childIdTable(db),
                        referencedColumn: $$DuolingoSnapshotsTableReferences
                            ._childIdTable(db)
                            .id,
                      ) as T;
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

typedef $$DuolingoSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DuolingoSnapshotsTable,
      DuolingoSnapshot,
      $$DuolingoSnapshotsTableFilterComposer,
      $$DuolingoSnapshotsTableOrderingComposer,
      $$DuolingoSnapshotsTableAnnotationComposer,
      $$DuolingoSnapshotsTableCreateCompanionBuilder,
      $$DuolingoSnapshotsTableUpdateCompanionBuilder,
      (DuolingoSnapshot, $$DuolingoSnapshotsTableReferences),
      DuolingoSnapshot,
      PrefetchHooks Function({bool childId})
    >;
typedef $$PraiseTemplatesTableCreateCompanionBuilder =
    PraiseTemplatesCompanion Function({
      Value<int> id,
      required String content,
      Value<int> sortOrder,
    });
typedef $$PraiseTemplatesTableUpdateCompanionBuilder =
    PraiseTemplatesCompanion Function({
      Value<int> id,
      Value<String> content,
      Value<int> sortOrder,
    });

class $$PraiseTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $PraiseTemplatesTable> {
  $$PraiseTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PraiseTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PraiseTemplatesTable> {
  $$PraiseTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PraiseTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PraiseTemplatesTable> {
  $$PraiseTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$PraiseTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PraiseTemplatesTable,
          PraiseTemplate,
          $$PraiseTemplatesTableFilterComposer,
          $$PraiseTemplatesTableOrderingComposer,
          $$PraiseTemplatesTableAnnotationComposer,
          $$PraiseTemplatesTableCreateCompanionBuilder,
          $$PraiseTemplatesTableUpdateCompanionBuilder,
          (
            PraiseTemplate,
            BaseReferences<
              _$AppDatabase,
              $PraiseTemplatesTable,
              PraiseTemplate
            >,
          ),
          PraiseTemplate,
          PrefetchHooks Function()
        > {
  $$PraiseTemplatesTableTableManager(
    _$AppDatabase db,
    $PraiseTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PraiseTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PraiseTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PraiseTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => PraiseTemplatesCompanion(
                id: id,
                content: content,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String content,
                Value<int> sortOrder = const Value.absent(),
              }) => PraiseTemplatesCompanion.insert(
                id: id,
                content: content,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PraiseTemplatesTable, PraiseTemplate>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PraiseTemplatesTable,
                    PraiseTemplate
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PraiseTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PraiseTemplatesTable,
      PraiseTemplate,
      $$PraiseTemplatesTableFilterComposer,
      $$PraiseTemplatesTableOrderingComposer,
      $$PraiseTemplatesTableAnnotationComposer,
      $$PraiseTemplatesTableCreateCompanionBuilder,
      $$PraiseTemplatesTableUpdateCompanionBuilder,
      (
        PraiseTemplate,
        BaseReferences<_$AppDatabase, $PraiseTemplatesTable, PraiseTemplate>,
      ),
      PraiseTemplate,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChildrenTableTableManager get children =>
      $$ChildrenTableTableManager(_db, _db.children);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$RewardsTableTableManager get rewards =>
      $$RewardsTableTableManager(_db, _db.rewards);
  $$StickerEventsTableTableManager get stickerEvents =>
      $$StickerEventsTableTableManager(_db, _db.stickerEvents);
  $$RedemptionsTableTableManager get redemptions =>
      $$RedemptionsTableTableManager(_db, _db.redemptions);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db, _db.routines);
  $$RoutineLogsTableTableManager get routineLogs =>
      $$RoutineLogsTableTableManager(_db, _db.routineLogs);
  $$DailyClearsTableTableManager get dailyClears =>
      $$DailyClearsTableTableManager(_db, _db.dailyClears);
  $$DiaryEntriesTableTableManager get diaryEntries =>
      $$DiaryEntriesTableTableManager(_db, _db.diaryEntries);
  $$BadgesTableTableManager get badges =>
      $$BadgesTableTableManager(_db, _db.badges);
  $$BadgeAwardsTableTableManager get badgeAwards =>
      $$BadgeAwardsTableTableManager(_db, _db.badgeAwards);
  $$ReportCommentsTableTableManager get reportComments =>
      $$ReportCommentsTableTableManager(_db, _db.reportComments);
  $$DuolingoSnapshotsTableTableManager get duolingoSnapshots =>
      $$DuolingoSnapshotsTableTableManager(_db, _db.duolingoSnapshots);
  $$PraiseTemplatesTableTableManager get praiseTemplates =>
      $$PraiseTemplatesTableTableManager(_db, _db.praiseTemplates);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
