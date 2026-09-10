import 'package:drift/drift.dart';

/// String Search Parameter Table
class StringSearchParameters extends Table {
  /// FHIR resource type name
  TextColumn get resourceType => text()();

  /// Resource logical id
  TextColumn get id => text()();

  /// When the resource was last updated
  IntColumn get lastUpdated => integer()();

  /// HTTP search parameter name (e.g., 'monitoring-program-name')
  TextColumn get searchName => text().withDefault(const Constant(''))();

  /// Index for multiple values from the same path.
  ///
  /// Convention, relied on by `_sort`: a row holding a WHOLE value of the
  /// parameter has a multiple of 100 here; the rows holding one word of a
  /// name part (see [StringSearchParametersExtension.toStringSearchParameter])
  /// have that multiple plus the word's position, 1..99. Every branch below
  /// keeps to it, so a sort can take the whole rows with `% 100 = 0` and no
  /// flag column is needed.
  IntColumn get paramIndex => integer()();

  /// Normalized string value for case- and accent-insensitive searches.
  ///
  /// R4 3.1.1.4.8: a string search "is insensitive to casing and included
  /// combining characters, like accents or other diacritical marks", and by
  /// default "a field matches ... if the value of the field equals or starts
  /// with the supplied parameter value, after both have been normalized by
  /// case and combining characters".
  TextColumn get stringValue => text()();

  /// The value exactly as it was written, for `:exact`.
  ///
  /// R4 3.1.1.4.4: ":exact returns results that match the entire supplied
  /// parameter, including casing and combining characters." That is
  /// unanswerable from the normalized column, because normalizing destroys the
  /// casing and the accents it has to compare. Both are needed, which is what
  /// HAPI does: SP_VALUE_NORMALIZED beside SP_VALUE_EXACT.
  ///
  /// Not nullable: the upgrade rebuilds this index from the stored resources,
  /// so there is no row without one. A nullable column would have meant
  /// `:exact` silently ignoring every record written before the upgrade,
  /// which is a wrong answer rather than an error.
  TextColumn get exactValue => text().withDefault(const Constant(''))();

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
