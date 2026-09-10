import 'package:drift/drift.dart';

/// Date Search Parameter Table.
///
/// Every row is a RANGE, `[dateValue, dateValueEnd)`, because that is what
/// R4B search §3.1.1.4.7 compares: "the date 2013-01-10 specifies all the
/// time from 00:00 on 10-Jan 2013 to immediately before 00:00 on 11-Jan
/// 2013"; a Period is "explicit, though the upper or lower bound might not
/// actually be specified in resources"; and for a Timing "only the outer
/// limits matter". A missing lower bound "is 'less than' any actual date",
/// a missing upper bound "'greater than' any actual date" — those are
/// [beforeAnyDate] and [afterAnyDate].
class DateSearchParameters extends Table {
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

  /// Original date/dateTime/instant/Period/Timing value, as JSON text for the
  /// complex types, for anyone who needs the value as written.
  TextColumn get dateString => text()();

  /// The inclusive start of the value's range; [beforeAnyDate] for a Period
  /// with no start (schema 12; it was NULL, which made every prefix an OR
  /// the index could not seek).
  DateTimeColumn get dateValue => dateTime().nullable()();

  /// The EXCLUSIVE end of the value's range: the first instant after it. A
  /// date `2013-01-10` ends at `2013-01-11T00:00`; a dateTime to the second
  /// ends one second later. [afterAnyDate] for a Period with no end
  /// (ongoing), schema 12.
  DateTimeColumn get dateValueEnd => dateTime().nullable()();

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
