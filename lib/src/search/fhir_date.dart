/// A FHIR date, dateTime or instant, parsed for what the index needs: the
/// instant it starts at and the unit of its precision.
///
/// R4B datatypes.html (read 2026-09-08): a `date` is `YYYY`, `YYYY-MM` or
/// `YYYY-MM-DD`; a `dateTime` adds `Thh:mm:ss+zz:zz`, "If hours and minutes
/// are specified, a time zone SHALL be populated"; an `instant` is always
/// to the second at least with a zone. The grammar below is the one the
/// search page also gives for a date search value (R4B search.html
/// 3.1.1.4.7): `yyyy-mm-ddThh:mm:ss[Z|(+|-)hh:mm]`, populated from the left.
///
/// Structural, so case-sensitive on purpose: `T` and `Z` are the grammar's
/// own letters.
final RegExp _fhirDate = RegExp(
  r'^(\d{4})(?:-(\d{2})(?:-(\d{2})(?:T(\d{2}):(\d{2})(?::(\d{2})(?:\.(\d+))?)?'
  r'(Z|[+-]\d{2}:\d{2})?)?)?)?$',
);

/// The precision a written date carries.
enum DatePrecision {
  /// `2013`
  years,

  /// `2013-01`
  months,

  /// `2013-01-14`
  days,

  /// `2013-01-14T10:00`
  minutes,

  /// `2013-01-14T10:00:00` (a fraction is below what the index stores)
  seconds,
}

/// A parsed FHIR date-like value.
class FhirDateValue {
  const FhirDateValue._(this.written, this.low, this.precision);

  /// Parses [written], or returns null when it is not a FHIR date, dateTime
  /// or instant.
  ///
  /// The instant honours the value's zone: `Z` or an offset is read in UTC
  /// (a `+02:00` wall clock is two hours ahead of UTC); a value with no
  /// zone is in the local zone, which is what R4B search.html 3.1.1.4.7
  /// asks: "Where both search parameters and resource element date times
  /// do not have time zones, the servers local time zone should be
  /// assumed".
  static FhirDateValue? tryParse(String written) {
    final m = _fhirDate.firstMatch(written.trim());
    if (m == null) return null;
    final year = int.parse(m.group(1)!);
    final month = m.group(2) == null ? null : int.parse(m.group(2)!);
    final day = m.group(3) == null ? null : int.parse(m.group(3)!);
    final hour = m.group(4) == null ? null : int.parse(m.group(4)!);
    final minute = m.group(5) == null ? null : int.parse(m.group(5)!);
    final second = m.group(6) == null ? null : int.parse(m.group(6)!);
    final fraction = m.group(7);
    final zone = m.group(8);
    if ((month != null && (month < 1 || month > 12)) ||
        (day != null && (day < 1 || day > 31)) ||
        (hour != null && hour > 23) ||
        (minute != null && minute > 59) ||
        (second != null && second > 59)) {
      return null;
    }
    final millis = fraction == null
        ? 0
        : int.parse(fraction.padRight(3, '0').substring(0, 3));
    final precision = hour == null
        ? day == null
            ? month == null
                ? DatePrecision.years
                : DatePrecision.months
            : DatePrecision.days
        : second == null
            ? DatePrecision.minutes
            : DatePrecision.seconds;
    DateTime low;
    if (zone != null) {
      final wallClock = DateTime.utc(
        year,
        month ?? 1,
        day ?? 1,
        hour ?? 0,
        minute ?? 0,
        second ?? 0,
        millis,
      );
      if (zone == 'Z') {
        low = wallClock;
      } else {
        final sign = zone[0] == '-' ? -1 : 1;
        final offset = Duration(
          hours: int.parse(zone.substring(1, 3)),
          minutes: int.parse(zone.substring(4, 6)),
        );
        low = wallClock.subtract(offset * sign);
      }
    } else {
      low = DateTime(
        year,
        month ?? 1,
        day ?? 1,
        hour ?? 0,
        minute ?? 0,
        second ?? 0,
        millis,
      );
    }
    return FhirDateValue._(written, low, precision);
  }

  /// The value as written.
  final String written;

  /// The instant the value starts at.
  final DateTime low;

  /// The precision the value was written to.
  final DatePrecision precision;

  /// The first instant after the value's own range (R4B search.html
  /// 3.1.1.4.7: "the date 2013-01-10 specifies all the time from 00:00 on
  /// 10-Jan 2013 to immediately before 00:00 on 11-Jan 2013"), computed in
  /// the same zone as [low] so a year or a month is a calendar one.
  /// Sub-second precision is below what the column stores, so an instant
  /// with milliseconds covers its second.
  DateTime get high {
    final t = low;
    final make = t.isUtc ? DateTime.utc : DateTime.new;
    return switch (precision) {
      DatePrecision.years => make(t.year + 1),
      DatePrecision.months => make(t.year, t.month + 1),
      DatePrecision.days => make(t.year, t.month, t.day + 1),
      DatePrecision.minutes => t.add(const Duration(minutes: 1)),
      DatePrecision.seconds => t.add(const Duration(seconds: 1)),
    };
  }
}

/// The half-open range `[low, high)` a date-like value covers, per R4B
/// search §3.1.1.4.7, or null when [written] is not a FHIR date.
({DateTime low, DateTime high})? dateTimeRange(String written) {
  final parsed = FhirDateValue.tryParse(written);
  if (parsed == null) return null;
  return (low: parsed.low, high: parsed.high);
}
