import 'package:drift/drift.dart';

/// Number Search Parameter Table
class NumberSearchParameters extends Table {
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

  /// The value as a number, when the element is a single number.
  RealColumn get numberValue => real().nullable()();

  /// The inclusive low bound of the value's range. R4B 3.1.1.4.5: "Searches
  /// are always performed on values that are implicitly or explicitly a
  /// range"; a decimal covers half a unit of its last significant digit
  /// either side (`2.0` is 1.95–2.05), an integer is a point.
  RealColumn get numberLow => real().nullable()();

  /// The exclusive high bound of the value's range; equal to [numberLow] for
  /// a point.
  RealColumn get numberHigh => real().nullable()();

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
