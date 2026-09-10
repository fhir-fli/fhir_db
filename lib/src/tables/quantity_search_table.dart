import 'package:drift/drift.dart';

/// Quantity Search Parameter Table
class QuantitySearchParameters extends Table {
  /// FHIR resource type name
  TextColumn get resourceType => text()();

  /// Resource logical id
  TextColumn get id => text()();

  /// When the resource was last updated
  IntColumn get lastUpdated => integer()();

  /// HTTP search parameter name (e.g., 'monitoring-program-name')
  TextColumn get searchName => text().withDefault(const Constant(''))();

  /// Index for multiple values from the same path
  IntColumn get paramIndex => integer()();

  /// The numeric value part of the quantity
  /// The value as a number, when the element has one (not a Range).
  RealColumn get quantityValue => real().nullable()();

  /// The inclusive low bound of the value's range: a Quantity covers half
  /// a unit of its last significant digit either side (R4B 3.1.1.4.5); a
  /// Range runs from its `low` to its `high`. A Range with no `low` is
  /// stored as -infinity (schema 11; it was NULL, which made every prefix
  /// an OR the index could not seek).
  RealColumn get quantityLow => real().nullable()();

  /// The exclusive high bound of the value's range; +infinity for a Range
  /// with no `high` (schema 11).
  RealColumn get quantityHigh => real().nullable()();

  /// Unit (optional)
  TextColumn get quantityUnit => text().nullable()();

  /// Unit system (optional)
  TextColumn get quantitySystem => text().nullable()();

  /// Coded representation of the unit (optional)
  TextColumn get quantityCode => text().nullable()();

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
