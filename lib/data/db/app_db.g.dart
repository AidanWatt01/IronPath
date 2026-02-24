// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $MovementsTable extends Movements
    with TableInfo<$MovementsTable, Movement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(""),
  );
  static const VerificationMeta _xpToUnlockMeta = const VerificationMeta(
    'xpToUnlock',
  );
  @override
  late final GeneratedColumn<int> xpToUnlock = GeneratedColumn<int>(
    'xp_to_unlock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _baseXpMeta = const VerificationMeta('baseXp');
  @override
  late final GeneratedColumn<int> baseXp = GeneratedColumn<int>(
    'base_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _xpPerRepMeta = const VerificationMeta(
    'xpPerRep',
  );
  @override
  late final GeneratedColumn<int> xpPerRep = GeneratedColumn<int>(
    'xp_per_rep',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _xpPerSecondMeta = const VerificationMeta(
    'xpPerSecond',
  );
  @override
  late final GeneratedColumn<int> xpPerSecond = GeneratedColumn<int>(
    'xp_per_second',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    difficulty,
    description,
    xpToUnlock,
    baseXp,
    xpPerRep,
    xpPerSecond,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Movement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('xp_to_unlock')) {
      context.handle(
        _xpToUnlockMeta,
        xpToUnlock.isAcceptableOrUnknown(
          data['xp_to_unlock']!,
          _xpToUnlockMeta,
        ),
      );
    }
    if (data.containsKey('base_xp')) {
      context.handle(
        _baseXpMeta,
        baseXp.isAcceptableOrUnknown(data['base_xp']!, _baseXpMeta),
      );
    }
    if (data.containsKey('xp_per_rep')) {
      context.handle(
        _xpPerRepMeta,
        xpPerRep.isAcceptableOrUnknown(data['xp_per_rep']!, _xpPerRepMeta),
      );
    }
    if (data.containsKey('xp_per_second')) {
      context.handle(
        _xpPerSecondMeta,
        xpPerSecond.isAcceptableOrUnknown(
          data['xp_per_second']!,
          _xpPerSecondMeta,
        ),
      );
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
  Movement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Movement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      xpToUnlock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_to_unlock'],
      )!,
      baseXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_xp'],
      )!,
      xpPerRep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_per_rep'],
      )!,
      xpPerSecond: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_per_second'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $MovementsTable createAlias(String alias) {
    return $MovementsTable(attachedDatabase, alias);
  }
}

