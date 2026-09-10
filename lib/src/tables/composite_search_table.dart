import 'package:drift/drift.dart';

/// Composite Search Parameter Table, R4B §3.1.1.4.17.
///
/// One row per element the composite is defined on (an
/// `Observation.component`, a `useContext`, a `Group.characteristic`, or
/// the resource itself) per combination of its components' values, so that
/// a `$`-joined search value is matched against values that sit on the SAME
/// element — "you need find a combination of key/value, not an intersection
/// of separate matches on key and value". Up to three components, each in
/// its own typed slot: what a token, quantity, number, date, string or
/// reference row would carry in its own table, reduced to five columns.
class CompositeSearchParameters extends Table {
  /// FHIR resource type name
  TextColumn get resourceType => text()();

  /// Resource logical id
  TextColumn get id => text()();

  /// When the resource was last updated
  IntColumn get lastUpdated => integer()();

  /// HTTP search parameter name (e.g., 'code-value-quantity')
  TextColumn get searchName => text().withDefault(const Constant(''))();

  /// Distinguishes the rows of one element and one parameter
  IntColumn get paramIndex => integer()();

  /// Component 1: its type (token, quantity, number, date, string,
  /// reference), then the same fields its own index table would hold.
  TextColumn get c1Type => text()();

  /// Token system, quantity system, reference resource type; else null.
  TextColumn get c1System => text().nullable()();

  /// Token code, quantity code, normalized string, reference id part.
  TextColumn get c1Value => text().nullable()();

  /// Reference as written, quantity unit; else null.
  TextColumn get c1Raw => text().nullable()();

  /// Inclusive low bound: number and quantity ranges, dates as seconds.
  RealColumn get c1Low => real().nullable()();

  /// Exclusive high bound; see [c1Low].
  RealColumn get c1High => real().nullable()();

  /// Component 2, as [c1Type].
  TextColumn get c2Type => text()();

  /// As [c1System].
  TextColumn get c2System => text().nullable()();

  /// As [c1Value].
  TextColumn get c2Value => text().nullable()();

  /// As [c1Raw].
  TextColumn get c2Raw => text().nullable()();

  /// As [c1Low].
  RealColumn get c2Low => real().nullable()();

  /// As [c1High].
  RealColumn get c2High => real().nullable()();

  /// Component 3, present on four MolecularSequence parameters; null type
  /// when the composite has two components.
  TextColumn get c3Type => text().nullable()();

  /// As [c1System].
  TextColumn get c3System => text().nullable()();

  /// As [c1Value].
  TextColumn get c3Value => text().nullable()();

  /// As [c1Raw].
  TextColumn get c3Raw => text().nullable()();

  /// As [c1Low].
  RealColumn get c3Low => real().nullable()();

  /// As [c1High].
  RealColumn get c3High => real().nullable()();

  /// No declared key: a rowid table. The key used to be
  /// `(resource_type, id, search_path, search_name, param_index)`, which
  /// stored the FHIRPath of every row in a second copy inside a unique
  /// index that no search read (measured 2026-09-06 on 929k MIMIC
  /// resources: 1.16 GB of key indexes across the nine tables, REVIEW
  /// §4.4-4.5). What a search reads is the covering indexes and what a
  /// re-index deletes by is the owner index, both in
  /// `FhirDb.createValueIndexes`. Two rows that only differed in their path
  /// (Observation.code and Observation.component.code under `combo-code`)
  /// are simply two rows.
}
