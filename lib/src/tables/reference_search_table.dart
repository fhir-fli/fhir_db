import 'package:drift/drift.dart';

/// Enhanced Reference Search Parameter Table
class ReferenceSearchParameters extends Table {
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

  /// Original reference string as it appears in the resource.
  /// Nullable for identifier-only references (no URL, just identifier).
  TextColumn get referenceValue => text().nullable()();

  /// Parsed target resource type (e.g. 'Patient')
  TextColumn get referenceResourceType => text().nullable()();

  /// Parsed target resource id
  TextColumn get referenceIdPart => text().nullable()();

  /// Parsed version from versioned references
  TextColumn get referenceVersion => text().nullable()();

  /// Parsed base URL for absolute references
  TextColumn get referenceBaseUrl => text().nullable()();

  /// Identifier system for identifier-based references
  TextColumn get identifierSystem => text().nullable()();

  /// Identifier value for identifier-based references
  TextColumn get identifierValue => text().nullable()();

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
