// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_general.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetIsarGeneralsCollection on Isar {
  IsarCollection<int, IsarGenerals> get isarGenerals => this.collection();
}

const IsarGeneralsSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'IsarGenerals',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'name',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'value',
        type: IsarType.json,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'name',
        properties: [
          "name",
        ],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, IsarGenerals>(
    serialize: serializeIsarGenerals,
    deserialize: deserializeIsarGenerals,
    deserializeProperty: deserializeIsarGeneralsProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeIsarGenerals(IsarWriter writer, IsarGenerals object) {
  IsarCore.writeString(writer, 1, object.name);
  IsarCore.writeString(writer, 2, isarJsonEncode(object.value));
  return object.id;
}

@isarProtected
IsarGenerals deserializeIsarGenerals(IsarReader reader) {
  final String _name;
  _name = IsarCore.readString(reader, 1) ?? '';
  final dynamic _value;
  _value = isarJsonDecode(IsarCore.readString(reader, 2) ?? 'null') ?? null;
  final object = IsarGenerals(
    name: _name,
    value: _value,
  );
  object.id = IsarCore.readId(reader);
  return object;
}

@isarProtected
dynamic deserializeIsarGeneralsProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return isarJsonDecode(IsarCore.readString(reader, 2) ?? 'null') ?? null;
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _IsarGeneralsUpdate {
  bool call({
    required int id,
    String? name,
  });
}

class _IsarGeneralsUpdateImpl implements _IsarGeneralsUpdate {
  const _IsarGeneralsUpdateImpl(this.collection);

  final IsarCollection<int, IsarGenerals> collection;

  @override
  bool call({
    required int id,
    Object? name = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (name != ignore) 1: name as String?,
        }) >
        0;
  }
}

sealed class _IsarGeneralsUpdateAll {
  int call({
    required List<int> id,
    String? name,
  });
}

class _IsarGeneralsUpdateAllImpl implements _IsarGeneralsUpdateAll {
  const _IsarGeneralsUpdateAllImpl(this.collection);

  final IsarCollection<int, IsarGenerals> collection;

  @override
  int call({
    required List<int> id,
    Object? name = ignore,
  }) {
    return collection.updateProperties(id, {
      if (name != ignore) 1: name as String?,
    });
  }
}

extension IsarGeneralsUpdate on IsarCollection<int, IsarGenerals> {
  _IsarGeneralsUpdate get update => _IsarGeneralsUpdateImpl(this);

  _IsarGeneralsUpdateAll get updateAll => _IsarGeneralsUpdateAllImpl(this);
}

sealed class _IsarGeneralsQueryUpdate {
  int call({
    String? name,
  });
}

class _IsarGeneralsQueryUpdateImpl implements _IsarGeneralsQueryUpdate {
  const _IsarGeneralsQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<IsarGenerals> query;
  final int? limit;

  @override
  int call({
    Object? name = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (name != ignore) 1: name as String?,
    });
  }
}

extension IsarGeneralsQueryUpdate on IsarQuery<IsarGenerals> {
  _IsarGeneralsQueryUpdate get updateFirst =>
      _IsarGeneralsQueryUpdateImpl(this, limit: 1);

  _IsarGeneralsQueryUpdate get updateAll => _IsarGeneralsQueryUpdateImpl(this);
}

class _IsarGeneralsQueryBuilderUpdateImpl implements _IsarGeneralsQueryUpdate {
  const _IsarGeneralsQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<IsarGenerals, IsarGenerals, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? name = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (name != ignore) 1: name as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension IsarGeneralsQueryBuilderUpdate
    on QueryBuilder<IsarGenerals, IsarGenerals, QOperations> {
  _IsarGeneralsQueryUpdate get updateFirst =>
      _IsarGeneralsQueryBuilderUpdateImpl(this, limit: 1);

  _IsarGeneralsQueryUpdate get updateAll =>
      _IsarGeneralsQueryBuilderUpdateImpl(this);
}

extension IsarGeneralsQueryFilter
    on QueryBuilder<IsarGenerals, IsarGenerals, QFilterCondition> {
  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition>
      idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 0,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition>
      nameGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition> nameLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition>
      nameLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }
}

extension IsarGeneralsQueryObject
    on QueryBuilder<IsarGenerals, IsarGenerals, QFilterCondition> {}

extension IsarGeneralsQuerySortBy
    on QueryBuilder<IsarGenerals, IsarGenerals, QSortBy> {
  QueryBuilder<IsarGenerals, IsarGenerals, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterSortBy> sortByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterSortBy> sortByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterSortBy> sortByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterSortBy> sortByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }
}

extension IsarGeneralsQuerySortThenBy
    on QueryBuilder<IsarGenerals, IsarGenerals, QSortThenBy> {
  QueryBuilder<IsarGenerals, IsarGenerals, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterSortBy> thenByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterSortBy> thenByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterSortBy> thenByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterSortBy> thenByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }
}

extension IsarGeneralsQueryWhereDistinct
    on QueryBuilder<IsarGenerals, IsarGenerals, QDistinct> {
  QueryBuilder<IsarGenerals, IsarGenerals, QAfterDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarGenerals, IsarGenerals, QAfterDistinct> distinctByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }
}

extension IsarGeneralsQueryProperty1
    on QueryBuilder<IsarGenerals, IsarGenerals, QProperty> {
  QueryBuilder<IsarGenerals, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<IsarGenerals, String, QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<IsarGenerals, dynamic, QAfterProperty> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension IsarGeneralsQueryProperty2<R>
    on QueryBuilder<IsarGenerals, R, QAfterProperty> {
  QueryBuilder<IsarGenerals, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<IsarGenerals, (R, String), QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<IsarGenerals, (R, dynamic), QAfterProperty> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension IsarGeneralsQueryProperty3<R1, R2>
    on QueryBuilder<IsarGenerals, (R1, R2), QAfterProperty> {
  QueryBuilder<IsarGenerals, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<IsarGenerals, (R1, R2, String), QOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<IsarGenerals, (R1, R2, dynamic), QOperations> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}