class Movement extends DataClass implements Insertable<Movement> {
  final String id;
  final String name;
  final String category;
  final int difficulty;
  final String description;
  final int xpToUnlock;
  final int baseXp;
  final int xpPerRep;
  final int xpPerSecond;
  final int sortOrder;
  const Movement({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.description,
    required this.xpToUnlock,
    required this.baseXp,
    required this.xpPerRep,
    required this.xpPerSecond,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['difficulty'] = Variable<int>(difficulty);
    map['description'] = Variable<String>(description);
    map['xp_to_unlock'] = Variable<int>(xpToUnlock);
    map['base_xp'] = Variable<int>(baseXp);
    map['xp_per_rep'] = Variable<int>(xpPerRep);
    map['xp_per_second'] = Variable<int>(xpPerSecond);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  MovementsCompanion toCompanion(bool nullToAbsent) {
    return MovementsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      difficulty: Value(difficulty),
      description: Value(description),
      xpToUnlock: Value(xpToUnlock),
      baseXp: Value(baseXp),
      xpPerRep: Value(xpPerRep),
      xpPerSecond: Value(xpPerSecond),
      sortOrder: Value(sortOrder),
    );
  }

  factory Movement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Movement(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      description: serializer.fromJson<String>(json['description']),
      xpToUnlock: serializer.fromJson<int>(json['xpToUnlock']),
      baseXp: serializer.fromJson<int>(json['baseXp']),
      xpPerRep: serializer.fromJson<int>(json['xpPerRep']),
      xpPerSecond: serializer.fromJson<int>(json['xpPerSecond']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'difficulty': serializer.toJson<int>(difficulty),
      'description': serializer.toJson<String>(description),
      'xpToUnlock': serializer.toJson<int>(xpToUnlock),
      'baseXp': serializer.toJson<int>(baseXp),
      'xpPerRep': serializer.toJson<int>(xpPerRep),
      'xpPerSecond': serializer.toJson<int>(xpPerSecond),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Movement copyWith({
    String? id,
    String? name,
    String? category,
    int? difficulty,
    String? description,
    int? xpToUnlock,
    int? baseXp,
    int? xpPerRep,
    int? xpPerSecond,
    int? sortOrder,
  }) => Movement(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    difficulty: difficulty ?? this.difficulty,
    description: description ?? this.description,
    xpToUnlock: xpToUnlock ?? this.xpToUnlock,
    baseXp: baseXp ?? this.baseXp,
    xpPerRep: xpPerRep ?? this.xpPerRep,
    xpPerSecond: xpPerSecond ?? this.xpPerSecond,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Movement copyWithCompanion(MovementsCompanion data) {
    return Movement(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      description: data.description.present
          ? data.description.value
          : this.description,
      xpToUnlock: data.xpToUnlock.present
          ? data.xpToUnlock.value
          : this.xpToUnlock,
      baseXp: data.baseXp.present ? data.baseXp.value : this.baseXp,
      xpPerRep: data.xpPerRep.present ? data.xpPerRep.value : this.xpPerRep,
      xpPerSecond: data.xpPerSecond.present
          ? data.xpPerSecond.value
          : this.xpPerSecond,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Movement(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('description: $description, ')
          ..write('xpToUnlock: $xpToUnlock, ')
          ..write('baseXp: $baseXp, ')
          ..write('xpPerRep: $xpPerRep, ')
          ..write('xpPerSecond: $xpPerSecond, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    difficulty,
    description,
    xpToUnlock,
    baseXp,
    xpPerRep,
    xpPerSecond,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Movement &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.difficulty == this.difficulty &&
          other.description == this.description &&
          other.xpToUnlock == this.xpToUnlock &&
          other.baseXp == this.baseXp &&
          other.xpPerRep == this.xpPerRep &&
          other.xpPerSecond == this.xpPerSecond &&
          other.sortOrder == this.sortOrder);
}

class MovementsCompanion extends UpdateCompanion<Movement> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<int> difficulty;
  final Value<String> description;
  final Value<int> xpToUnlock;
  final Value<int> baseXp;
  final Value<int> xpPerRep;
  final Value<int> xpPerSecond;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const MovementsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.description = const Value.absent(),
    this.xpToUnlock = const Value.absent(),
    this.baseXp = const Value.absent(),
    this.xpPerRep = const Value.absent(),
    this.xpPerSecond = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovementsCompanion.insert({
    required String id,
    required String name,
    required String category,
    required int difficulty,
    this.description = const Value.absent(),
    this.xpToUnlock = const Value.absent(),
    this.baseXp = const Value.absent(),
    this.xpPerRep = const Value.absent(),
    this.xpPerSecond = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       difficulty = Value(difficulty);
  static Insertable<Movement> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<int>? difficulty,
    Expression<String>? description,
    Expression<int>? xpToUnlock,
    Expression<int>? baseXp,
    Expression<int>? xpPerRep,
    Expression<int>? xpPerSecond,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (difficulty != null) 'difficulty': difficulty,
      if (description != null) 'description': description,
      if (xpToUnlock != null) 'xp_to_unlock': xpToUnlock,
      if (baseXp != null) 'base_xp': baseXp,
      if (xpPerRep != null) 'xp_per_rep': xpPerRep,
      if (xpPerSecond != null) 'xp_per_second': xpPerSecond,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? category,
    Value<int>? difficulty,
    Value<String>? description,
    Value<int>? xpToUnlock,
    Value<int>? baseXp,
    Value<int>? xpPerRep,
    Value<int>? xpPerSecond,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return MovementsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      xpToUnlock: xpToUnlock ?? this.xpToUnlock,
      baseXp: baseXp ?? this.baseXp,
      xpPerRep: xpPerRep ?? this.xpPerRep,
      xpPerSecond: xpPerSecond ?? this.xpPerSecond,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (xpToUnlock.present) {
      map['xp_to_unlock'] = Variable<int>(xpToUnlock.value);
    }
    if (baseXp.present) {
      map['base_xp'] = Variable<int>(baseXp.value);
    }
    if (xpPerRep.present) {
      map['xp_per_rep'] = Variable<int>(xpPerRep.value);
    }
    if (xpPerSecond.present) {
      map['xp_per_second'] = Variable<int>(xpPerSecond.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovementsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('description: $description, ')
          ..write('xpToUnlock: $xpToUnlock, ')
          ..write('baseXp: $baseXp, ')
          ..write('xpPerRep: $xpPerRep, ')
          ..write('xpPerSecond: $xpPerSecond, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovementPrereqsTable extends MovementPrereqs
    with TableInfo<$MovementPrereqsTable, MovementPrereq> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovementPrereqsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _movementIdMeta = const VerificationMeta(
    'movementId',
  );
  @override
  late final GeneratedColumn<String> movementId = GeneratedColumn<String>(
    'movement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES movements (id)',
    ),
  );
  static const VerificationMeta _prereqMovementIdMeta = const VerificationMeta(
    'prereqMovementId',
  );
  @override
  late final GeneratedColumn<String> prereqMovementId = GeneratedColumn<String>(
    'prereq_movement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES movements (id)',
    ),
  );
  static const VerificationMeta _prereqTypeMeta = const VerificationMeta(
    'prereqType',
  );
  @override
  late final GeneratedColumn<String> prereqType = GeneratedColumn<String>(
    'prereq_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant("unlocked"),
  );
  @override
  List<GeneratedColumn> get $columns => [
    movementId,
    prereqMovementId,
    prereqType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movement_prereqs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovementPrereq> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('movement_id')) {
      context.handle(
        _movementIdMeta,
        movementId.isAcceptableOrUnknown(data['movement_id']!, _movementIdMeta),
      );
    } else if (isInserting) {
      context.missing(_movementIdMeta);
    }
    if (data.containsKey('prereq_movement_id')) {
      context.handle(
        _prereqMovementIdMeta,
        prereqMovementId.isAcceptableOrUnknown(
          data['prereq_movement_id']!,
          _prereqMovementIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_prereqMovementIdMeta);
    }
    if (data.containsKey('prereq_type')) {
      context.handle(
        _prereqTypeMeta,
        prereqType.isAcceptableOrUnknown(data['prereq_type']!, _prereqTypeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {movementId, prereqMovementId};
  @override
  MovementPrereq map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovementPrereq(
      movementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement_id'],
      )!,
      prereqMovementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prereq_movement_id'],
      )!,
      prereqType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prereq_type'],
      )!,
    );
  }

  @override
  $MovementPrereqsTable createAlias(String alias) {
    return $MovementPrereqsTable(attachedDatabase, alias);
  }
}

class MovementPrereq extends DataClass implements Insertable<MovementPrereq> {
  final String movementId;
  final String prereqMovementId;
  final String prereqType;
  const MovementPrereq({
    required this.movementId,
    required this.prereqMovementId,
    required this.prereqType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['movement_id'] = Variable<String>(movementId);
    map['prereq_movement_id'] = Variable<String>(prereqMovementId);
    map['prereq_type'] = Variable<String>(prereqType);
    return map;
  }

  MovementPrereqsCompanion toCompanion(bool nullToAbsent) {
    return MovementPrereqsCompanion(
      movementId: Value(movementId),
      prereqMovementId: Value(prereqMovementId),
      prereqType: Value(prereqType),
    );
  }

  factory MovementPrereq.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovementPrereq(
      movementId: serializer.fromJson<String>(json['movementId']),
      prereqMovementId: serializer.fromJson<String>(json['prereqMovementId']),
      prereqType: serializer.fromJson<String>(json['prereqType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'movementId': serializer.toJson<String>(movementId),
      'prereqMovementId': serializer.toJson<String>(prereqMovementId),
      'prereqType': serializer.toJson<String>(prereqType),
    };
  }

  MovementPrereq copyWith({
    String? movementId,
    String? prereqMovementId,
    String? prereqType,
  }) => MovementPrereq(
    movementId: movementId ?? this.movementId,
    prereqMovementId: prereqMovementId ?? this.prereqMovementId,
    prereqType: prereqType ?? this.prereqType,
  );
  MovementPrereq copyWithCompanion(MovementPrereqsCompanion data) {
    return MovementPrereq(
      movementId: data.movementId.present
          ? data.movementId.value
          : this.movementId,
      prereqMovementId: data.prereqMovementId.present
          ? data.prereqMovementId.value
          : this.prereqMovementId,
      prereqType: data.prereqType.present
          ? data.prereqType.value
          : this.prereqType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovementPrereq(')
          ..write('movementId: $movementId, ')
          ..write('prereqMovementId: $prereqMovementId, ')
          ..write('prereqType: $prereqType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(movementId, prereqMovementId, prereqType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovementPrereq &&
          other.movementId == this.movementId &&
          other.prereqMovementId == this.prereqMovementId &&
          other.prereqType == this.prereqType);
}

class MovementPrereqsCompanion extends UpdateCompanion<MovementPrereq> {
  final Value<String> movementId;
  final Value<String> prereqMovementId;
  final Value<String> prereqType;
  final Value<int> rowid;
  const MovementPrereqsCompanion({
    this.movementId = const Value.absent(),
    this.prereqMovementId = const Value.absent(),
    this.prereqType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovementPrereqsCompanion.insert({
    required String movementId,
    required String prereqMovementId,
    this.prereqType = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : movementId = Value(movementId),
       prereqMovementId = Value(prereqMovementId);
  static Insertable<MovementPrereq> custom({
    Expression<String>? movementId,
    Expression<String>? prereqMovementId,
    Expression<String>? prereqType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (movementId != null) 'movement_id': movementId,
      if (prereqMovementId != null) 'prereq_movement_id': prereqMovementId,
      if (prereqType != null) 'prereq_type': prereqType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovementPrereqsCompanion copyWith({
    Value<String>? movementId,
    Value<String>? prereqMovementId,
    Value<String>? prereqType,
    Value<int>? rowid,
  }) {
    return MovementPrereqsCompanion(
      movementId: movementId ?? this.movementId,
      prereqMovementId: prereqMovementId ?? this.prereqMovementId,
      prereqType: prereqType ?? this.prereqType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (movementId.present) {
      map['movement_id'] = Variable<String>(movementId.value);
    }
    if (prereqMovementId.present) {
      map['prereq_movement_id'] = Variable<String>(prereqMovementId.value);
    }
    if (prereqType.present) {
      map['prereq_type'] = Variable<String>(prereqType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovementPrereqsCompanion(')
          ..write('movementId: $movementId, ')
          ..write('prereqMovementId: $prereqMovementId, ')
          ..write('prereqType: $prereqType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovementProgressesTable extends MovementProgresses
    with TableInfo<$MovementProgressesTable, MovementProgress> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovementProgressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _movementIdMeta = const VerificationMeta(
    'movementId',
  );
  @override
  late final GeneratedColumn<String> movementId = GeneratedColumn<String>(
    'movement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES movements (id)',
    ),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant("locked"),
  );
  static const VerificationMeta _totalXpMeta = const VerificationMeta(
    'totalXp',
  );
  @override
  late final GeneratedColumn<int> totalXp = GeneratedColumn<int>(
    'total_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _masteredAtMeta = const VerificationMeta(
    'masteredAt',
  );
  @override
  late final GeneratedColumn<DateTime> masteredAt = GeneratedColumn<DateTime>(
    'mastered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bestRepsMeta = const VerificationMeta(
    'bestReps',
  );
  @override
  late final GeneratedColumn<int> bestReps = GeneratedColumn<int>(
    'best_reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestHoldSecondsMeta = const VerificationMeta(
    'bestHoldSeconds',
  );
  @override
  late final GeneratedColumn<int> bestHoldSeconds = GeneratedColumn<int>(
    'best_hold_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestFormScoreMeta = const VerificationMeta(
    'bestFormScore',
  );
  @override
  late final GeneratedColumn<int> bestFormScore = GeneratedColumn<int>(
    'best_form_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    movementId,
    state,
    totalXp,
    unlockedAt,
    masteredAt,
    bestReps,
    bestHoldSeconds,
    bestFormScore,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movement_progresses';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovementProgress> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('movement_id')) {
      context.handle(
        _movementIdMeta,
        movementId.isAcceptableOrUnknown(data['movement_id']!, _movementIdMeta),
      );
    } else if (isInserting) {
      context.missing(_movementIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('total_xp')) {
      context.handle(
        _totalXpMeta,
        totalXp.isAcceptableOrUnknown(data['total_xp']!, _totalXpMeta),
      );
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    if (data.containsKey('mastered_at')) {
      context.handle(
        _masteredAtMeta,
        masteredAt.isAcceptableOrUnknown(data['mastered_at']!, _masteredAtMeta),
      );
    }
    if (data.containsKey('best_reps')) {
      context.handle(
        _bestRepsMeta,
        bestReps.isAcceptableOrUnknown(data['best_reps']!, _bestRepsMeta),
      );
    }
    if (data.containsKey('best_hold_seconds')) {
      context.handle(
        _bestHoldSecondsMeta,
        bestHoldSeconds.isAcceptableOrUnknown(
          data['best_hold_seconds']!,
          _bestHoldSecondsMeta,
        ),
      );
    }
    if (data.containsKey('best_form_score')) {
      context.handle(
        _bestFormScoreMeta,
        bestFormScore.isAcceptableOrUnknown(
          data['best_form_score']!,
          _bestFormScoreMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {movementId};
  @override
  MovementProgress map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovementProgress(
      movementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      totalXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_xp'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      ),
      masteredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}mastered_at'],
      ),
      bestReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_reps'],
      )!,
      bestHoldSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_hold_seconds'],
      )!,
      bestFormScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_form_score'],
      )!,
    );
  }

  @override
  $MovementProgressesTable createAlias(String alias) {
    return $MovementProgressesTable(attachedDatabase, alias);
  }
}

class MovementProgress extends DataClass
    implements Insertable<MovementProgress> {
  final String movementId;
  final String state;
  final int totalXp;
  final DateTime? unlockedAt;
  final DateTime? masteredAt;
  final int bestReps;
  final int bestHoldSeconds;
  final int bestFormScore;
  const MovementProgress({
    required this.movementId,
    required this.state,
    required this.totalXp,
    this.unlockedAt,
    this.masteredAt,
    required this.bestReps,
    required this.bestHoldSeconds,
    required this.bestFormScore,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['movement_id'] = Variable<String>(movementId);
    map['state'] = Variable<String>(state);
    map['total_xp'] = Variable<int>(totalXp);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    if (!nullToAbsent || masteredAt != null) {
      map['mastered_at'] = Variable<DateTime>(masteredAt);
    }
    map['best_reps'] = Variable<int>(bestReps);
    map['best_hold_seconds'] = Variable<int>(bestHoldSeconds);
    map['best_form_score'] = Variable<int>(bestFormScore);
    return map;
  }

  MovementProgressesCompanion toCompanion(bool nullToAbsent) {
    return MovementProgressesCompanion(
      movementId: Value(movementId),
      state: Value(state),
      totalXp: Value(totalXp),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
      masteredAt: masteredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(masteredAt),
      bestReps: Value(bestReps),
      bestHoldSeconds: Value(bestHoldSeconds),
      bestFormScore: Value(bestFormScore),
    );
  }

  factory MovementProgress.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovementProgress(
      movementId: serializer.fromJson<String>(json['movementId']),
      state: serializer.fromJson<String>(json['state']),
      totalXp: serializer.fromJson<int>(json['totalXp']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
      masteredAt: serializer.fromJson<DateTime?>(json['masteredAt']),
      bestReps: serializer.fromJson<int>(json['bestReps']),
      bestHoldSeconds: serializer.fromJson<int>(json['bestHoldSeconds']),
      bestFormScore: serializer.fromJson<int>(json['bestFormScore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'movementId': serializer.toJson<String>(movementId),
      'state': serializer.toJson<String>(state),
      'totalXp': serializer.toJson<int>(totalXp),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
      'masteredAt': serializer.toJson<DateTime?>(masteredAt),
      'bestReps': serializer.toJson<int>(bestReps),
      'bestHoldSeconds': serializer.toJson<int>(bestHoldSeconds),
      'bestFormScore': serializer.toJson<int>(bestFormScore),
    };
  }

  MovementProgress copyWith({
    String? movementId,
    String? state,
    int? totalXp,
    Value<DateTime?> unlockedAt = const Value.absent(),
    Value<DateTime?> masteredAt = const Value.absent(),
    int? bestReps,
    int? bestHoldSeconds,
    int? bestFormScore,
  }) => MovementProgress(
    movementId: movementId ?? this.movementId,
    state: state ?? this.state,
    totalXp: totalXp ?? this.totalXp,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
    masteredAt: masteredAt.present ? masteredAt.value : this.masteredAt,
    bestReps: bestReps ?? this.bestReps,
    bestHoldSeconds: bestHoldSeconds ?? this.bestHoldSeconds,
    bestFormScore: bestFormScore ?? this.bestFormScore,
  );
  MovementProgress copyWithCompanion(MovementProgressesCompanion data) {
    return MovementProgress(
      movementId: data.movementId.present
          ? data.movementId.value
          : this.movementId,
      state: data.state.present ? data.state.value : this.state,
      totalXp: data.totalXp.present ? data.totalXp.value : this.totalXp,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
      masteredAt: data.masteredAt.present
          ? data.masteredAt.value
          : this.masteredAt,
      bestReps: data.bestReps.present ? data.bestReps.value : this.bestReps,
      bestHoldSeconds: data.bestHoldSeconds.present
          ? data.bestHoldSeconds.value
          : this.bestHoldSeconds,
      bestFormScore: data.bestFormScore.present
          ? data.bestFormScore.value
          : this.bestFormScore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovementProgress(')
          ..write('movementId: $movementId, ')
          ..write('state: $state, ')
          ..write('totalXp: $totalXp, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('masteredAt: $masteredAt, ')
          ..write('bestReps: $bestReps, ')
          ..write('bestHoldSeconds: $bestHoldSeconds, ')
          ..write('bestFormScore: $bestFormScore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    movementId,
    state,
    totalXp,
    unlockedAt,
    masteredAt,
    bestReps,
    bestHoldSeconds,
    bestFormScore,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovementProgress &&
          other.movementId == this.movementId &&
          other.state == this.state &&
          other.totalXp == this.totalXp &&
          other.unlockedAt == this.unlockedAt &&
          other.masteredAt == this.masteredAt &&
          other.bestReps == this.bestReps &&
          other.bestHoldSeconds == this.bestHoldSeconds &&
          other.bestFormScore == this.bestFormScore);
}

class MovementProgressesCompanion extends UpdateCompanion<MovementProgress> {
  final Value<String> movementId;
  final Value<String> state;
  final Value<int> totalXp;
  final Value<DateTime?> unlockedAt;
  final Value<DateTime?> masteredAt;
  final Value<int> bestReps;
  final Value<int> bestHoldSeconds;
  final Value<int> bestFormScore;
  final Value<int> rowid;
  const MovementProgressesCompanion({
    this.movementId = const Value.absent(),
    this.state = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.masteredAt = const Value.absent(),
    this.bestReps = const Value.absent(),
    this.bestHoldSeconds = const Value.absent(),
    this.bestFormScore = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovementProgressesCompanion.insert({
    required String movementId,
    this.state = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.masteredAt = const Value.absent(),
    this.bestReps = const Value.absent(),
    this.bestHoldSeconds = const Value.absent(),
    this.bestFormScore = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : movementId = Value(movementId);
  static Insertable<MovementProgress> custom({
    Expression<String>? movementId,
    Expression<String>? state,
    Expression<int>? totalXp,
    Expression<DateTime>? unlockedAt,
    Expression<DateTime>? masteredAt,
    Expression<int>? bestReps,
    Expression<int>? bestHoldSeconds,
    Expression<int>? bestFormScore,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (movementId != null) 'movement_id': movementId,
      if (state != null) 'state': state,
      if (totalXp != null) 'total_xp': totalXp,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (masteredAt != null) 'mastered_at': masteredAt,
      if (bestReps != null) 'best_reps': bestReps,
      if (bestHoldSeconds != null) 'best_hold_seconds': bestHoldSeconds,
      if (bestFormScore != null) 'best_form_score': bestFormScore,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovementProgressesCompanion copyWith({
    Value<String>? movementId,
    Value<String>? state,
    Value<int>? totalXp,
    Value<DateTime?>? unlockedAt,
    Value<DateTime?>? masteredAt,
    Value<int>? bestReps,
    Value<int>? bestHoldSeconds,
    Value<int>? bestFormScore,
    Value<int>? rowid,
  }) {
    return MovementProgressesCompanion(
      movementId: movementId ?? this.movementId,
      state: state ?? this.state,
      totalXp: totalXp ?? this.totalXp,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      masteredAt: masteredAt ?? this.masteredAt,
      bestReps: bestReps ?? this.bestReps,
      bestHoldSeconds: bestHoldSeconds ?? this.bestHoldSeconds,
      bestFormScore: bestFormScore ?? this.bestFormScore,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (movementId.present) {
      map['movement_id'] = Variable<String>(movementId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (totalXp.present) {
      map['total_xp'] = Variable<int>(totalXp.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (masteredAt.present) {
      map['mastered_at'] = Variable<DateTime>(masteredAt.value);
    }
    if (bestReps.present) {
      map['best_reps'] = Variable<int>(bestReps.value);
    }
    if (bestHoldSeconds.present) {
      map['best_hold_seconds'] = Variable<int>(bestHoldSeconds.value);
    }
    if (bestFormScore.present) {
      map['best_form_score'] = Variable<int>(bestFormScore.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovementProgressesCompanion(')
          ..write('movementId: $movementId, ')
          ..write('state: $state, ')
          ..write('totalXp: $totalXp, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('masteredAt: $masteredAt, ')
          ..write('bestReps: $bestReps, ')
          ..write('bestHoldSeconds: $bestHoldSeconds, ')
          ..write('bestFormScore: $bestFormScore, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutsTable extends Workouts with TableInfo<$WorkoutsTable, Workout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, startedAt, durationSeconds, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Workout> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workout(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }
}

class Workout extends DataClass implements Insertable<Workout> {
  final int id;
  final DateTime startedAt;
  final int durationSeconds;
  final String? notes;
  const Workout({
    required this.id,
    required this.startedAt,
    required this.durationSeconds,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      durationSeconds: Value(durationSeconds),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Workout.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workout(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Workout copyWith({
    int? id,
    DateTime? startedAt,
    int? durationSeconds,
    Value<String?> notes = const Value.absent(),
  }) => Workout(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    notes: notes.present ? notes.value : this.notes,
  );
  Workout copyWithCompanion(WorkoutsCompanion data) {
    return Workout(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workout(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, startedAt, durationSeconds, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workout &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.notes == this.notes);
}

class WorkoutsCompanion extends UpdateCompanion<Workout> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<int> durationSeconds;
  final Value<String?> notes;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.notes = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.durationSeconds = const Value.absent(),
    this.notes = const Value.absent(),
  }) : startedAt = Value(startedAt);
  static Insertable<Workout> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<int>? durationSeconds,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (notes != null) 'notes': notes,
    });
  }

  WorkoutsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<int>? durationSeconds,
    Value<String?>? notes,
  }) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _movementIdMeta = const VerificationMeta(
    'movementId',
  );
  @override
  late final GeneratedColumn<String> movementId = GeneratedColumn<String>(
    'movement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES movements (id)',
    ),
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
    'workout_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workouts (id)',
    ),
  );
  static const VerificationMeta _setIndexMeta = const VerificationMeta(
    'setIndex',
  );
  @override
  late final GeneratedColumn<int> setIndex = GeneratedColumn<int>(
    'set_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumn<int> sets = GeneratedColumn<int>(
    'sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _holdSecondsMeta = const VerificationMeta(
    'holdSeconds',
  );
  @override
  late final GeneratedColumn<int> holdSeconds = GeneratedColumn<int>(
    'hold_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _formScoreMeta = const VerificationMeta(
    'formScore',
  );
  @override
  late final GeneratedColumn<int> formScore = GeneratedColumn<int>(
    'form_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xpEarnedMeta = const VerificationMeta(
    'xpEarned',
  );
  @override
  late final GeneratedColumn<int> xpEarned = GeneratedColumn<int>(
    'xp_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    movementId,
    workoutId,
    setIndex,
    sets,
    startedAt,
    durationSeconds,
    reps,
    holdSeconds,
    formScore,
    notes,
    xpEarned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('movement_id')) {
      context.handle(
        _movementIdMeta,
        movementId.isAcceptableOrUnknown(data['movement_id']!, _movementIdMeta),
      );
    } else if (isInserting) {
      context.missing(_movementIdMeta);
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    }
    if (data.containsKey('set_index')) {
      context.handle(
        _setIndexMeta,
        setIndex.isAcceptableOrUnknown(data['set_index']!, _setIndexMeta),
      );
    }
    if (data.containsKey('sets')) {
      context.handle(
        _setsMeta,
        sets.isAcceptableOrUnknown(data['sets']!, _setsMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('hold_seconds')) {
      context.handle(
        _holdSecondsMeta,
        holdSeconds.isAcceptableOrUnknown(
          data['hold_seconds']!,
          _holdSecondsMeta,
        ),
      );
    }
    if (data.containsKey('form_score')) {
      context.handle(
        _formScoreMeta,
        formScore.isAcceptableOrUnknown(data['form_score']!, _formScoreMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('xp_earned')) {
      context.handle(
        _xpEarnedMeta,
        xpEarned.isAcceptableOrUnknown(data['xp_earned']!, _xpEarnedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      movementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement_id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workout_id'],
      ),
      setIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_index'],
      )!,
      sets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sets'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      holdSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hold_seconds'],
      )!,
      formScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}form_score'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      xpEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_earned'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final String movementId;
  final int? workoutId;
  final int setIndex;
  final int sets;
  final DateTime startedAt;
  final int durationSeconds;
  final int reps;
  final int holdSeconds;
  final int formScore;
  final String? notes;
  final int xpEarned;
  const Session({
    required this.id,
    required this.movementId,
    this.workoutId,
    required this.setIndex,
    required this.sets,
    required this.startedAt,
    required this.durationSeconds,
    required this.reps,
    required this.holdSeconds,
    required this.formScore,
    this.notes,
    required this.xpEarned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['movement_id'] = Variable<String>(movementId);
    if (!nullToAbsent || workoutId != null) {
      map['workout_id'] = Variable<int>(workoutId);
    }
    map['set_index'] = Variable<int>(setIndex);
    map['sets'] = Variable<int>(sets);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['reps'] = Variable<int>(reps);
    map['hold_seconds'] = Variable<int>(holdSeconds);
    map['form_score'] = Variable<int>(formScore);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['xp_earned'] = Variable<int>(xpEarned);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      movementId: Value(movementId),
      workoutId: workoutId == null && nullToAbsent
          ? const Value.absent()
          : Value(workoutId),
      setIndex: Value(setIndex),
      sets: Value(sets),
      startedAt: Value(startedAt),
      durationSeconds: Value(durationSeconds),
      reps: Value(reps),
      holdSeconds: Value(holdSeconds),
      formScore: Value(formScore),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      xpEarned: Value(xpEarned),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      movementId: serializer.fromJson<String>(json['movementId']),
      workoutId: serializer.fromJson<int?>(json['workoutId']),
      setIndex: serializer.fromJson<int>(json['setIndex']),
      sets: serializer.fromJson<int>(json['sets']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      reps: serializer.fromJson<int>(json['reps']),
      holdSeconds: serializer.fromJson<int>(json['holdSeconds']),
      formScore: serializer.fromJson<int>(json['formScore']),
      notes: serializer.fromJson<String?>(json['notes']),
      xpEarned: serializer.fromJson<int>(json['xpEarned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'movementId': serializer.toJson<String>(movementId),
      'workoutId': serializer.toJson<int?>(workoutId),
      'setIndex': serializer.toJson<int>(setIndex),
      'sets': serializer.toJson<int>(sets),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'reps': serializer.toJson<int>(reps),
      'holdSeconds': serializer.toJson<int>(holdSeconds),
      'formScore': serializer.toJson<int>(formScore),
      'notes': serializer.toJson<String?>(notes),
      'xpEarned': serializer.toJson<int>(xpEarned),
    };
  }

  Session copyWith({
    int? id,
    String? movementId,
    Value<int?> workoutId = const Value.absent(),
    int? setIndex,
    int? sets,
    DateTime? startedAt,
    int? durationSeconds,
    int? reps,
    int? holdSeconds,
    int? formScore,
    Value<String?> notes = const Value.absent(),
    int? xpEarned,
  }) => Session(
    id: id ?? this.id,
    movementId: movementId ?? this.movementId,
    workoutId: workoutId.present ? workoutId.value : this.workoutId,
    setIndex: setIndex ?? this.setIndex,
    sets: sets ?? this.sets,
    startedAt: startedAt ?? this.startedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    reps: reps ?? this.reps,
    holdSeconds: holdSeconds ?? this.holdSeconds,
    formScore: formScore ?? this.formScore,
    notes: notes.present ? notes.value : this.notes,
    xpEarned: xpEarned ?? this.xpEarned,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      movementId: data.movementId.present
          ? data.movementId.value
          : this.movementId,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      setIndex: data.setIndex.present ? data.setIndex.value : this.setIndex,
      sets: data.sets.present ? data.sets.value : this.sets,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      reps: data.reps.present ? data.reps.value : this.reps,
      holdSeconds: data.holdSeconds.present
          ? data.holdSeconds.value
          : this.holdSeconds,
      formScore: data.formScore.present ? data.formScore.value : this.formScore,
      notes: data.notes.present ? data.notes.value : this.notes,
      xpEarned: data.xpEarned.present ? data.xpEarned.value : this.xpEarned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('movementId: $movementId, ')
          ..write('workoutId: $workoutId, ')
          ..write('setIndex: $setIndex, ')
          ..write('sets: $sets, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('reps: $reps, ')
          ..write('holdSeconds: $holdSeconds, ')
          ..write('formScore: $formScore, ')
          ..write('notes: $notes, ')
          ..write('xpEarned: $xpEarned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    movementId,
    workoutId,
    setIndex,
    sets,
    startedAt,
    durationSeconds,
    reps,
    holdSeconds,
    formScore,
    notes,
    xpEarned,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.movementId == this.movementId &&
          other.workoutId == this.workoutId &&
          other.setIndex == this.setIndex &&
          other.sets == this.sets &&
          other.startedAt == this.startedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.reps == this.reps &&
          other.holdSeconds == this.holdSeconds &&
          other.formScore == this.formScore &&
          other.notes == this.notes &&
          other.xpEarned == this.xpEarned);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<String> movementId;
  final Value<int?> workoutId;
  final Value<int> setIndex;
  final Value<int> sets;
  final Value<DateTime> startedAt;
  final Value<int> durationSeconds;
  final Value<int> reps;
  final Value<int> holdSeconds;
  final Value<int> formScore;
  final Value<String?> notes;
  final Value<int> xpEarned;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.movementId = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.setIndex = const Value.absent(),
    this.sets = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.reps = const Value.absent(),
    this.holdSeconds = const Value.absent(),
    this.formScore = const Value.absent(),
    this.notes = const Value.absent(),
    this.xpEarned = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String movementId,
    this.workoutId = const Value.absent(),
    this.setIndex = const Value.absent(),
    this.sets = const Value.absent(),
    required DateTime startedAt,
    this.durationSeconds = const Value.absent(),
    this.reps = const Value.absent(),
    this.holdSeconds = const Value.absent(),
    this.formScore = const Value.absent(),
    this.notes = const Value.absent(),
    this.xpEarned = const Value.absent(),
  }) : movementId = Value(movementId),
       startedAt = Value(startedAt);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<String>? movementId,
    Expression<int>? workoutId,
    Expression<int>? setIndex,
    Expression<int>? sets,
    Expression<DateTime>? startedAt,
    Expression<int>? durationSeconds,
    Expression<int>? reps,
    Expression<int>? holdSeconds,
    Expression<int>? formScore,
    Expression<String>? notes,
    Expression<int>? xpEarned,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (movementId != null) 'movement_id': movementId,
      if (workoutId != null) 'workout_id': workoutId,
      if (setIndex != null) 'set_index': setIndex,
      if (sets != null) 'sets': sets,
      if (startedAt != null) 'started_at': startedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (reps != null) 'reps': reps,
      if (holdSeconds != null) 'hold_seconds': holdSeconds,
      if (formScore != null) 'form_score': formScore,
      if (notes != null) 'notes': notes,
      if (xpEarned != null) 'xp_earned': xpEarned,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? movementId,
    Value<int?>? workoutId,
    Value<int>? setIndex,
    Value<int>? sets,
    Value<DateTime>? startedAt,
    Value<int>? durationSeconds,
    Value<int>? reps,
    Value<int>? holdSeconds,
    Value<int>? formScore,
    Value<String?>? notes,
    Value<int>? xpEarned,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      movementId: movementId ?? this.movementId,
      workoutId: workoutId ?? this.workoutId,
      setIndex: setIndex ?? this.setIndex,
      sets: sets ?? this.sets,
      startedAt: startedAt ?? this.startedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      reps: reps ?? this.reps,
      holdSeconds: holdSeconds ?? this.holdSeconds,
      formScore: formScore ?? this.formScore,
      notes: notes ?? this.notes,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (movementId.present) {
      map['movement_id'] = Variable<String>(movementId.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (setIndex.present) {
      map['set_index'] = Variable<int>(setIndex.value);
    }
    if (sets.present) {
      map['sets'] = Variable<int>(sets.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (holdSeconds.present) {
      map['hold_seconds'] = Variable<int>(holdSeconds.value);
    }
    if (formScore.present) {
      map['form_score'] = Variable<int>(formScore.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (xpEarned.present) {
      map['xp_earned'] = Variable<int>(xpEarned.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('movementId: $movementId, ')
          ..write('workoutId: $workoutId, ')
          ..write('setIndex: $setIndex, ')
          ..write('sets: $sets, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('reps: $reps, ')
          ..write('holdSeconds: $holdSeconds, ')
          ..write('formScore: $formScore, ')
          ..write('notes: $notes, ')
          ..write('xpEarned: $xpEarned')
          ..write(')'))
        .toString();
  }
}

class $UserStatsTable extends UserStats
    with TableInfo<$UserStatsTable, UserStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _totalXpMeta = const VerificationMeta(
    'totalXp',
  );
  @override
  late final GeneratedColumn<int> totalXp = GeneratedColumn<int>(
    'total_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _perkPointsMeta = const VerificationMeta(
    'perkPoints',
  );
  @override
  late final GeneratedColumn<int> perkPoints = GeneratedColumn<int>(
    'perk_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _coinsMeta = const VerificationMeta('coins');
  @override
  late final GeneratedColumn<int> coins = GeneratedColumn<int>(
    'coins',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentStreakMeta = const VerificationMeta(
    'currentStreak',
  );
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
    'current_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestStreakMeta = const VerificationMeta(
    'bestStreak',
  );
  @override
  late final GeneratedColumn<int> bestStreak = GeneratedColumn<int>(
    'best_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastActiveDateMeta = const VerificationMeta(
    'lastActiveDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastActiveDate =
      GeneratedColumn<DateTime>(
        'last_active_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    totalXp,
    level,
    perkPoints,
    coins,
    currentStreak,
    bestStreak,
    lastActiveDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserStat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('total_xp')) {
      context.handle(
        _totalXpMeta,
        totalXp.isAcceptableOrUnknown(data['total_xp']!, _totalXpMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('perk_points')) {
      context.handle(
        _perkPointsMeta,
        perkPoints.isAcceptableOrUnknown(data['perk_points']!, _perkPointsMeta),
      );
    }
    if (data.containsKey('coins')) {
      context.handle(
        _coinsMeta,
        coins.isAcceptableOrUnknown(data['coins']!, _coinsMeta),
      );
    }
    if (data.containsKey('current_streak')) {
      context.handle(
        _currentStreakMeta,
        currentStreak.isAcceptableOrUnknown(
          data['current_streak']!,
          _currentStreakMeta,
        ),
      );
    }
    if (data.containsKey('best_streak')) {
      context.handle(
        _bestStreakMeta,
        bestStreak.isAcceptableOrUnknown(data['best_streak']!, _bestStreakMeta),
      );
    }
    if (data.containsKey('last_active_date')) {
      context.handle(
        _lastActiveDateMeta,
        lastActiveDate.isAcceptableOrUnknown(
          data['last_active_date']!,
          _lastActiveDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserStat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      totalXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_xp'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      perkPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}perk_points'],
      )!,
      coins: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coins'],
      )!,
      currentStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_streak'],
      )!,
      bestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_streak'],
      )!,
      lastActiveDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_active_date'],
      ),
    );
  }

  @override
  $UserStatsTable createAlias(String alias) {
    return $UserStatsTable(attachedDatabase, alias);
  }
}

class UserStat extends DataClass implements Insertable<UserStat> {
  final int id;
  final int totalXp;
  final int level;
  final int perkPoints;
  final int coins;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastActiveDate;
  const UserStat({
    required this.id,
    required this.totalXp,
    required this.level,
    required this.perkPoints,
    required this.coins,
    required this.currentStreak,
    required this.bestStreak,
    this.lastActiveDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['total_xp'] = Variable<int>(totalXp);
    map['level'] = Variable<int>(level);
    map['perk_points'] = Variable<int>(perkPoints);
    map['coins'] = Variable<int>(coins);
    map['current_streak'] = Variable<int>(currentStreak);
    map['best_streak'] = Variable<int>(bestStreak);
    if (!nullToAbsent || lastActiveDate != null) {
      map['last_active_date'] = Variable<DateTime>(lastActiveDate);
    }
    return map;
  }

  UserStatsCompanion toCompanion(bool nullToAbsent) {
    return UserStatsCompanion(
      id: Value(id),
      totalXp: Value(totalXp),
      level: Value(level),
      perkPoints: Value(perkPoints),
      coins: Value(coins),
      currentStreak: Value(currentStreak),
      bestStreak: Value(bestStreak),
      lastActiveDate: lastActiveDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActiveDate),
    );
  }

  factory UserStat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserStat(
      id: serializer.fromJson<int>(json['id']),
      totalXp: serializer.fromJson<int>(json['totalXp']),
      level: serializer.fromJson<int>(json['level']),
      perkPoints: serializer.fromJson<int>(json['perkPoints']),
      coins: serializer.fromJson<int>(json['coins']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      bestStreak: serializer.fromJson<int>(json['bestStreak']),
      lastActiveDate: serializer.fromJson<DateTime?>(json['lastActiveDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'totalXp': serializer.toJson<int>(totalXp),
      'level': serializer.toJson<int>(level),
      'perkPoints': serializer.toJson<int>(perkPoints),
      'coins': serializer.toJson<int>(coins),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'bestStreak': serializer.toJson<int>(bestStreak),
      'lastActiveDate': serializer.toJson<DateTime?>(lastActiveDate),
    };
  }

  UserStat copyWith({
    int? id,
    int? totalXp,
    int? level,
    int? perkPoints,
    int? coins,
    int? currentStreak,
    int? bestStreak,
    Value<DateTime?> lastActiveDate = const Value.absent(),
  }) => UserStat(
    id: id ?? this.id,
    totalXp: totalXp ?? this.totalXp,
    level: level ?? this.level,
    perkPoints: perkPoints ?? this.perkPoints,
    coins: coins ?? this.coins,
    currentStreak: currentStreak ?? this.currentStreak,
    bestStreak: bestStreak ?? this.bestStreak,
    lastActiveDate: lastActiveDate.present
        ? lastActiveDate.value
        : this.lastActiveDate,
  );
  UserStat copyWithCompanion(UserStatsCompanion data) {
    return UserStat(
      id: data.id.present ? data.id.value : this.id,
      totalXp: data.totalXp.present ? data.totalXp.value : this.totalXp,
      level: data.level.present ? data.level.value : this.level,
      perkPoints: data.perkPoints.present
          ? data.perkPoints.value
          : this.perkPoints,
      coins: data.coins.present ? data.coins.value : this.coins,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      bestStreak: data.bestStreak.present
          ? data.bestStreak.value
          : this.bestStreak,
      lastActiveDate: data.lastActiveDate.present
          ? data.lastActiveDate.value
          : this.lastActiveDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserStat(')
          ..write('id: $id, ')
          ..write('totalXp: $totalXp, ')
          ..write('level: $level, ')
          ..write('perkPoints: $perkPoints, ')
          ..write('coins: $coins, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('lastActiveDate: $lastActiveDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    totalXp,
    level,
    perkPoints,
    coins,
    currentStreak,
    bestStreak,
    lastActiveDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserStat &&
          other.id == this.id &&
          other.totalXp == this.totalXp &&
          other.level == this.level &&
          other.perkPoints == this.perkPoints &&
          other.coins == this.coins &&
          other.currentStreak == this.currentStreak &&
          other.bestStreak == this.bestStreak &&
          other.lastActiveDate == this.lastActiveDate);
}

class UserStatsCompanion extends UpdateCompanion<UserStat> {
  final Value<int> id;
  final Value<int> totalXp;
  final Value<int> level;
  final Value<int> perkPoints;
  final Value<int> coins;
  final Value<int> currentStreak;
  final Value<int> bestStreak;
  final Value<DateTime?> lastActiveDate;
  const UserStatsCompanion({
    this.id = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.level = const Value.absent(),
    this.perkPoints = const Value.absent(),
    this.coins = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.lastActiveDate = const Value.absent(),
  });
  UserStatsCompanion.insert({
    this.id = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.level = const Value.absent(),
    this.perkPoints = const Value.absent(),
    this.coins = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.lastActiveDate = const Value.absent(),
  });
  static Insertable<UserStat> custom({
    Expression<int>? id,
    Expression<int>? totalXp,
    Expression<int>? level,
    Expression<int>? perkPoints,
    Expression<int>? coins,
    Expression<int>? currentStreak,
    Expression<int>? bestStreak,
    Expression<DateTime>? lastActiveDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (totalXp != null) 'total_xp': totalXp,
      if (level != null) 'level': level,
      if (perkPoints != null) 'perk_points': perkPoints,
      if (coins != null) 'coins': coins,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (bestStreak != null) 'best_streak': bestStreak,
      if (lastActiveDate != null) 'last_active_date': lastActiveDate,
    });
  }

  UserStatsCompanion copyWith({
    Value<int>? id,
    Value<int>? totalXp,
    Value<int>? level,
    Value<int>? perkPoints,
    Value<int>? coins,
    Value<int>? currentStreak,
    Value<int>? bestStreak,
    Value<DateTime?>? lastActiveDate,
  }) {
    return UserStatsCompanion(
      id: id ?? this.id,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      perkPoints: perkPoints ?? this.perkPoints,
      coins: coins ?? this.coins,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (totalXp.present) {
      map['total_xp'] = Variable<int>(totalXp.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (perkPoints.present) {
      map['perk_points'] = Variable<int>(perkPoints.value);
    }
    if (coins.present) {
      map['coins'] = Variable<int>(coins.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (bestStreak.present) {
      map['best_streak'] = Variable<int>(bestStreak.value);
    }
    if (lastActiveDate.present) {
      map['last_active_date'] = Variable<DateTime>(lastActiveDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserStatsCompanion(')
          ..write('id: $id, ')
          ..write('totalXp: $totalXp, ')
          ..write('level: $level, ')
          ..write('perkPoints: $perkPoints, ')
          ..write('coins: $coins, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('lastActiveDate: $lastActiveDate')
          ..write(')'))
        .toString();
  }
}

class $UserPerksTable extends UserPerks
    with TableInfo<$UserPerksTable, UserPerk> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPerksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _perkIdMeta = const VerificationMeta('perkId');
  @override
  late final GeneratedColumn<String> perkId = GeneratedColumn<String>(
    'perk_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [perkId, level, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_perks';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPerk> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('perk_id')) {
      context.handle(
        _perkIdMeta,
        perkId.isAcceptableOrUnknown(data['perk_id']!, _perkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_perkIdMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {perkId};
  @override
  UserPerk map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPerk(
      perkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}perk_id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      ),
    );
  }

  @override
  $UserPerksTable createAlias(String alias) {
    return $UserPerksTable(attachedDatabase, alias);
  }
}

class UserPerk extends DataClass implements Insertable<UserPerk> {
  final String perkId;
  final int level;
  final DateTime? unlockedAt;
  const UserPerk({required this.perkId, required this.level, this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['perk_id'] = Variable<String>(perkId);
    map['level'] = Variable<int>(level);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    return map;
  }

  UserPerksCompanion toCompanion(bool nullToAbsent) {
    return UserPerksCompanion(
      perkId: Value(perkId),
      level: Value(level),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
    );
  }

  factory UserPerk.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPerk(
      perkId: serializer.fromJson<String>(json['perkId']),
      level: serializer.fromJson<int>(json['level']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'perkId': serializer.toJson<String>(perkId),
      'level': serializer.toJson<int>(level),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
    };
  }

  UserPerk copyWith({
    String? perkId,
    int? level,
    Value<DateTime?> unlockedAt = const Value.absent(),
  }) => UserPerk(
    perkId: perkId ?? this.perkId,
    level: level ?? this.level,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
  );
  UserPerk copyWithCompanion(UserPerksCompanion data) {
    return UserPerk(
      perkId: data.perkId.present ? data.perkId.value : this.perkId,
      level: data.level.present ? data.level.value : this.level,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPerk(')
          ..write('perkId: $perkId, ')
          ..write('level: $level, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(perkId, level, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPerk &&
          other.perkId == this.perkId &&
          other.level == this.level &&
          other.unlockedAt == this.unlockedAt);
}

class UserPerksCompanion extends UpdateCompanion<UserPerk> {
  final Value<String> perkId;
  final Value<int> level;
  final Value<DateTime?> unlockedAt;
  final Value<int> rowid;
  const UserPerksCompanion({
    this.perkId = const Value.absent(),
    this.level = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPerksCompanion.insert({
    required String perkId,
    this.level = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : perkId = Value(perkId);
  static Insertable<UserPerk> custom({
    Expression<String>? perkId,
    Expression<int>? level,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (perkId != null) 'perk_id': perkId,
      if (level != null) 'level': level,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPerksCompanion copyWith({
    Value<String>? perkId,
    Value<int>? level,
    Value<DateTime?>? unlockedAt,
    Value<int>? rowid,
  }) {
    return UserPerksCompanion(
      perkId: perkId ?? this.perkId,
      level: level ?? this.level,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (perkId.present) {
      map['perk_id'] = Variable<String>(perkId.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPerksCompanion(')
          ..write('perkId: $perkId, ')
          ..write('level: $level, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyQuestClaimsTable extends DailyQuestClaims
    with TableInfo<$DailyQuestClaimsTable, DailyQuestClaim> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyQuestClaimsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questIdMeta = const VerificationMeta(
    'questId',
  );
  @override
  late final GeneratedColumn<String> questId = GeneratedColumn<String>(
    'quest_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _claimDateMeta = const VerificationMeta(
    'claimDate',
  );
  @override
  late final GeneratedColumn<String> claimDate = GeneratedColumn<String>(
    'claim_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _claimedAtMeta = const VerificationMeta(
    'claimedAt',
  );
  @override
  late final GeneratedColumn<DateTime> claimedAt = GeneratedColumn<DateTime>(
    'claimed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [questId, claimDate, claimedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_quest_claims';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyQuestClaim> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('quest_id')) {
      context.handle(
        _questIdMeta,
        questId.isAcceptableOrUnknown(data['quest_id']!, _questIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questIdMeta);
    }
    if (data.containsKey('claim_date')) {
      context.handle(
        _claimDateMeta,
        claimDate.isAcceptableOrUnknown(data['claim_date']!, _claimDateMeta),
      );
    } else if (isInserting) {
      context.missing(_claimDateMeta);
    }
    if (data.containsKey('claimed_at')) {
      context.handle(
        _claimedAtMeta,
        claimedAt.isAcceptableOrUnknown(data['claimed_at']!, _claimedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_claimedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questId, claimDate};
  @override
  DailyQuestClaim map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyQuestClaim(
      questId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quest_id'],
      )!,
      claimDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_date'],
      )!,
      claimedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}claimed_at'],
      )!,
    );
  }

  @override
  $DailyQuestClaimsTable createAlias(String alias) {
    return $DailyQuestClaimsTable(attachedDatabase, alias);
  }
}

class DailyQuestClaim extends DataClass implements Insertable<DailyQuestClaim> {
  final String questId;
  final String claimDate;
  final DateTime claimedAt;
  const DailyQuestClaim({
    required this.questId,
    required this.claimDate,
    required this.claimedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['quest_id'] = Variable<String>(questId);
    map['claim_date'] = Variable<String>(claimDate);
    map['claimed_at'] = Variable<DateTime>(claimedAt);
    return map;
  }

  DailyQuestClaimsCompanion toCompanion(bool nullToAbsent) {
    return DailyQuestClaimsCompanion(
      questId: Value(questId),
      claimDate: Value(claimDate),
      claimedAt: Value(claimedAt),
    );
  }

  factory DailyQuestClaim.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyQuestClaim(
      questId: serializer.fromJson<String>(json['questId']),
      claimDate: serializer.fromJson<String>(json['claimDate']),
      claimedAt: serializer.fromJson<DateTime>(json['claimedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questId': serializer.toJson<String>(questId),
      'claimDate': serializer.toJson<String>(claimDate),
      'claimedAt': serializer.toJson<DateTime>(claimedAt),
    };
  }

  DailyQuestClaim copyWith({
    String? questId,
    String? claimDate,
    DateTime? claimedAt,
  }) => DailyQuestClaim(
    questId: questId ?? this.questId,
    claimDate: claimDate ?? this.claimDate,
    claimedAt: claimedAt ?? this.claimedAt,
  );
  DailyQuestClaim copyWithCompanion(DailyQuestClaimsCompanion data) {
    return DailyQuestClaim(
      questId: data.questId.present ? data.questId.value : this.questId,
      claimDate: data.claimDate.present ? data.claimDate.value : this.claimDate,
      claimedAt: data.claimedAt.present ? data.claimedAt.value : this.claimedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyQuestClaim(')
          ..write('questId: $questId, ')
          ..write('claimDate: $claimDate, ')
          ..write('claimedAt: $claimedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(questId, claimDate, claimedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyQuestClaim &&
          other.questId == this.questId &&
          other.claimDate == this.claimDate &&
          other.claimedAt == this.claimedAt);
}

class DailyQuestClaimsCompanion extends UpdateCompanion<DailyQuestClaim> {
  final Value<String> questId;
  final Value<String> claimDate;
  final Value<DateTime> claimedAt;
  final Value<int> rowid;
  const DailyQuestClaimsCompanion({
    this.questId = const Value.absent(),
    this.claimDate = const Value.absent(),
    this.claimedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyQuestClaimsCompanion.insert({
    required String questId,
    required String claimDate,
    required DateTime claimedAt,
    this.rowid = const Value.absent(),
  }) : questId = Value(questId),
       claimDate = Value(claimDate),
       claimedAt = Value(claimedAt);
  static Insertable<DailyQuestClaim> custom({
    Expression<String>? questId,
    Expression<String>? claimDate,
    Expression<DateTime>? claimedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questId != null) 'quest_id': questId,
      if (claimDate != null) 'claim_date': claimDate,
      if (claimedAt != null) 'claimed_at': claimedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyQuestClaimsCompanion copyWith({
    Value<String>? questId,
    Value<String>? claimDate,
    Value<DateTime>? claimedAt,
    Value<int>? rowid,
  }) {
    return DailyQuestClaimsCompanion(
      questId: questId ?? this.questId,
      claimDate: claimDate ?? this.claimDate,
      claimedAt: claimedAt ?? this.claimedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questId.present) {
      map['quest_id'] = Variable<String>(questId.value);
    }
    if (claimDate.present) {
      map['claim_date'] = Variable<String>(claimDate.value);
    }
    if (claimedAt.present) {
      map['claimed_at'] = Variable<DateTime>(claimedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyQuestClaimsCompanion(')
          ..write('questId: $questId, ')
          ..write('claimDate: $claimDate, ')
          ..write('claimedAt: $claimedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BadgesTable extends Badges with TableInfo<$BadgesTable, Badge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BadgesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
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
  List<GeneratedColumn> get $columns => [id, name, description, sortOrder];
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
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
  Badge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Badge(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $BadgesTable createAlias(String alias) {
    return $BadgesTable(attachedDatabase, alias);
  }
}

class Badge extends DataClass implements Insertable<Badge> {
  final String id;
  final String name;
  final String description;
  final int sortOrder;
  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  BadgesCompanion toCompanion(bool nullToAbsent) {
    return BadgesCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      sortOrder: Value(sortOrder),
    );
  }

  factory Badge.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Badge(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Badge copyWith({
    String? id,
    String? name,
    String? description,
    int? sortOrder,
  }) => Badge(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Badge copyWithCompanion(BadgesCompanion data) {
    return Badge(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Badge(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Badge &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.sortOrder == this.sortOrder);
}

class BadgesCompanion extends UpdateCompanion<Badge> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const BadgesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BadgesCompanion.insert({
    required String id,
    required String name,
    required String description,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       description = Value(description);
  static Insertable<Badge> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BadgesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return BadgesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BadgesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserBadgesTable extends UserBadges
    with TableInfo<$UserBadgesTable, UserBadge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserBadgesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _badgeIdMeta = const VerificationMeta(
    'badgeId',
  );
  @override
  late final GeneratedColumn<String> badgeId = GeneratedColumn<String>(
    'badge_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES badges (id)',
    ),
  );
  static const VerificationMeta _earnedAtMeta = const VerificationMeta(
    'earnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> earnedAt = GeneratedColumn<DateTime>(
    'earned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [badgeId, earnedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_badges';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserBadge> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('badge_id')) {
      context.handle(
        _badgeIdMeta,
        badgeId.isAcceptableOrUnknown(data['badge_id']!, _badgeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_badgeIdMeta);
    }
    if (data.containsKey('earned_at')) {
      context.handle(
        _earnedAtMeta,
        earnedAt.isAcceptableOrUnknown(data['earned_at']!, _earnedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_earnedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {badgeId};
  @override
  UserBadge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserBadge(
      badgeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}badge_id'],
      )!,
      earnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}earned_at'],
      )!,
    );
  }

  @override
  $UserBadgesTable createAlias(String alias) {
    return $UserBadgesTable(attachedDatabase, alias);
  }
}

class UserBadge extends DataClass implements Insertable<UserBadge> {
  final String badgeId;
  final DateTime earnedAt;
  const UserBadge({required this.badgeId, required this.earnedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['badge_id'] = Variable<String>(badgeId);
    map['earned_at'] = Variable<DateTime>(earnedAt);
    return map;
  }

  UserBadgesCompanion toCompanion(bool nullToAbsent) {
    return UserBadgesCompanion(
      badgeId: Value(badgeId),
      earnedAt: Value(earnedAt),
    );
  }

  factory UserBadge.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserBadge(
      badgeId: serializer.fromJson<String>(json['badgeId']),
      earnedAt: serializer.fromJson<DateTime>(json['earnedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'badgeId': serializer.toJson<String>(badgeId),
      'earnedAt': serializer.toJson<DateTime>(earnedAt),
    };
  }

  UserBadge copyWith({String? badgeId, DateTime? earnedAt}) => UserBadge(
    badgeId: badgeId ?? this.badgeId,
    earnedAt: earnedAt ?? this.earnedAt,
  );
  UserBadge copyWithCompanion(UserBadgesCompanion data) {
    return UserBadge(
      badgeId: data.badgeId.present ? data.badgeId.value : this.badgeId,
      earnedAt: data.earnedAt.present ? data.earnedAt.value : this.earnedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserBadge(')
          ..write('badgeId: $badgeId, ')
          ..write('earnedAt: $earnedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(badgeId, earnedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserBadge &&
          other.badgeId == this.badgeId &&
          other.earnedAt == this.earnedAt);
}

class UserBadgesCompanion extends UpdateCompanion<UserBadge> {
  final Value<String> badgeId;
  final Value<DateTime> earnedAt;
  final Value<int> rowid;
  const UserBadgesCompanion({
    this.badgeId = const Value.absent(),
    this.earnedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserBadgesCompanion.insert({
    required String badgeId,
    required DateTime earnedAt,
    this.rowid = const Value.absent(),
  }) : badgeId = Value(badgeId),
       earnedAt = Value(earnedAt);
  static Insertable<UserBadge> custom({
    Expression<String>? badgeId,
    Expression<DateTime>? earnedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (badgeId != null) 'badge_id': badgeId,
      if (earnedAt != null) 'earned_at': earnedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserBadgesCompanion copyWith({
    Value<String>? badgeId,
    Value<DateTime>? earnedAt,
    Value<int>? rowid,
  }) {
    return UserBadgesCompanion(
      badgeId: badgeId ?? this.badgeId,
      earnedAt: earnedAt ?? this.earnedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (badgeId.present) {
      map['badge_id'] = Variable<String>(badgeId.value);
    }
    if (earnedAt.present) {
      map['earned_at'] = Variable<DateTime>(earnedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserBadgesCompanion(')
          ..write('badgeId: $badgeId, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovementGuidesTable extends MovementGuides
    with TableInfo<$MovementGuidesTable, MovementGuide> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovementGuidesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _movementIdMeta = const VerificationMeta(
    'movementId',
  );
  @override
  late final GeneratedColumn<String> movementId = GeneratedColumn<String>(
    'movement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES movements (id)',
    ),
  );
  static const VerificationMeta _primaryMusclesMeta = const VerificationMeta(
    'primaryMuscles',
  );
  @override
  late final GeneratedColumn<String> primaryMuscles = GeneratedColumn<String>(
    'primary_muscles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(""),
  );
  static const VerificationMeta _secondaryMusclesMeta = const VerificationMeta(
    'secondaryMuscles',
  );
  @override
  late final GeneratedColumn<String> secondaryMuscles = GeneratedColumn<String>(
    'secondary_muscles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(""),
  );
  static const VerificationMeta _setupMeta = const VerificationMeta('setup');
  @override
  late final GeneratedColumn<String> setup = GeneratedColumn<String>(
    'setup',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(""),
  );
  static const VerificationMeta _executionMeta = const VerificationMeta(
    'execution',
  );
  @override
  late final GeneratedColumn<String> execution = GeneratedColumn<String>(
    'execution',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(""),
  );
  static const VerificationMeta _cuesMeta = const VerificationMeta('cues');
  @override
  late final GeneratedColumn<String> cues = GeneratedColumn<String>(
    'cues',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(""),
  );
  static const VerificationMeta _commonMistakesMeta = const VerificationMeta(
    'commonMistakes',
  );
  @override
  late final GeneratedColumn<String> commonMistakes = GeneratedColumn<String>(
    'common_mistakes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(""),
  );
  static const VerificationMeta _regressionsMeta = const VerificationMeta(
    'regressions',
  );
  @override
  late final GeneratedColumn<String> regressions = GeneratedColumn<String>(
    'regressions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(""),
  );
  static const VerificationMeta _progressionsMeta = const VerificationMeta(
    'progressions',
  );
  @override
  late final GeneratedColumn<String> progressions = GeneratedColumn<String>(
    'progressions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(""),
  );
  static const VerificationMeta _youtubeQueryMeta = const VerificationMeta(
    'youtubeQuery',
  );
  @override
  late final GeneratedColumn<String> youtubeQuery = GeneratedColumn<String>(
    'youtube_query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(""),
  );
  @override
  List<GeneratedColumn> get $columns => [
    movementId,
    primaryMuscles,
    secondaryMuscles,
    setup,
    execution,
    cues,
    commonMistakes,
    regressions,
    progressions,
    youtubeQuery,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movement_guides';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovementGuide> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('movement_id')) {
      context.handle(
        _movementIdMeta,
        movementId.isAcceptableOrUnknown(data['movement_id']!, _movementIdMeta),
      );
    } else if (isInserting) {
      context.missing(_movementIdMeta);
    }
    if (data.containsKey('primary_muscles')) {
      context.handle(
        _primaryMusclesMeta,
        primaryMuscles.isAcceptableOrUnknown(
          data['primary_muscles']!,
          _primaryMusclesMeta,
        ),
      );
    }
    if (data.containsKey('secondary_muscles')) {
      context.handle(
        _secondaryMusclesMeta,
        secondaryMuscles.isAcceptableOrUnknown(
          data['secondary_muscles']!,
          _secondaryMusclesMeta,
        ),
      );
    }
    if (data.containsKey('setup')) {
      context.handle(
        _setupMeta,
        setup.isAcceptableOrUnknown(data['setup']!, _setupMeta),
      );
    }
    if (data.containsKey('execution')) {
      context.handle(
        _executionMeta,
        execution.isAcceptableOrUnknown(data['execution']!, _executionMeta),
      );
    }
    if (data.containsKey('cues')) {
      context.handle(
        _cuesMeta,
        cues.isAcceptableOrUnknown(data['cues']!, _cuesMeta),
      );
    }
    if (data.containsKey('common_mistakes')) {
      context.handle(
        _commonMistakesMeta,
        commonMistakes.isAcceptableOrUnknown(
          data['common_mistakes']!,
          _commonMistakesMeta,
        ),
      );
    }
    if (data.containsKey('regressions')) {
      context.handle(
        _regressionsMeta,
        regressions.isAcceptableOrUnknown(
          data['regressions']!,
          _regressionsMeta,
        ),
      );
    }
    if (data.containsKey('progressions')) {
      context.handle(
        _progressionsMeta,
        progressions.isAcceptableOrUnknown(
          data['progressions']!,
          _progressionsMeta,
        ),
      );
    }
    if (data.containsKey('youtube_query')) {
      context.handle(
        _youtubeQueryMeta,
        youtubeQuery.isAcceptableOrUnknown(
          data['youtube_query']!,
          _youtubeQueryMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {movementId};
  @override
  MovementGuide map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovementGuide(
      movementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement_id'],
      )!,
      primaryMuscles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_muscles'],
      )!,
      secondaryMuscles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secondary_muscles'],
      )!,
      setup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setup'],
      )!,
      execution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}execution'],
      )!,
      cues: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cues'],
      )!,
      commonMistakes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}common_mistakes'],
      )!,
      regressions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}regressions'],
      )!,
      progressions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}progressions'],
      )!,
      youtubeQuery: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}youtube_query'],
      )!,
    );
  }

  @override
  $MovementGuidesTable createAlias(String alias) {
    return $MovementGuidesTable(attachedDatabase, alias);
  }
}

class MovementGuide extends DataClass implements Insertable<MovementGuide> {
  final String movementId;
  final String primaryMuscles;
  final String secondaryMuscles;
  final String setup;
  final String execution;
  final String cues;
  final String commonMistakes;
  final String regressions;
  final String progressions;
  final String youtubeQuery;
  const MovementGuide({
    required this.movementId,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.setup,
    required this.execution,
    required this.cues,
    required this.commonMistakes,
    required this.regressions,
    required this.progressions,
    required this.youtubeQuery,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['movement_id'] = Variable<String>(movementId);
    map['primary_muscles'] = Variable<String>(primaryMuscles);
    map['secondary_muscles'] = Variable<String>(secondaryMuscles);
    map['setup'] = Variable<String>(setup);
    map['execution'] = Variable<String>(execution);
    map['cues'] = Variable<String>(cues);
    map['common_mistakes'] = Variable<String>(commonMistakes);
    map['regressions'] = Variable<String>(regressions);
    map['progressions'] = Variable<String>(progressions);
    map['youtube_query'] = Variable<String>(youtubeQuery);
    return map;
  }

  MovementGuidesCompanion toCompanion(bool nullToAbsent) {
    return MovementGuidesCompanion(
      movementId: Value(movementId),
      primaryMuscles: Value(primaryMuscles),
      secondaryMuscles: Value(secondaryMuscles),
      setup: Value(setup),
      execution: Value(execution),
      cues: Value(cues),
      commonMistakes: Value(commonMistakes),
      regressions: Value(regressions),
      progressions: Value(progressions),
      youtubeQuery: Value(youtubeQuery),
    );
  }

  factory MovementGuide.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovementGuide(
      movementId: serializer.fromJson<String>(json['movementId']),
      primaryMuscles: serializer.fromJson<String>(json['primaryMuscles']),
      secondaryMuscles: serializer.fromJson<String>(json['secondaryMuscles']),
      setup: serializer.fromJson<String>(json['setup']),
      execution: serializer.fromJson<String>(json['execution']),
      cues: serializer.fromJson<String>(json['cues']),
      commonMistakes: serializer.fromJson<String>(json['commonMistakes']),
      regressions: serializer.fromJson<String>(json['regressions']),
      progressions: serializer.fromJson<String>(json['progressions']),
      youtubeQuery: serializer.fromJson<String>(json['youtubeQuery']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'movementId': serializer.toJson<String>(movementId),
      'primaryMuscles': serializer.toJson<String>(primaryMuscles),
      'secondaryMuscles': serializer.toJson<String>(secondaryMuscles),
      'setup': serializer.toJson<String>(setup),
      'execution': serializer.toJson<String>(execution),
      'cues': serializer.toJson<String>(cues),
      'commonMistakes': serializer.toJson<String>(commonMistakes),
      'regressions': serializer.toJson<String>(regressions),
      'progressions': serializer.toJson<String>(progressions),
      'youtubeQuery': serializer.toJson<String>(youtubeQuery),
    };
  }

  MovementGuide copyWith({
    String? movementId,
    String? primaryMuscles,
    String? secondaryMuscles,
    String? setup,
    String? execution,
    String? cues,
    String? commonMistakes,
    String? regressions,
    String? progressions,
    String? youtubeQuery,
  }) => MovementGuide(
    movementId: movementId ?? this.movementId,
    primaryMuscles: primaryMuscles ?? this.primaryMuscles,
    secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
    setup: setup ?? this.setup,
    execution: execution ?? this.execution,
    cues: cues ?? this.cues,
    commonMistakes: commonMistakes ?? this.commonMistakes,
    regressions: regressions ?? this.regressions,
    progressions: progressions ?? this.progressions,
    youtubeQuery: youtubeQuery ?? this.youtubeQuery,
  );
  MovementGuide copyWithCompanion(MovementGuidesCompanion data) {
    return MovementGuide(
      movementId: data.movementId.present
          ? data.movementId.value
          : this.movementId,
      primaryMuscles: data.primaryMuscles.present
          ? data.primaryMuscles.value
          : this.primaryMuscles,
      secondaryMuscles: data.secondaryMuscles.present
          ? data.secondaryMuscles.value
          : this.secondaryMuscles,
      setup: data.setup.present ? data.setup.value : this.setup,
      execution: data.execution.present ? data.execution.value : this.execution,
      cues: data.cues.present ? data.cues.value : this.cues,
      commonMistakes: data.commonMistakes.present
          ? data.commonMistakes.value
          : this.commonMistakes,
      regressions: data.regressions.present
          ? data.regressions.value
          : this.regressions,
      progressions: data.progressions.present
          ? data.progressions.value
          : this.progressions,
      youtubeQuery: data.youtubeQuery.present
          ? data.youtubeQuery.value
          : this.youtubeQuery,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovementGuide(')
          ..write('movementId: $movementId, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('setup: $setup, ')
          ..write('execution: $execution, ')
          ..write('cues: $cues, ')
          ..write('commonMistakes: $commonMistakes, ')
          ..write('regressions: $regressions, ')
          ..write('progressions: $progressions, ')
          ..write('youtubeQuery: $youtubeQuery')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    movementId,
    primaryMuscles,
    secondaryMuscles,
    setup,
    execution,
    cues,
    commonMistakes,
    regressions,
    progressions,
    youtubeQuery,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovementGuide &&
          other.movementId == this.movementId &&
          other.primaryMuscles == this.primaryMuscles &&
          other.secondaryMuscles == this.secondaryMuscles &&
          other.setup == this.setup &&
          other.execution == this.execution &&
          other.cues == this.cues &&
          other.commonMistakes == this.commonMistakes &&
          other.regressions == this.regressions &&
          other.progressions == this.progressions &&
          other.youtubeQuery == this.youtubeQuery);
}

class MovementGuidesCompanion extends UpdateCompanion<MovementGuide> {
  final Value<String> movementId;
  final Value<String> primaryMuscles;
  final Value<String> secondaryMuscles;
  final Value<String> setup;
  final Value<String> execution;
  final Value<String> cues;
  final Value<String> commonMistakes;
  final Value<String> regressions;
  final Value<String> progressions;
  final Value<String> youtubeQuery;
  final Value<int> rowid;
  const MovementGuidesCompanion({
    this.movementId = const Value.absent(),
    this.primaryMuscles = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.setup = const Value.absent(),
    this.execution = const Value.absent(),
    this.cues = const Value.absent(),
    this.commonMistakes = const Value.absent(),
    this.regressions = const Value.absent(),
    this.progressions = const Value.absent(),
    this.youtubeQuery = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovementGuidesCompanion.insert({
    required String movementId,
    this.primaryMuscles = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.setup = const Value.absent(),
    this.execution = const Value.absent(),
    this.cues = const Value.absent(),
    this.commonMistakes = const Value.absent(),
    this.regressions = const Value.absent(),
    this.progressions = const Value.absent(),
    this.youtubeQuery = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : movementId = Value(movementId);
  static Insertable<MovementGuide> custom({
    Expression<String>? movementId,
    Expression<String>? primaryMuscles,
    Expression<String>? secondaryMuscles,
    Expression<String>? setup,
    Expression<String>? execution,
    Expression<String>? cues,
    Expression<String>? commonMistakes,
    Expression<String>? regressions,
    Expression<String>? progressions,
    Expression<String>? youtubeQuery,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (movementId != null) 'movement_id': movementId,
      if (primaryMuscles != null) 'primary_muscles': primaryMuscles,
      if (secondaryMuscles != null) 'secondary_muscles': secondaryMuscles,
      if (setup != null) 'setup': setup,
      if (execution != null) 'execution': execution,
      if (cues != null) 'cues': cues,
      if (commonMistakes != null) 'common_mistakes': commonMistakes,
      if (regressions != null) 'regressions': regressions,
      if (progressions != null) 'progressions': progressions,
      if (youtubeQuery != null) 'youtube_query': youtubeQuery,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovementGuidesCompanion copyWith({
    Value<String>? movementId,
    Value<String>? primaryMuscles,
    Value<String>? secondaryMuscles,
    Value<String>? setup,
    Value<String>? execution,
    Value<String>? cues,
    Value<String>? commonMistakes,
    Value<String>? regressions,
    Value<String>? progressions,
    Value<String>? youtubeQuery,
    Value<int>? rowid,
  }) {
    return MovementGuidesCompanion(
      movementId: movementId ?? this.movementId,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      setup: setup ?? this.setup,
      execution: execution ?? this.execution,
      cues: cues ?? this.cues,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      regressions: regressions ?? this.regressions,
      progressions: progressions ?? this.progressions,
      youtubeQuery: youtubeQuery ?? this.youtubeQuery,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (movementId.present) {
      map['movement_id'] = Variable<String>(movementId.value);
    }
    if (primaryMuscles.present) {
      map['primary_muscles'] = Variable<String>(primaryMuscles.value);
    }
    if (secondaryMuscles.present) {
      map['secondary_muscles'] = Variable<String>(secondaryMuscles.value);
    }
    if (setup.present) {
      map['setup'] = Variable<String>(setup.value);
    }
    if (execution.present) {
      map['execution'] = Variable<String>(execution.value);
    }
    if (cues.present) {
      map['cues'] = Variable<String>(cues.value);
    }
    if (commonMistakes.present) {
      map['common_mistakes'] = Variable<String>(commonMistakes.value);
    }
    if (regressions.present) {
      map['regressions'] = Variable<String>(regressions.value);
    }
    if (progressions.present) {
      map['progressions'] = Variable<String>(progressions.value);
    }
    if (youtubeQuery.present) {
      map['youtube_query'] = Variable<String>(youtubeQuery.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovementGuidesCompanion(')
          ..write('movementId: $movementId, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('setup: $setup, ')
          ..write('execution: $execution, ')
          ..write('cues: $cues, ')
          ..write('commonMistakes: $commonMistakes, ')
          ..write('regressions: $regressions, ')
          ..write('progressions: $progressions, ')
          ..write('youtubeQuery: $youtubeQuery, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $MovementsTable movements = $MovementsTable(this);
  late final $MovementPrereqsTable movementPrereqs = $MovementPrereqsTable(
    this,
  );
  late final $MovementProgressesTable movementProgresses =
      $MovementProgressesTable(this);
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $UserStatsTable userStats = $UserStatsTable(this);
  late final $UserPerksTable userPerks = $UserPerksTable(this);
  late final $DailyQuestClaimsTable dailyQuestClaims = $DailyQuestClaimsTable(
    this,
  );
  late final $BadgesTable badges = $BadgesTable(this);
  late final $UserBadgesTable userBadges = $UserBadgesTable(this);
  late final $MovementGuidesTable movementGuides = $MovementGuidesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    movements,
    movementPrereqs,
    movementProgresses,
    workouts,
    sessions,
    userStats,
    userPerks,
    dailyQuestClaims,
    badges,
    userBadges,
    movementGuides,
  ];
}

typedef $$MovementsTableCreateCompanionBuilder =
    MovementsCompanion Function({
      required String id,
      required String name,
      required String category,
      required int difficulty,
      Value<String> description,
      Value<int> xpToUnlock,
      Value<int> baseXp,
      Value<int> xpPerRep,
      Value<int> xpPerSecond,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$MovementsTableUpdateCompanionBuilder =
    MovementsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> category,
      Value<int> difficulty,
      Value<String> description,
      Value<int> xpToUnlock,
      Value<int> baseXp,
      Value<int> xpPerRep,
      Value<int> xpPerSecond,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$MovementsTableReferences
    extends BaseReferences<_$AppDb, $MovementsTable, Movement> {
  $$MovementsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MovementProgressesTable, List<MovementProgress>>
  _movementProgressesRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.movementProgresses,
    aliasName: $_aliasNameGenerator(
      db.movements.id,
      db.movementProgresses.movementId,
    ),
  );

  $$MovementProgressesTableProcessedTableManager get movementProgressesRefs {
    final manager = $$MovementProgressesTableTableManager(
      $_db,
      $_db.movementProgresses,
    ).filter((f) => f.movementId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _movementProgressesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDb db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: $_aliasNameGenerator(db.movements.id, db.sessions.movementId),
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.movementId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MovementGuidesTable, List<MovementGuide>>
  _movementGuidesRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.movementGuides,
    aliasName: $_aliasNameGenerator(
      db.movements.id,
      db.movementGuides.movementId,
    ),
  );

  $$MovementGuidesTableProcessedTableManager get movementGuidesRefs {
    final manager = $$MovementGuidesTableTableManager(
      $_db,
      $_db.movementGuides,
    ).filter((f) => f.movementId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_movementGuidesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MovementsTableFilterComposer
    extends Composer<_$AppDb, $MovementsTable> {
  $$MovementsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpToUnlock => $composableBuilder(
    column: $table.xpToUnlock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseXp => $composableBuilder(
    column: $table.baseXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpPerRep => $composableBuilder(
    column: $table.xpPerRep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpPerSecond => $composableBuilder(
    column: $table.xpPerSecond,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> movementProgressesRefs(
    Expression<bool> Function($$MovementProgressesTableFilterComposer f) f,
  ) {
    final $$MovementProgressesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movementProgresses,
      getReferencedColumn: (t) => t.movementId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementProgressesTableFilterComposer(
            $db: $db,
            $table: $db.movementProgresses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.movementId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> movementGuidesRefs(
    Expression<bool> Function($$MovementGuidesTableFilterComposer f) f,
  ) {
    final $$MovementGuidesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movementGuides,
      getReferencedColumn: (t) => t.movementId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementGuidesTableFilterComposer(
            $db: $db,
            $table: $db.movementGuides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MovementsTableOrderingComposer
    extends Composer<_$AppDb, $MovementsTable> {
  $$MovementsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpToUnlock => $composableBuilder(
    column: $table.xpToUnlock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseXp => $composableBuilder(
    column: $table.baseXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpPerRep => $composableBuilder(
    column: $table.xpPerRep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpPerSecond => $composableBuilder(
    column: $table.xpPerSecond,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MovementsTableAnnotationComposer
    extends Composer<_$AppDb, $MovementsTable> {
  $$MovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpToUnlock => $composableBuilder(
    column: $table.xpToUnlock,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseXp =>
      $composableBuilder(column: $table.baseXp, builder: (column) => column);

  GeneratedColumn<int> get xpPerRep =>
      $composableBuilder(column: $table.xpPerRep, builder: (column) => column);

  GeneratedColumn<int> get xpPerSecond => $composableBuilder(
    column: $table.xpPerSecond,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> movementProgressesRefs<T extends Object>(
    Expression<T> Function($$MovementProgressesTableAnnotationComposer a) f,
  ) {
    final $$MovementProgressesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.movementProgresses,
          getReferencedColumn: (t) => t.movementId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MovementProgressesTableAnnotationComposer(
                $db: $db,
                $table: $db.movementProgresses,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.movementId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> movementGuidesRefs<T extends Object>(
    Expression<T> Function($$MovementGuidesTableAnnotationComposer a) f,
  ) {
    final $$MovementGuidesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movementGuides,
      getReferencedColumn: (t) => t.movementId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementGuidesTableAnnotationComposer(
            $db: $db,
            $table: $db.movementGuides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MovementsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $MovementsTable,
          Movement,
          $$MovementsTableFilterComposer,
          $$MovementsTableOrderingComposer,
          $$MovementsTableAnnotationComposer,
          $$MovementsTableCreateCompanionBuilder,
          $$MovementsTableUpdateCompanionBuilder,
          (Movement, $$MovementsTableReferences),
          Movement,
          PrefetchHooks Function({
            bool movementProgressesRefs,
            bool sessionsRefs,
            bool movementGuidesRefs,
          })
        > {
  $$MovementsTableTableManager(_$AppDb db, $MovementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> xpToUnlock = const Value.absent(),
                Value<int> baseXp = const Value.absent(),
                Value<int> xpPerRep = const Value.absent(),
                Value<int> xpPerSecond = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementsCompanion(
                id: id,
                name: name,
                category: category,
                difficulty: difficulty,
                description: description,
                xpToUnlock: xpToUnlock,
                baseXp: baseXp,
                xpPerRep: xpPerRep,
                xpPerSecond: xpPerSecond,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String category,
                required int difficulty,
                Value<String> description = const Value.absent(),
                Value<int> xpToUnlock = const Value.absent(),
                Value<int> baseXp = const Value.absent(),
                Value<int> xpPerRep = const Value.absent(),
                Value<int> xpPerSecond = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementsCompanion.insert(
                id: id,
                name: name,
                category: category,
                difficulty: difficulty,
                description: description,
                xpToUnlock: xpToUnlock,
                baseXp: baseXp,
                xpPerRep: xpPerRep,
                xpPerSecond: xpPerSecond,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MovementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                movementProgressesRefs = false,
                sessionsRefs = false,
                movementGuidesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (movementProgressesRefs) db.movementProgresses,
                    if (sessionsRefs) db.sessions,
                    if (movementGuidesRefs) db.movementGuides,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (movementProgressesRefs)
                        await $_getPrefetchedData<
                          Movement,
                          $MovementsTable,
                          MovementProgress
                        >(
                          currentTable: table,
                          referencedTable: $$MovementsTableReferences
                              ._movementProgressesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MovementsTableReferences(
                                db,
                                table,
                                p0,
                              ).movementProgressesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.movementId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionsRefs)
                        await $_getPrefetchedData<
                          Movement,
                          $MovementsTable,
                          Session
                        >(
                          currentTable: table,
                          referencedTable: $$MovementsTableReferences
                              ._sessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MovementsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.movementId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (movementGuidesRefs)
                        await $_getPrefetchedData<
                          Movement,
                          $MovementsTable,
                          MovementGuide
                        >(
                          currentTable: table,
                          referencedTable: $$MovementsTableReferences
                              ._movementGuidesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MovementsTableReferences(
                                db,
                                table,
                                p0,
                              ).movementGuidesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.movementId == item.id,
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

typedef $$MovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $MovementsTable,
      Movement,
      $$MovementsTableFilterComposer,
      $$MovementsTableOrderingComposer,
      $$MovementsTableAnnotationComposer,
      $$MovementsTableCreateCompanionBuilder,
      $$MovementsTableUpdateCompanionBuilder,
      (Movement, $$MovementsTableReferences),
      Movement,
      PrefetchHooks Function({
        bool movementProgressesRefs,
        bool sessionsRefs,
        bool movementGuidesRefs,
      })
    >;
typedef $$MovementPrereqsTableCreateCompanionBuilder =
    MovementPrereqsCompanion Function({
      required String movementId,
      required String prereqMovementId,
      Value<String> prereqType,
      Value<int> rowid,
    });
typedef $$MovementPrereqsTableUpdateCompanionBuilder =
    MovementPrereqsCompanion Function({
      Value<String> movementId,
      Value<String> prereqMovementId,
      Value<String> prereqType,
      Value<int> rowid,
    });

final class $$MovementPrereqsTableReferences
    extends BaseReferences<_$AppDb, $MovementPrereqsTable, MovementPrereq> {
  $$MovementPrereqsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MovementsTable _movementIdTable(_$AppDb db) =>
      db.movements.createAlias(
        $_aliasNameGenerator(db.movementPrereqs.movementId, db.movements.id),
      );

  $$MovementsTableProcessedTableManager get movementId {
    final $_column = $_itemColumn<String>('movement_id')!;

    final manager = $$MovementsTableTableManager(
      $_db,
      $_db.movements,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_movementIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MovementsTable _prereqMovementIdTable(_$AppDb db) =>
      db.movements.createAlias(
        $_aliasNameGenerator(
          db.movementPrereqs.prereqMovementId,
          db.movements.id,
        ),
      );

  $$MovementsTableProcessedTableManager get prereqMovementId {
    final $_column = $_itemColumn<String>('prereq_movement_id')!;

    final manager = $$MovementsTableTableManager(
      $_db,
      $_db.movements,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_prereqMovementIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MovementPrereqsTableFilterComposer
    extends Composer<_$AppDb, $MovementPrereqsTable> {
  $$MovementPrereqsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get prereqType => $composableBuilder(
    column: $table.prereqType,
    builder: (column) => ColumnFilters(column),
  );

  $$MovementsTableFilterComposer get movementId {
    final $$MovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.movementId,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableFilterComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MovementsTableFilterComposer get prereqMovementId {
    final $$MovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prereqMovementId,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableFilterComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementPrereqsTableOrderingComposer
    extends Composer<_$AppDb, $MovementPrereqsTable> {
  $$MovementPrereqsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get prereqType => $composableBuilder(
    column: $table.prereqType,
    builder: (column) => ColumnOrderings(column),
  );

  $$MovementsTableOrderingComposer get movementId {
    final $$MovementsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.movementId,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableOrderingComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MovementsTableOrderingComposer get prereqMovementId {
    final $$MovementsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prereqMovementId,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableOrderingComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementPrereqsTableAnnotationComposer
    extends Composer<_$AppDb, $MovementPrereqsTable> {
  $$MovementPrereqsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get prereqType => $composableBuilder(
    column: $table.prereqType,
    builder: (column) => column,
  );

  $$MovementsTableAnnotationComposer get movementId {
    final $$MovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.movementId,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MovementsTableAnnotationComposer get prereqMovementId {
    final $$MovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prereqMovementId,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementPrereqsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $MovementPrereqsTable,
          MovementPrereq,
          $$MovementPrereqsTableFilterComposer,
          $$MovementPrereqsTableOrderingComposer,
          $$MovementPrereqsTableAnnotationComposer,
          $$MovementPrereqsTableCreateCompanionBuilder,
          $$MovementPrereqsTableUpdateCompanionBuilder,
          (MovementPrereq, $$MovementPrereqsTableReferences),
          MovementPrereq,
          PrefetchHooks Function({bool movementId, bool prereqMovementId})
        > {
  $$MovementPrereqsTableTableManager(_$AppDb db, $MovementPrereqsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovementPrereqsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovementPrereqsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovementPrereqsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> movementId = const Value.absent(),
                Value<String> prereqMovementId = const Value.absent(),
                Value<String> prereqType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementPrereqsCompanion(
                movementId: movementId,
                prereqMovementId: prereqMovementId,
                prereqType: prereqType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String movementId,
                required String prereqMovementId,
                Value<String> prereqType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementPrereqsCompanion.insert(
                movementId: movementId,
                prereqMovementId: prereqMovementId,
                prereqType: prereqType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MovementPrereqsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({movementId = false, prereqMovementId = false}) {
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
                        if (movementId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.movementId,
                                    referencedTable:
                                        $$MovementPrereqsTableReferences
                                            ._movementIdTable(db),
                                    referencedColumn:
                                        $$MovementPrereqsTableReferences
                                            ._movementIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (prereqMovementId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.prereqMovementId,
                                    referencedTable:
                                        $$MovementPrereqsTableReferences
                                            ._prereqMovementIdTable(db),
                                    referencedColumn:
                                        $$MovementPrereqsTableReferences
                                            ._prereqMovementIdTable(db)
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

typedef $$MovementPrereqsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $MovementPrereqsTable,
      MovementPrereq,
      $$MovementPrereqsTableFilterComposer,
      $$MovementPrereqsTableOrderingComposer,
      $$MovementPrereqsTableAnnotationComposer,
      $$MovementPrereqsTableCreateCompanionBuilder,
      $$MovementPrereqsTableUpdateCompanionBuilder,
      (MovementPrereq, $$MovementPrereqsTableReferences),
      MovementPrereq,
      PrefetchHooks Function({bool movementId, bool prereqMovementId})
    >;
typedef $$MovementProgressesTableCreateCompanionBuilder =
    MovementProgressesCompanion Function({
      required String movementId,
      Value<String> state,
      Value<int> totalXp,
      Value<DateTime?> unlockedAt,
      Value<DateTime?> masteredAt,
      Value<int> bestReps,
      Value<int> bestHoldSeconds,
      Value<int> bestFormScore,
      Value<int> rowid,
    });
typedef $$MovementProgressesTableUpdateCompanionBuilder =
    MovementProgressesCompanion Function({
      Value<String> movementId,
      Value<String> state,
      Value<int> totalXp,
      Value<DateTime?> unlockedAt,
      Value<DateTime?> masteredAt,
      Value<int> bestReps,
      Value<int> bestHoldSeconds,
      Value<int> bestFormScore,
      Value<int> rowid,
    });

final class $$MovementProgressesTableReferences
    extends
        BaseReferences<_$AppDb, $MovementProgressesTable, MovementProgress> {
  $$MovementProgressesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MovementsTable _movementIdTable(_$AppDb db) =>
      db.movements.createAlias(
        $_aliasNameGenerator(db.movementProgresses.movementId, db.movements.id),
      );

  $$MovementsTableProcessedTableManager get movementId {
    final $_column = $_itemColumn<String>('movement_id')!;

    final manager = $$MovementsTableTableManager(
      $_db,
      $_db.movements,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_movementIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MovementProgressesTableFilterComposer
    extends Composer<_$AppDb, $MovementProgressesTable> {
  $$MovementProgressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get masteredAt => $composableBuilder(
    column: $table.masteredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestReps => $composableBuilder(
    column: $table.bestReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestHoldSeconds => $composableBuilder(
    column: $table.bestHoldSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestFormScore => $composableBuilder(
    column: $table.bestFormScore,
    builder: (column) => ColumnFilters(column),
  );

  $$MovementsTableFilterComposer get movementId {
    final $$MovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.movementId,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableFilterComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementProgressesTableOrderingComposer
    extends Composer<_$AppDb, $MovementProgressesTable> {
  $$MovementProgressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get masteredAt => $composableBuilder(
    column: $table.masteredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestReps => $composableBuilder(
    column: $table.bestReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestHoldSeconds => $composableBuilder(
    column: $table.bestHoldSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestFormScore => $composableBuilder(
    column: $table.bestFormScore,
    builder: (column) => ColumnOrderings(column),
  );

  $$MovementsTableOrderingComposer get movementId {
    final $$MovementsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.movementId,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableOrderingComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementProgressesTableAnnotationComposer
    extends Composer<_$AppDb, $MovementProgressesTable> {
  $$MovementProgressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get totalXp =>
      $composableBuilder(column: $table.totalXp, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get masteredAt => $composableBuilder(
    column: $table.masteredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestReps =>
      $composableBuilder(column: $table.bestReps, builder: (column) => column);

  GeneratedColumn<int> get bestHoldSeconds => $composableBuilder(
    column: $table.bestHoldSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestFormScore => $composableBuilder(
    column: $table.bestFormScore,
    builder: (column) => column,
  );

  $$MovementsTableAnnotationComposer get movementId {
    final $$MovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.movementId,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementProgressesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $MovementProgressesTable,
          MovementProgress,
          $$MovementProgressesTableFilterComposer,
          $$MovementProgressesTableOrderingComposer,
          $$MovementProgressesTableAnnotationComposer,
          $$MovementProgressesTableCreateCompanionBuilder,
          $$MovementProgressesTableUpdateCompanionBuilder,
          (MovementProgress, $$MovementProgressesTableReferences),
          MovementProgress,
          PrefetchHooks Function({bool movementId})
        > {
  $$MovementProgressesTableTableManager(
    _$AppDb db,
    $MovementProgressesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovementProgressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovementProgressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovementProgressesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> movementId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<DateTime?> masteredAt = const Value.absent(),
                Value<int> bestReps = const Value.absent(),
                Value<int> bestHoldSeconds = const Value.absent(),
                Value<int> bestFormScore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementProgressesCompanion(
                movementId: movementId,
                state: state,
                totalXp: totalXp,
                unlockedAt: unlockedAt,
                masteredAt: masteredAt,
                bestReps: bestReps,
                bestHoldSeconds: bestHoldSeconds,
                bestFormScore: bestFormScore,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String movementId,
                Value<String> state = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<DateTime?> masteredAt = const Value.absent(),
                Value<int> bestReps = const Value.absent(),
                Value<int> bestHoldSeconds = const Value.absent(),
                Value<int> bestFormScore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementProgressesCompanion.insert(
                movementId: movementId,
                state: state,
                totalXp: totalXp,
                unlockedAt: unlockedAt,
                masteredAt: masteredAt,
                bestReps: bestReps,
                bestHoldSeconds: bestHoldSeconds,
                bestFormScore: bestFormScore,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MovementProgressesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({movementId = false}) {
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
                    if (movementId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.movementId,
                                referencedTable:
                                    $$MovementProgressesTableReferences
                                        ._movementIdTable(db),
                                referencedColumn:
                                    $$MovementProgressesTableReferences
                                        ._movementIdTable(db)
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

typedef $$MovementProgressesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $MovementProgressesTable,
      MovementProgress,
      $$MovementProgressesTableFilterComposer,
      $$MovementProgressesTableOrderingComposer,
      $$MovementProgressesTableAnnotationComposer,
      $$MovementProgressesTableCreateCompanionBuilder,
      $$MovementProgressesTableUpdateCompanionBuilder,
      (MovementProgress, $$MovementProgressesTableReferences),
      MovementProgress,
      PrefetchHooks Function({bool movementId})
    >;
typedef $$WorkoutsTableCreateCompanionBuilder =
    WorkoutsCompanion Function({
      Value<int> id,
      required DateTime startedAt,
      Value<int> durationSeconds,
      Value<String?> notes,
    });
typedef $$WorkoutsTableUpdateCompanionBuilder =
    WorkoutsCompanion Function({
      Value<int> id,
      Value<DateTime> startedAt,
      Value<int> durationSeconds,
      Value<String?> notes,
    });

final class $$WorkoutsTableReferences
    extends BaseReferences<_$AppDb, $WorkoutsTable, Workout> {
  $$WorkoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDb db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: $_aliasNameGenerator(db.workouts.id, db.sessions.workoutId),
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutsTableFilterComposer extends Composer<_$AppDb, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutsTableOrderingComposer
    extends Composer<_$AppDb, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutsTableAnnotationComposer
    extends Composer<_$AppDb, $WorkoutsTable> {
  $$WorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $WorkoutsTable,
          Workout,
          $$WorkoutsTableFilterComposer,
          $$WorkoutsTableOrderingComposer,
          $$WorkoutsTableAnnotationComposer,
          $$WorkoutsTableCreateCompanionBuilder,
          $$WorkoutsTableUpdateCompanionBuilder,
          (Workout, $$WorkoutsTableReferences),
          Workout,
          PrefetchHooks Function({bool sessionsRefs})
        > {
  $$WorkoutsTableTableManager(_$AppDb db, $WorkoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => WorkoutsCompanion(
                id: id,
                startedAt: startedAt,
                durationSeconds: durationSeconds,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                Value<int> durationSeconds = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => WorkoutsCompanion.insert(
                id: id,
                startedAt: startedAt,
                durationSeconds: durationSeconds,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sessionsRefs) db.sessions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionsRefs)
                    await $_getPrefetchedData<Workout, $WorkoutsTable, Session>(
                      currentTable: table,
                      referencedTable: $$WorkoutsTableReferences
                          ._sessionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WorkoutsTableReferences(db, table, p0).sessionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.workoutId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $WorkoutsTable,
      Workout,
      $$WorkoutsTableFilterComposer,
      $$WorkoutsTableOrderingComposer,
      $$WorkoutsTableAnnotationComposer,
      $$WorkoutsTableCreateCompanionBuilder,
      $$WorkoutsTableUpdateCompanionBuilder,
      (Workout, $$WorkoutsTableReferences),
      Workout,
      PrefetchHooks Function({bool sessionsRefs})
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required String movementId,
      Value<int?> workoutId,
      Value<int> setIndex,
      Value<int> sets,
      required DateTime startedAt,
      Value<int> durationSeconds,
      Value<int> reps,
      Value<int> holdSeconds,
      Value<int> formScore,
      Value<String?> notes,
      Value<int> xpEarned,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<String> movementId,
      Value<int?> workoutId,
      Value<int> setIndex,
      Value<int> sets,
      Value<DateTime> startedAt,
      Value<int> durationSeconds,
      Value<int> reps,
      Value<int> holdSeconds,
      Value<int> formScore,
      Value<String?> notes,
      Value<int> xpEarned,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDb, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MovementsTable _movementIdTable(_$AppDb db) =>
      db.movements.createAlias(
        $_aliasNameGenerator(db.sessions.movementId, db.movements.id),
      );

  $$MovementsTableProcessedTableManager get movementId {
    final $_column = $_itemColumn<String>('movement_id')!;

    final manager = $$MovementsTableTableManager(
      $_db,
      $_db.movements,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_movementIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkoutsTable _workoutIdTable(_$AppDb db) => db.workouts.createAlias(
    $_aliasNameGenerator(db.sessions.workoutId, db.workouts.id),
  );

  $$WorkoutsTableProcessedTableManager? get workoutId {
    final $_column = $_itemColumn<int>('workout_id');
    if ($_column == null) return null;
    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionsTableFilterComposer extends Composer<_$AppDb, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get holdSeconds => $composableBuilder(
    column: $table.holdSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get formScore => $composableBuilder(
    column: $table.formScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnFilters(column),
  );

  $$MovementsTableFilterComposer get movementId {
    final $$MovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.movementId,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableFilterComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDb, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get holdSeconds => $composableBuilder(
    column: $table.holdSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get formScore => $composableBuilder(
    column: $table.formScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnOrderings(column),
  );

  $$MovementsTableOrderingComposer get movementId {
    final $$MovementsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.movementId,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableOrderingComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDb, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get setIndex =>
      $composableBuilder(column: $table.setIndex, builder: (column) => column);

  GeneratedColumn<int> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get holdSeconds => $composableBuilder(
    column: $table.holdSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get formScore =>
      $composableBuilder(column: $table.formScore, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get xpEarned =>
      $composableBuilder(column: $table.xpEarned, builder: (column) => column);

  $$MovementsTableAnnotationComposer get movementId {
    final $$MovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.movementId,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({bool movementId, bool workoutId})
        > {
  $$SessionsTableTableManager(_$AppDb db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> movementId = const Value.absent(),
                Value<int?> workoutId = const Value.absent(),
                Value<int> setIndex = const Value.absent(),
                Value<int> sets = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> holdSeconds = const Value.absent(),
                Value<int> formScore = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> xpEarned = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                movementId: movementId,
                workoutId: workoutId,
                setIndex: setIndex,
                sets: sets,
                startedAt: startedAt,
                durationSeconds: durationSeconds,
                reps: reps,
                holdSeconds: holdSeconds,
                formScore: formScore,
                notes: notes,
                xpEarned: xpEarned,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String movementId,
                Value<int?> workoutId = const Value.absent(),
                Value<int> setIndex = const Value.absent(),
                Value<int> sets = const Value.absent(),
                required DateTime startedAt,
                Value<int> durationSeconds = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> holdSeconds = const Value.absent(),
                Value<int> formScore = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> xpEarned = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                movementId: movementId,
                workoutId: workoutId,
                setIndex: setIndex,
                sets: sets,
                startedAt: startedAt,
                durationSeconds: durationSeconds,
                reps: reps,
                holdSeconds: holdSeconds,
                formScore: formScore,
                notes: notes,
                xpEarned: xpEarned,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({movementId = false, workoutId = false}) {
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
                    if (movementId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.movementId,
                                referencedTable: $$SessionsTableReferences
                                    ._movementIdTable(db),
                                referencedColumn: $$SessionsTableReferences
                                    ._movementIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (workoutId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workoutId,
                                referencedTable: $$SessionsTableReferences
                                    ._workoutIdTable(db),
                                referencedColumn: $$SessionsTableReferences
                                    ._workoutIdTable(db)
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

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({bool movementId, bool workoutId})
    >;
typedef $$UserStatsTableCreateCompanionBuilder =
    UserStatsCompanion Function({
      Value<int> id,
      Value<int> totalXp,
      Value<int> level,
      Value<int> perkPoints,
      Value<int> coins,
      Value<int> currentStreak,
      Value<int> bestStreak,
      Value<DateTime?> lastActiveDate,
    });
typedef $$UserStatsTableUpdateCompanionBuilder =
    UserStatsCompanion Function({
      Value<int> id,
      Value<int> totalXp,
      Value<int> level,
      Value<int> perkPoints,
      Value<int> coins,
      Value<int> currentStreak,
      Value<int> bestStreak,
      Value<DateTime?> lastActiveDate,
    });

class $$UserStatsTableFilterComposer
    extends Composer<_$AppDb, $UserStatsTable> {
  $$UserStatsTableFilterComposer({
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

  ColumnFilters<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get perkPoints => $composableBuilder(
    column: $table.perkPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coins => $composableBuilder(
    column: $table.coins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserStatsTableOrderingComposer
    extends Composer<_$AppDb, $UserStatsTable> {
  $$UserStatsTableOrderingComposer({
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

  ColumnOrderings<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get perkPoints => $composableBuilder(
    column: $table.perkPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coins => $composableBuilder(
    column: $table.coins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserStatsTableAnnotationComposer
    extends Composer<_$AppDb, $UserStatsTable> {
  $$UserStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get totalXp =>
      $composableBuilder(column: $table.totalXp, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get perkPoints => $composableBuilder(
    column: $table.perkPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coins =>
      $composableBuilder(column: $table.coins, builder: (column) => column);

  GeneratedColumn<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => column,
  );
}

class $$UserStatsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $UserStatsTable,
          UserStat,
          $$UserStatsTableFilterComposer,
          $$UserStatsTableOrderingComposer,
          $$UserStatsTableAnnotationComposer,
          $$UserStatsTableCreateCompanionBuilder,
          $$UserStatsTableUpdateCompanionBuilder,
          (UserStat, BaseReferences<_$AppDb, $UserStatsTable, UserStat>),
          UserStat,
          PrefetchHooks Function()
        > {
  $$UserStatsTableTableManager(_$AppDb db, $UserStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> perkPoints = const Value.absent(),
                Value<int> coins = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> bestStreak = const Value.absent(),
                Value<DateTime?> lastActiveDate = const Value.absent(),
              }) => UserStatsCompanion(
                id: id,
                totalXp: totalXp,
                level: level,
                perkPoints: perkPoints,
                coins: coins,
                currentStreak: currentStreak,
                bestStreak: bestStreak,
                lastActiveDate: lastActiveDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> perkPoints = const Value.absent(),
                Value<int> coins = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> bestStreak = const Value.absent(),
                Value<DateTime?> lastActiveDate = const Value.absent(),
              }) => UserStatsCompanion.insert(
                id: id,
                totalXp: totalXp,
                level: level,
                perkPoints: perkPoints,
                coins: coins,
                currentStreak: currentStreak,
                bestStreak: bestStreak,
                lastActiveDate: lastActiveDate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $UserStatsTable,
      UserStat,
      $$UserStatsTableFilterComposer,
      $$UserStatsTableOrderingComposer,
      $$UserStatsTableAnnotationComposer,
      $$UserStatsTableCreateCompanionBuilder,
      $$UserStatsTableUpdateCompanionBuilder,
      (UserStat, BaseReferences<_$AppDb, $UserStatsTable, UserStat>),
      UserStat,
      PrefetchHooks Function()
    >;
typedef $$UserPerksTableCreateCompanionBuilder =
    UserPerksCompanion Function({
      required String perkId,
      Value<int> level,
      Value<DateTime?> unlockedAt,
      Value<int> rowid,
    });
typedef $$UserPerksTableUpdateCompanionBuilder =
    UserPerksCompanion Function({
      Value<String> perkId,
      Value<int> level,
      Value<DateTime?> unlockedAt,
      Value<int> rowid,
    });

class $$UserPerksTableFilterComposer
    extends Composer<_$AppDb, $UserPerksTable> {
  $$UserPerksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get perkId => $composableBuilder(
    column: $table.perkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPerksTableOrderingComposer
    extends Composer<_$AppDb, $UserPerksTable> {
  $$UserPerksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get perkId => $composableBuilder(
    column: $table.perkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPerksTableAnnotationComposer
    extends Composer<_$AppDb, $UserPerksTable> {
  $$UserPerksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get perkId =>
      $composableBuilder(column: $table.perkId, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$UserPerksTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $UserPerksTable,
          UserPerk,
          $$UserPerksTableFilterComposer,
          $$UserPerksTableOrderingComposer,
          $$UserPerksTableAnnotationComposer,
          $$UserPerksTableCreateCompanionBuilder,
          $$UserPerksTableUpdateCompanionBuilder,
          (UserPerk, BaseReferences<_$AppDb, $UserPerksTable, UserPerk>),
          UserPerk,
          PrefetchHooks Function()
        > {
  $$UserPerksTableTableManager(_$AppDb db, $UserPerksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPerksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPerksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPerksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> perkId = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPerksCompanion(
                perkId: perkId,
                level: level,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String perkId,
                Value<int> level = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPerksCompanion.insert(
                perkId: perkId,
                level: level,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPerksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $UserPerksTable,
      UserPerk,
      $$UserPerksTableFilterComposer,
      $$UserPerksTableOrderingComposer,
      $$UserPerksTableAnnotationComposer,
      $$UserPerksTableCreateCompanionBuilder,
      $$UserPerksTableUpdateCompanionBuilder,
      (UserPerk, BaseReferences<_$AppDb, $UserPerksTable, UserPerk>),
      UserPerk,
      PrefetchHooks Function()
    >;
typedef $$DailyQuestClaimsTableCreateCompanionBuilder =
    DailyQuestClaimsCompanion Function({
      required String questId,
      required String claimDate,
      required DateTime claimedAt,
      Value<int> rowid,
    });
typedef $$DailyQuestClaimsTableUpdateCompanionBuilder =
    DailyQuestClaimsCompanion Function({
      Value<String> questId,
      Value<String> claimDate,
      Value<DateTime> claimedAt,
      Value<int> rowid,
    });

class $$DailyQuestClaimsTableFilterComposer
    extends Composer<_$AppDb, $DailyQuestClaimsTable> {
  $$DailyQuestClaimsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get questId => $composableBuilder(
    column: $table.questId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get claimDate => $composableBuilder(
    column: $table.claimDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get claimedAt => $composableBuilder(
    column: $table.claimedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyQuestClaimsTableOrderingComposer
    extends Composer<_$AppDb, $DailyQuestClaimsTable> {
  $$DailyQuestClaimsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get questId => $composableBuilder(
    column: $table.questId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get claimDate => $composableBuilder(
    column: $table.claimDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get claimedAt => $composableBuilder(
    column: $table.claimedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyQuestClaimsTableAnnotationComposer
    extends Composer<_$AppDb, $DailyQuestClaimsTable> {
  $$DailyQuestClaimsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get questId =>
      $composableBuilder(column: $table.questId, builder: (column) => column);

  GeneratedColumn<String> get claimDate =>
      $composableBuilder(column: $table.claimDate, builder: (column) => column);

  GeneratedColumn<DateTime> get claimedAt =>
      $composableBuilder(column: $table.claimedAt, builder: (column) => column);
}

class $$DailyQuestClaimsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $DailyQuestClaimsTable,
          DailyQuestClaim,
          $$DailyQuestClaimsTableFilterComposer,
          $$DailyQuestClaimsTableOrderingComposer,
          $$DailyQuestClaimsTableAnnotationComposer,
          $$DailyQuestClaimsTableCreateCompanionBuilder,
          $$DailyQuestClaimsTableUpdateCompanionBuilder,
          (
            DailyQuestClaim,
            BaseReferences<_$AppDb, $DailyQuestClaimsTable, DailyQuestClaim>,
          ),
          DailyQuestClaim,
          PrefetchHooks Function()
        > {
  $$DailyQuestClaimsTableTableManager(_$AppDb db, $DailyQuestClaimsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyQuestClaimsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyQuestClaimsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyQuestClaimsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> questId = const Value.absent(),
                Value<String> claimDate = const Value.absent(),
                Value<DateTime> claimedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyQuestClaimsCompanion(
                questId: questId,
                claimDate: claimDate,
                claimedAt: claimedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String questId,
                required String claimDate,
                required DateTime claimedAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyQuestClaimsCompanion.insert(
                questId: questId,
                claimDate: claimDate,
                claimedAt: claimedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyQuestClaimsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $DailyQuestClaimsTable,
      DailyQuestClaim,
      $$DailyQuestClaimsTableFilterComposer,
      $$DailyQuestClaimsTableOrderingComposer,
      $$DailyQuestClaimsTableAnnotationComposer,
      $$DailyQuestClaimsTableCreateCompanionBuilder,
      $$DailyQuestClaimsTableUpdateCompanionBuilder,
      (
        DailyQuestClaim,
        BaseReferences<_$AppDb, $DailyQuestClaimsTable, DailyQuestClaim>,
      ),
      DailyQuestClaim,
      PrefetchHooks Function()
    >;
typedef $$BadgesTableCreateCompanionBuilder =
    BadgesCompanion Function({
      required String id,
      required String name,
      required String description,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$BadgesTableUpdateCompanionBuilder =
    BadgesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$BadgesTableReferences
    extends BaseReferences<_$AppDb, $BadgesTable, Badge> {
  $$BadgesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserBadgesTable, List<UserBadge>>
  _userBadgesRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.userBadges,
    aliasName: $_aliasNameGenerator(db.badges.id, db.userBadges.badgeId),
  );

  $$UserBadgesTableProcessedTableManager get userBadgesRefs {
    final manager = $$UserBadgesTableTableManager(
      $_db,
      $_db.userBadges,
    ).filter((f) => f.badgeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userBadgesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BadgesTableFilterComposer extends Composer<_$AppDb, $BadgesTable> {
  $$BadgesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userBadgesRefs(
    Expression<bool> Function($$UserBadgesTableFilterComposer f) f,
  ) {
    final $$UserBadgesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userBadges,
      getReferencedColumn: (t) => t.badgeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserBadgesTableFilterComposer(
            $db: $db,
            $table: $db.userBadges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BadgesTableOrderingComposer extends Composer<_$AppDb, $BadgesTable> {
  $$BadgesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BadgesTableAnnotationComposer extends Composer<_$AppDb, $BadgesTable> {
  $$BadgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> userBadgesRefs<T extends Object>(
    Expression<T> Function($$UserBadgesTableAnnotationComposer a) f,
  ) {
    final $$UserBadgesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userBadges,
      getReferencedColumn: (t) => t.badgeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserBadgesTableAnnotationComposer(
            $db: $db,
            $table: $db.userBadges,
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
          _$AppDb,
          $BadgesTable,
          Badge,
          $$BadgesTableFilterComposer,
          $$BadgesTableOrderingComposer,
          $$BadgesTableAnnotationComposer,
          $$BadgesTableCreateCompanionBuilder,
          $$BadgesTableUpdateCompanionBuilder,
          (Badge, $$BadgesTableReferences),
          Badge,
          PrefetchHooks Function({bool userBadgesRefs})
        > {
  $$BadgesTableTableManager(_$AppDb db, $BadgesTable table)
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
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BadgesCompanion(
                id: id,
                name: name,
                description: description,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String description,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BadgesCompanion.insert(
                id: id,
                name: name,
                description: description,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BadgesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({userBadgesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (userBadgesRefs) db.userBadges],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userBadgesRefs)
                    await $_getPrefetchedData<Badge, $BadgesTable, UserBadge>(
                      currentTable: table,
                      referencedTable: $$BadgesTableReferences
                          ._userBadgesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BadgesTableReferences(db, table, p0).userBadgesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.badgeId == item.id),
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
      _$AppDb,
      $BadgesTable,
      Badge,
      $$BadgesTableFilterComposer,
      $$BadgesTableOrderingComposer,
      $$BadgesTableAnnotationComposer,
      $$BadgesTableCreateCompanionBuilder,
      $$BadgesTableUpdateCompanionBuilder,
      (Badge, $$BadgesTableReferences),
      Badge,
      PrefetchHooks Function({bool userBadgesRefs})
    >;
typedef $$UserBadgesTableCreateCompanionBuilder =
    UserBadgesCompanion Function({
      required String badgeId,
      required DateTime earnedAt,
      Value<int> rowid,
    });
typedef $$UserBadgesTableUpdateCompanionBuilder =
    UserBadgesCompanion Function({
      Value<String> badgeId,
      Value<DateTime> earnedAt,
      Value<int> rowid,
    });

final class $$UserBadgesTableReferences
    extends BaseReferences<_$AppDb, $UserBadgesTable, UserBadge> {
  $$UserBadgesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BadgesTable _badgeIdTable(_$AppDb db) => db.badges.createAlias(
    $_aliasNameGenerator(db.userBadges.badgeId, db.badges.id),
  );

  $$BadgesTableProcessedTableManager get badgeId {
    final $_column = $_itemColumn<String>('badge_id')!;

    final manager = $$BadgesTableTableManager(
      $_db,
      $_db.badges,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_badgeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserBadgesTableFilterComposer
    extends Composer<_$AppDb, $UserBadgesTable> {
  $$UserBadgesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get earnedAt => $composableBuilder(
    column: $table.earnedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BadgesTableFilterComposer get badgeId {
    final $$BadgesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.badgeId,
      referencedTable: $db.badges,
      getReferencedColumn: (t) => t.id,
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
}

class $$UserBadgesTableOrderingComposer
    extends Composer<_$AppDb, $UserBadgesTable> {
  $$UserBadgesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get earnedAt => $composableBuilder(
    column: $table.earnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BadgesTableOrderingComposer get badgeId {
    final $$BadgesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.badgeId,
      referencedTable: $db.badges,
      getReferencedColumn: (t) => t.id,
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
}

class $$UserBadgesTableAnnotationComposer
    extends Composer<_$AppDb, $UserBadgesTable> {
  $$UserBadgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get earnedAt =>
      $composableBuilder(column: $table.earnedAt, builder: (column) => column);

  $$BadgesTableAnnotationComposer get badgeId {
    final $$BadgesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.badgeId,
      referencedTable: $db.badges,
      getReferencedColumn: (t) => t.id,
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
}

class $$UserBadgesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $UserBadgesTable,
          UserBadge,
          $$UserBadgesTableFilterComposer,
          $$UserBadgesTableOrderingComposer,
          $$UserBadgesTableAnnotationComposer,
          $$UserBadgesTableCreateCompanionBuilder,
          $$UserBadgesTableUpdateCompanionBuilder,
          (UserBadge, $$UserBadgesTableReferences),
          UserBadge,
          PrefetchHooks Function({bool badgeId})
        > {
  $$UserBadgesTableTableManager(_$AppDb db, $UserBadgesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserBadgesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserBadgesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserBadgesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> badgeId = const Value.absent(),
                Value<DateTime> earnedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserBadgesCompanion(
                badgeId: badgeId,
                earnedAt: earnedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String badgeId,
                required DateTime earnedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserBadgesCompanion.insert(
                badgeId: badgeId,
                earnedAt: earnedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserBadgesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({badgeId = false}) {
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
                    if (badgeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.badgeId,
                                referencedTable: $$UserBadgesTableReferences
                                    ._badgeIdTable(db),
                                referencedColumn: $$UserBadgesTableReferences
                                    ._badgeIdTable(db)
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

typedef $$UserBadgesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $UserBadgesTable,
      UserBadge,
      $$UserBadgesTableFilterComposer,
      $$UserBadgesTableOrderingComposer,
      $$UserBadgesTableAnnotationComposer,
      $$UserBadgesTableCreateCompanionBuilder,
      $$UserBadgesTableUpdateCompanionBuilder,
      (UserBadge, $$UserBadgesTableReferences),
      UserBadge,
      PrefetchHooks Function({bool badgeId})
    >;
typedef $$MovementGuidesTableCreateCompanionBuilder =
    MovementGuidesCompanion Function({
      required String movementId,
      Value<String> primaryMuscles,
      Value<String> secondaryMuscles,
      Value<String> setup,
      Value<String> execution,
      Value<String> cues,
      Value<String> commonMistakes,
      Value<String> regressions,
      Value<String> progressions,
      Value<String> youtubeQuery,
      Value<int> rowid,
    });
typedef $$MovementGuidesTableUpdateCompanionBuilder =
    MovementGuidesCompanion Function({
      Value<String> movementId,
      Value<String> primaryMuscles,
      Value<String> secondaryMuscles,
      Value<String> setup,
      Value<String> execution,
      Value<String> cues,
      Value<String> commonMistakes,
      Value<String> regressions,
      Value<String> progressions,
      Value<String> youtubeQuery,
      Value<int> rowid,
    });

final class $$MovementGuidesTableReferences
    extends BaseReferences<_$AppDb, $MovementGuidesTable, MovementGuide> {
  $$MovementGuidesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MovementsTable _movementIdTable(_$AppDb db) =>
      db.movements.createAlias(
        $_aliasNameGenerator(db.movementGuides.movementId, db.movements.id),
      );

  $$MovementsTableProcessedTableManager get movementId {
    final $_column = $_itemColumn<String>('movement_id')!;

    final manager = $$MovementsTableTableManager(
      $_db,
      $_db.movements,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_movementIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MovementGuidesTableFilterComposer
    extends Composer<_$AppDb, $MovementGuidesTable> {
  $$MovementGuidesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setup => $composableBuilder(
    column: $table.setup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get execution => $composableBuilder(
    column: $table.execution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cues => $composableBuilder(
    column: $table.cues,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commonMistakes => $composableBuilder(
    column: $table.commonMistakes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regressions => $composableBuilder(
    column: $table.regressions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get progressions => $composableBuilder(
    column: $table.progressions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get youtubeQuery => $composableBuilder(
    column: $table.youtubeQuery,
    builder: (column) => ColumnFilters(column),
  );

  $$MovementsTableFilterComposer get movementId {
    final $$MovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.movementId,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableFilterComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementGuidesTableOrderingComposer
    extends Composer<_$AppDb, $MovementGuidesTable> {
  $$MovementGuidesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setup => $composableBuilder(
    column: $table.setup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get execution => $composableBuilder(
    column: $table.execution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cues => $composableBuilder(
    column: $table.cues,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commonMistakes => $composableBuilder(
    column: $table.commonMistakes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regressions => $composableBuilder(
    column: $table.regressions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get progressions => $composableBuilder(
    column: $table.progressions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get youtubeQuery => $composableBuilder(
    column: $table.youtubeQuery,
    builder: (column) => ColumnOrderings(column),
  );

  $$MovementsTableOrderingComposer get movementId {
    final $$MovementsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.movementId,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableOrderingComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementGuidesTableAnnotationComposer
    extends Composer<_$AppDb, $MovementGuidesTable> {
  $$MovementGuidesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get setup =>
      $composableBuilder(column: $table.setup, builder: (column) => column);

  GeneratedColumn<String> get execution =>
      $composableBuilder(column: $table.execution, builder: (column) => column);

  GeneratedColumn<String> get cues =>
      $composableBuilder(column: $table.cues, builder: (column) => column);

  GeneratedColumn<String> get commonMistakes => $composableBuilder(
    column: $table.commonMistakes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get regressions => $composableBuilder(
    column: $table.regressions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get progressions => $composableBuilder(
    column: $table.progressions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get youtubeQuery => $composableBuilder(
    column: $table.youtubeQuery,
    builder: (column) => column,
  );

  $$MovementsTableAnnotationComposer get movementId {
    final $$MovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.movementId,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementGuidesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $MovementGuidesTable,
          MovementGuide,
          $$MovementGuidesTableFilterComposer,
          $$MovementGuidesTableOrderingComposer,
          $$MovementGuidesTableAnnotationComposer,
          $$MovementGuidesTableCreateCompanionBuilder,
          $$MovementGuidesTableUpdateCompanionBuilder,
          (MovementGuide, $$MovementGuidesTableReferences),
          MovementGuide,
          PrefetchHooks Function({bool movementId})
        > {
  $$MovementGuidesTableTableManager(_$AppDb db, $MovementGuidesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovementGuidesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovementGuidesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovementGuidesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> movementId = const Value.absent(),
                Value<String> primaryMuscles = const Value.absent(),
                Value<String> secondaryMuscles = const Value.absent(),
                Value<String> setup = const Value.absent(),
                Value<String> execution = const Value.absent(),
                Value<String> cues = const Value.absent(),
                Value<String> commonMistakes = const Value.absent(),
                Value<String> regressions = const Value.absent(),
                Value<String> progressions = const Value.absent(),
                Value<String> youtubeQuery = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementGuidesCompanion(
                movementId: movementId,
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles,
                setup: setup,
                execution: execution,
                cues: cues,
                commonMistakes: commonMistakes,
                regressions: regressions,
                progressions: progressions,
                youtubeQuery: youtubeQuery,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String movementId,
                Value<String> primaryMuscles = const Value.absent(),
                Value<String> secondaryMuscles = const Value.absent(),
                Value<String> setup = const Value.absent(),
                Value<String> execution = const Value.absent(),
                Value<String> cues = const Value.absent(),
                Value<String> commonMistakes = const Value.absent(),
                Value<String> regressions = const Value.absent(),
                Value<String> progressions = const Value.absent(),
                Value<String> youtubeQuery = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementGuidesCompanion.insert(
                movementId: movementId,
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles,
                setup: setup,
                execution: execution,
                cues: cues,
                commonMistakes: commonMistakes,
                regressions: regressions,
                progressions: progressions,
                youtubeQuery: youtubeQuery,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MovementGuidesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({movementId = false}) {
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
                    if (movementId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.movementId,
                                referencedTable: $$MovementGuidesTableReferences
                                    ._movementIdTable(db),
                                referencedColumn:
                                    $$MovementGuidesTableReferences
                                        ._movementIdTable(db)
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

typedef $$MovementGuidesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $MovementGuidesTable,
      MovementGuide,
      $$MovementGuidesTableFilterComposer,
      $$MovementGuidesTableOrderingComposer,
      $$MovementGuidesTableAnnotationComposer,
      $$MovementGuidesTableCreateCompanionBuilder,
      $$MovementGuidesTableUpdateCompanionBuilder,
      (MovementGuide, $$MovementGuidesTableReferences),
      MovementGuide,
      PrefetchHooks Function({bool movementId})
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$MovementsTableTableManager get movements =>
      $$MovementsTableTableManager(_db, _db.movements);
  $$MovementPrereqsTableTableManager get movementPrereqs =>
      $$MovementPrereqsTableTableManager(_db, _db.movementPrereqs);
  $$MovementProgressesTableTableManager get movementProgresses =>
      $$MovementProgressesTableTableManager(_db, _db.movementProgresses);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db, _db.workouts);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$UserStatsTableTableManager get userStats =>
      $$UserStatsTableTableManager(_db, _db.userStats);
  $$UserPerksTableTableManager get userPerks =>
      $$UserPerksTableTableManager(_db, _db.userPerks);
  $$DailyQuestClaimsTableTableManager get dailyQuestClaims =>
      $$DailyQuestClaimsTableTableManager(_db, _db.dailyQuestClaims);
  $$BadgesTableTableManager get badges =>
      $$BadgesTableTableManager(_db, _db.badges);
  $$UserBadgesTableTableManager get userBadges =>
      $$UserBadgesTableTableManager(_db, _db.userBadges);
  $$MovementGuidesTableTableManager get movementGuides =>
      $$MovementGuidesTableTableManager(_db, _db.movementGuides);
}
