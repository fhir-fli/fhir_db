import 'package:drift/drift.dart';
import 'package:fhir_db/src/fhir_db.dart';
import 'package:fhir_db/src/fhir_model.dart';
import 'package:fhir_db/src/search/fhir_date.dart';
import 'package:fhir_db/src/search/implicit_range.dart';
import 'package:fhir_db/src/search/normalize.dart';
import 'package:fhir_db/src/search/search_date_range.dart';
import 'package:fhir_db/src/search/search_parameter_types.dart';
import 'package:fhir_node/fhir_node.dart';

/// The FHIR type names a `Quantity` search parameter reads: Quantity and
/// its specialisations (R4B datatypes.html, data types summary, read
/// 2026-09-09: Quantity, SimpleQuantity, Age, Distance, Duration, Count,
/// MoneyQuantity), as `as(Quantity)` in FHIRPath takes them.
const quantityTypes = {
  'Quantity',
  'SimpleQuantity',
  'Age',
  'Distance',
  'Duration',
  'Count',
  'MoneyQuantity',
};

/// The primitive types a `uri` search parameter reads: `uri` and the
/// primitives specialised from it in the model (`url`, `canonical`, `oid`,
/// `uuid`, and `id`, which `fhir_r4` derives from uri).
const uriTypes = {'uri', 'url', 'canonical', 'oid', 'uuid', 'id'};

/// The primitive types a `number` search parameter reads (R4B search.html
/// 3.1.1.4.6: integer or decimal).
const numberTypes = {'integer', 'decimal', 'positiveInt', 'unsignedInt'};

/// The primitive types a `date` search parameter reads.
const dateTypes = {'date', 'dateTime', 'instant'};

/// Builds index rows from a value, by search-parameter type, through
/// [FhirNode] navigation only: no FHIR version is named here. A binding's
/// generated extractor walks its typed model and hands each element to the
/// method of the parameter's type; the composite builder and the sort keys
/// call the same methods, so every reader of a value agrees with the index.
///
/// These were extension methods on `fhir_r4`'s `FhirBase` switching on its
/// classes, kept three times over (fhirant REVIEW-2026-09-06 §4.6).
class SearchIndexer {
  /// Creates the indexer over [model], for the enum systems and the
  /// composite definitions.
  const SearchIndexer(this.model);

  /// The version's model.
  final FhirModel<FhirNode, Object> model;

  // ── token ────────────────────────────────────────────────────────────

  /// The token rows of [value] (R4B 3.1.1.4.10 and 3.1.1.9's cross-map:
  /// code, Coding, CodeableConcept, Identifier, boolean, string, id,
  /// ContactPoint, CodeableReference).
  List<TokenSearchParametersCompanion> tokenRows(
    FhirNode value,
    String resourceType,
    String id,
    int lastUpdated,
    String searchPath,
    int? paramIndex, {
    String searchName = '',
  }) {
    TokenSearchParametersCompanion row({
      required String code,
      String? system,
      String? display,
      Value<int>? index,
    }) =>
        TokenSearchParametersCompanion(
          resourceType: Value(resourceType),
          id: Value(id),
          lastUpdated: Value(lastUpdated),
          searchName: Value(searchName),
          paramIndex: index ?? indexValue(paramIndex),
          tokenSystem: system == null ? const Value.absent() : Value(system),
          tokenValue: Value(code),
          tokenDisplay: display == null
              ? const Value.absent()
              : Value(normalizeSearchString(display)),
        );

    switch (value.fhirType) {
      case 'code':
        final code = value.primitiveValue;
        if (code == null) return const [];
        return [
          row(
            code: code,
            system: model.enumSystem(value),
            display: model.enumDisplay(value),
          ),
        ];
      case 'Coding':
        final code = value.childValue('code');
        if (code == null) return const [];
        return [
          row(
            code: code,
            system: value.childValue('system'),
            display: value.childValue('display'),
          ),
        ];
      case 'CodeableConcept':
        final rows = <TokenSearchParametersCompanion>[];
        final codings = value.children('coding');
        for (var i = 0; i < codings.length; i++) {
          final code = codings[i].childValue('code');
          if (code == null) continue;
          rows.add(
            row(
              code: code,
              system: codings[i].childValue('system'),
              display: codings[i].childValue('display'),
              index: Value(paramIndex == null ? i : paramIndex * 100 + i),
            ),
          );
        }
        final text = value.childValue('text');
        if (text != null) {
          // R4B 3.1.1.4.4: `:text` "does a partial searches on the text
          // portion of a CodeableConcept or the display portion of a
          // Coding", "instead of the default search which uses codes". So
          // the text is a DISPLAY, and the row carries no code.
          final textIndex = codings.length;
          rows.add(
            row(
              code: '',
              display: text,
              index: Value(
                paramIndex == null ? textIndex : paramIndex * 100 + textIndex,
              ),
            ),
          );
        }
        return rows;
      case 'Identifier':
        final code = value.childValue('value');
        if (code == null) return const [];
        return [
          row(
            code: code,
            system: value.childValue('system'),
            // R4B 3.1.1.4.10: `:text` searches "Identifier.type.text".
            display: value.child('type')?.childValue('text'),
          ),
        ];
      case 'boolean' || 'string' || 'markdown' || 'id':
        final code = value.primitiveValue;
        return code == null ? const [] : [row(code: code)];
      // R4B 3.1.1.9's cross-map: token parameters also search ContactPoint
      // (`Patient.telecom`, `phone`, `email`), and the R4B
      // CodeableReference through its concept.
      case 'ContactPoint':
        // 3.1.1.4.10: "For token parameters on elements of type
        // ContactPoint ... only the [parameter]=[code] form is allowed",
        // so no system; the value is stored as written.
        final code = value.childValue('value');
        return code == null ? const [] : [row(code: code)];
      case 'CodeableReference':
        final concept = value.child('concept');
        if (concept == null) return const [];
        return tokenRows(
          concept,
          resourceType,
          id,
          lastUpdated,
          searchPath,
          paramIndex,
          searchName: searchName,
        );
      default:
        return const [];
    }
  }

  // ── string ───────────────────────────────────────────────────────────

  /// The string rows of [value] (string, HumanName, Address,
  /// ContactPoint). A name part yields one row per word as well as the
  /// whole, R4B 3.1.1.4.8: "servers should search the parts of a family
  /// name independently. E.g. searching either "Carreno" or "Quinones"
  /// should match a family name of "Carreno Quinones"". A word row carries
  /// the word as its search value and the WHOLE element as its exact
  /// value; whole values sit on the multiples of 100 of `param_index`.
  List<StringSearchParametersCompanion> stringRows(
    FhirNode value,
    String resourceType,
    String id,
    int lastUpdated,
    String searchPath,
    int? paramIndex, {
    String searchName = '',
  }) {
    final results = <StringSearchParametersCompanion>[];
    void addRows(String written, int index, {required bool nameParts}) {
      final normalized = normalizeSearchString(written);
      final words = nameParts
          ? normalized.split(' ').where((w) => w.isNotEmpty)
          : const <String>[];
      final searchValues = [normalized, ...words.skip(1)];
      for (final (w, searchValue) in searchValues.indexed) {
        results.add(
          StringSearchParametersCompanion(
            resourceType: Value(resourceType),
            id: Value(id),
            lastUpdated: Value(lastUpdated),
            searchName: Value(searchName),
            paramIndex: Value(index * 100 + w),
            stringValue: Value(searchValue),
            exactValue: Value(written),
          ),
        );
      }
    }

    // `family`, `given`, `phonetic`: a string that is a name part, told
    // apart by its path. Structural, so case-sensitive on purpose.
    final isNamePart = RegExp(r'\.name\.(family|given|prefix|suffix|text)$')
        .hasMatch(searchPath);

    switch (value.fhirType) {
      // `code` is a string in the model (`FhirCode extends FhirString`), as
      // it was under the typed switch.
      case 'string' || 'markdown' || 'code':
        final written = value.primitiveValue;
        if (written != null) {
          addRows(written, paramIndex ?? 0, nameParts: isNamePart);
        }
        return results;
      case 'HumanName':
        final parts = <String?>[
          value.childValue('family'),
          for (final n in value.children('given')) n.primitiveValue,
          for (final n in value.children('prefix')) n.primitiveValue,
          for (final n in value.children('suffix')) n.primitiveValue,
          value.childValue('text'),
        ].whereType<String>().toList();
        for (var i = 0; i < parts.length; i++) {
          addRows(parts[i], (paramIndex ?? 0) * 100 + i, nameParts: true);
        }
        return results;
      case 'Address':
        final parts = <String?>[
          for (final n in value.children('line')) n.primitiveValue,
          value.childValue('city'),
          value.childValue('district'),
          value.childValue('state'),
          value.childValue('postalCode'),
          value.childValue('country'),
          value.childValue('text'),
        ].whereType<String>().toList();
        for (var i = 0; i < parts.length; i++) {
          results.add(
            StringSearchParametersCompanion(
              resourceType: Value(resourceType),
              id: Value(id),
              lastUpdated: Value(lastUpdated),
              searchName: Value(searchName),
              paramIndex: Value(((paramIndex ?? 0) * 100 + i) * 100),
              stringValue: Value(normalizeSearchString(parts[i])),
              exactValue: Value(parts[i]),
            ),
          );
        }
        return results;
      case 'ContactPoint':
        final written = value.childValue('value');
        if (written != null) {
          results.add(
            StringSearchParametersCompanion(
              resourceType: Value(resourceType),
              id: Value(id),
              lastUpdated: Value(lastUpdated),
              searchName: Value(searchName),
              paramIndex: Value((paramIndex ?? 0) * 100),
              stringValue: Value(normalizeSearchString(written)),
              exactValue: Value(written),
            ),
          );
        }
        return results;
      default:
        return results;
    }
  }

  // ── reference ────────────────────────────────────────────────────────

  /// The reference rows of [value]: Reference (literal or identifier),
  /// and, R4B 3.1.1.9's cross-map, canonical, uri (and the model's
  /// specialisations of it) and the R4B CodeableReference through its
  /// reference.
  List<ReferenceSearchParametersCompanion> referenceRows(
    FhirNode value,
    String resourceType,
    String id,
    int lastUpdated,
    String searchPath,
    int? paramIndex, {
    String searchName = '',
  }) {
    ReferenceSearchParametersCompanion row(
      String? written, {
      String? identifierSystem,
      String? identifierValue,
    }) {
      final parts = parseReference(written);
      Value<String?> v(String? s) =>
          s == null ? const Value.absent() : Value(s);
      return ReferenceSearchParametersCompanion(
        resourceType: Value(resourceType),
        id: Value(id),
        lastUpdated: Value(lastUpdated),
        searchName: Value(searchName),
        paramIndex: indexValue(paramIndex),
        referenceValue: v(written),
        referenceResourceType: v(parts.resourceType),
        referenceIdPart: v(parts.id),
        referenceVersion: v(parts.version),
        referenceBaseUrl: v(parts.baseUrl),
        identifierSystem: v(identifierSystem),
        identifierValue: v(identifierValue),
      );
    }

    switch (value.fhirType) {
      case 'Reference':
        final written = value.childValue('reference');
        final identifier = value.child('identifier');
        final identifierValue = identifier?.childValue('value');
        // A display-only reference (no reference string and no identifier)
        // names nothing the index can find.
        if (written == null && identifierValue == null) return const [];
        return [
          row(
            written,
            identifierSystem: identifier?.childValue('system'),
            identifierValue: identifierValue,
          ),
        ];
      case 'CodeableReference':
        final reference = value.child('reference');
        if (reference == null) return const [];
        return referenceRows(
          reference,
          resourceType,
          id,
          lastUpdated,
          searchPath,
          paramIndex,
          searchName: searchName,
        );
      default:
        if (!uriTypes.contains(value.fhirType)) return const [];
        final written = value.primitiveValue;
        return written == null ? const [] : [row(written)];
    }
  }

  // ── date ─────────────────────────────────────────────────────────────

  /// The date rows of [value]: date, dateTime, instant, Period, Timing.
  /// Every row is a RANGE `[low, high)` (R4B search §3.1.1.4.7), an open
  /// bound stored as [beforeAnyDate] or [afterAnyDate].
  List<DateSearchParametersCompanion> dateRows(
    FhirNode value,
    String resourceType,
    String id,
    int lastUpdated,
    String searchPath,
    int? paramIndex, {
    String searchName = '',
  }) {
    DateSearchParametersCompanion row(
      String written,
      DateTime? low,
      DateTime? high,
    ) =>
        DateSearchParametersCompanion(
          resourceType: Value(resourceType),
          id: Value(id),
          lastUpdated: Value(lastUpdated),
          searchName: Value(searchName),
          paramIndex: indexValue(paramIndex),
          dateString: Value(written),
          dateValue: Value(low ?? beforeAnyDate),
          dateValueEnd: Value(high ?? afterAnyDate),
        );

    final type = value.fhirType;
    if (dateTypes.contains(type)) {
      final written = value.primitiveValue;
      final range = written == null ? null : dateTimeRange(written);
      if (written == null || range == null) return const [];
      return [row(written, range.low, range.high)];
    }
    switch (type) {
      case 'Period':
        // §3.1.1.4.7: "Explicit, though the upper or lower bound might not
        // actually be specified in resources." Period.end is inclusive and
        // carries its own precision, so the range runs to the END of the
        // end value's own range. A missing start is before any date and a
        // missing end is ongoing.
        final start = value.childValue('start');
        final end = value.childValue('end');
        final low = start == null ? null : dateTimeRange(start);
        final high = end == null ? null : dateTimeRange(end);
        if (low == null && high == null) return const [];
        return [row(_json(value), low?.low, high?.high)];
      case 'Timing':
        // §3.1.1.4.7: "the specified scheduling details are ignored and
        // only the outer limits matter." The outer limits are the earliest
        // and latest of the events and the bounds period; a bounds
        // Duration or Range has no anchor in time and contributes nothing.
        DateTime? low;
        DateTime? high;
        var openStart = false;
        var openEnd = false;
        void widen(DateTime? l, DateTime? h) {
          if (l == null) {
            openStart = true;
          } else if (low == null || l.isBefore(low!)) {
            low = l;
          }
          if (h == null) {
            openEnd = true;
          } else if (high == null || h.isAfter(high!)) {
            high = h;
          }
        }

        for (final event in value.children('event')) {
          final written = event.primitiveValue;
          final range = written == null ? null : dateTimeRange(written);
          if (range != null) widen(range.low, range.high);
        }
        final bounds = value.child('repeat')?.child('boundsPeriod');
        final boundsStart = bounds?.childValue('start');
        final boundsEnd = bounds?.childValue('end');
        if (bounds != null && (boundsStart != null || boundsEnd != null)) {
          widen(
            boundsStart == null ? null : dateTimeRange(boundsStart)?.low,
            boundsEnd == null ? null : dateTimeRange(boundsEnd)?.high,
          );
        }
        if (low == null && high == null && !openStart && !openEnd) {
          return const [];
        }
        return [
          row(_json(value), openStart ? null : low, openEnd ? null : high),
        ];
      default:
        return const [];
    }
  }

  // ── quantity ─────────────────────────────────────────────────────────

  /// The quantity rows of [value]: Quantity and its specialisations,
  /// Money, Range (R4B 3.1.1.9's cross-map). An open bound is stored as
  /// infinity, never NULL, so every prefix is one index range.
  List<QuantitySearchParametersCompanion> quantityRows(
    FhirNode value,
    String resourceType,
    String id,
    int lastUpdated,
    String searchPath,
    int? paramIndex, {
    String searchName = '',
  }) {
    QuantitySearchParametersCompanion row({
      required double? number,
      required double? low,
      required double? high,
      String? unit,
      String? system,
      String? code,
    }) =>
        QuantitySearchParametersCompanion(
          resourceType: Value(resourceType),
          id: Value(id),
          lastUpdated: Value(lastUpdated),
          searchName: Value(searchName),
          paramIndex: indexValue(paramIndex),
          quantityValue: Value(number),
          quantityLow: Value(low ?? double.negativeInfinity),
          quantityHigh: Value(high ?? double.infinity),
          quantityUnit: Value(unit),
          quantitySystem: Value(system),
          quantityCode: Value(code),
        );

    final type = value.fhirType;
    if (quantityTypes.contains(type)) {
      final number = value.child('value');
      final range = number == null ? null : numberRange(number);
      if (range == null) return const [];
      return [
        row(
          number: range.value,
          low: range.low,
          high: range.high,
          unit: value.childValue('unit'),
          system: value.childValue('system'),
          code: value.childValue('code'),
        ),
      ];
    }
    switch (type) {
      case 'Money':
        final number = value.child('value');
        final range = number == null ? null : numberRange(number);
        if (range == null) return const [];
        // The currency is the code, in the ISO 4217 system Money binds to.
        return [
          row(
            number: range.value,
            low: range.low,
            high: range.high,
            system: 'urn:iso:std:iso:4217',
            code: value.childValue('currency'),
          ),
        ];
      case 'Range':
        // 3.1.1.4.5: a Range is explicitly a range, "the upper or lower
        // bound might not actually be specified"; a missing one is open.
        final lowQ = value.child('low');
        final highQ = value.child('high');
        final lowN = lowQ?.child('value');
        final highN = highQ?.child('value');
        final lowR = lowN == null ? null : numberRange(lowN);
        final highR = highN == null ? null : numberRange(highN);
        if (lowR == null && highR == null) return const [];
        final unitOf = lowQ ?? highQ;
        return [
          row(
            number: null,
            low: lowR?.low,
            high: highR?.high,
            unit: unitOf?.childValue('unit'),
            system: unitOf?.childValue('system'),
            code: unitOf?.childValue('code'),
          ),
        ];
      default:
        return const [];
    }
  }

  // ── number ───────────────────────────────────────────────────────────

  /// The number rows of [value] (integer, decimal, positiveInt,
  /// unsignedInt).
  List<NumberSearchParametersCompanion> numberRows(
    FhirNode value,
    String resourceType,
    String id,
    int lastUpdated,
    String searchPath,
    int? paramIndex, {
    String searchName = '',
  }) {
    if (!numberTypes.contains(value.fhirType)) return const [];
    final range = numberRange(value);
    if (range == null) return const [];
    return [
      NumberSearchParametersCompanion(
        resourceType: Value(resourceType),
        id: Value(id),
        lastUpdated: Value(lastUpdated),
        searchName: Value(searchName),
        paramIndex: indexValue(paramIndex),
        numberValue: Value(range.value),
        numberLow: Value(range.low),
        numberHigh: Value(range.high),
      ),
    ];
  }

  // ── uri ──────────────────────────────────────────────────────────────

  /// The uri rows of [value], the value as written: R4B 3.1.1.4.9,
  /// "matches are precise (e.g. case, accent, and escape) sensitive, and
  /// the entire URI must match."
  List<UriSearchParametersCompanion> uriRows(
    FhirNode value,
    String resourceType,
    String id,
    int lastUpdated,
    String searchPath,
    int? paramIndex, {
    String searchName = '',
  }) {
    if (!uriTypes.contains(value.fhirType)) return const [];
    final written = value.primitiveValue;
    if (written == null) return const [];
    return [
      UriSearchParametersCompanion(
        resourceType: Value(resourceType),
        id: Value(id),
        lastUpdated: Value(lastUpdated),
        searchName: Value(searchName),
        paramIndex: indexValue(paramIndex),
        uriValue: Value(written),
      ),
    ];
  }

  // ── special ──────────────────────────────────────────────────────────

  /// The special rows of [value]. R4B 3.1.1.4.21 lists two special
  /// parameters, `_filter` (the server's) and `near` on Location; `near`
  /// reads Location.position, kept as numbers so the distance test can run
  /// in SQL.
  List<SpecialSearchParametersCompanion> specialRows(
    FhirNode value,
    String resourceType,
    String id,
    int lastUpdated,
    String searchPath,
    int? paramIndex, {
    String searchName = '',
  }) {
    if (value.fhirType != 'LocationPosition') return const [];
    final latitude = double.tryParse(value.childValue('latitude') ?? '');
    final longitude = double.tryParse(value.childValue('longitude') ?? '');
    if (latitude == null || longitude == null) return const [];
    return [
      SpecialSearchParametersCompanion(
        resourceType: Value(resourceType),
        id: Value(id),
        lastUpdated: Value(lastUpdated),
        searchName: Value(searchName),
        paramIndex: indexValue(paramIndex),
        specialValue: Value('$latitude|$longitude'),
        latitude: Value(latitude),
        longitude: Value(longitude),
      ),
    ];
  }

  // ── composite ────────────────────────────────────────────────────────

  /// The composite rows for [value], one per combination of its
  /// components' values. [searchName] names the composite, whose
  /// components come from the definitions; [root] is the resource, for a
  /// component written from `%resource`. Each component's value goes
  /// through the builder of its own type, so a token component reads a
  /// CodeableConcept exactly as the token index would.
  List<CompositeSearchParametersCompanion> compositeRows(
    FhirNode value,
    String resourceType,
    String id,
    int lastUpdated,
    String searchPath,
    int? paramIndex, {
    String searchName = '',
    FhirNode? root,
  }) {
    final definition = model.searchParameters.lookup(resourceType, searchName);
    if (definition == null || definition.components.isEmpty) return const [];

    final perComponent = <List<CompositeSlot>>[];
    for (final component in definition.components) {
      final values =
          evaluateComponentPath(value, component.expression, root: root);
      final slots = <CompositeSlot>[];
      for (final v in values) {
        slots.addAll(
          _slotsFor(
            v,
            component.type,
            resourceType,
            id,
            lastUpdated,
            searchPath,
          ),
        );
      }
      // An element missing one component cannot match a composite value.
      if (slots.isEmpty) return const [];
      perComponent.add(slots);
    }

    var combinations = <List<CompositeSlot>>[[]];
    for (final slots in perComponent) {
      combinations = [
        for (final prefix in combinations)
          for (final slot in slots) [...prefix, slot],
      ];
    }
    final rows = <CompositeSearchParametersCompanion>[];
    for (final (n, combination) in combinations.indexed) {
      final c1 = combination[0];
      final c2 = combination[1];
      final c3 = combination.length > 2 ? combination[2] : null;
      rows.add(
        CompositeSearchParametersCompanion(
          resourceType: Value(resourceType),
          id: Value(id),
          lastUpdated: Value(lastUpdated),
          searchName: Value(searchName),
          paramIndex: Value((paramIndex ?? 0) * 1000 + n),
          c1Type: Value(c1.type),
          c1System: Value(c1.system),
          c1Value: Value(c1.value),
          c1Raw: Value(c1.raw),
          c1Low: Value(c1.low),
          c1High: Value(c1.high),
          c2Type: Value(c2.type),
          c2System: Value(c2.system),
          c2Value: Value(c2.value),
          c2Raw: Value(c2.raw),
          c2Low: Value(c2.low),
          c2High: Value(c2.high),
          c3Type: Value(c3?.type),
          c3System: Value(c3?.system),
          c3Value: Value(c3?.value),
          c3Raw: Value(c3?.raw),
          c3Low: Value(c3?.low),
          c3High: Value(c3?.high),
        ),
      );
    }
    return rows;
  }

  List<CompositeSlot> _slotsFor(
    FhirNode value,
    String type,
    String resourceType,
    String id,
    int lastUpdated,
    String searchPath,
  ) {
    switch (type) {
      case 'token':
        return [
          for (final row
              in tokenRows(value, resourceType, id, lastUpdated, searchPath, 0))
            // A text-only row (CodeableConcept.text as display) has no
            // code and is not a token value.
            if (row.tokenValue.value.isNotEmpty)
              CompositeSlot(
                type: type,
                system: row.tokenSystem.value,
                value: row.tokenValue.value,
              ),
        ];
      case 'quantity':
        return [
          for (final row in quantityRows(
            value,
            resourceType,
            id,
            lastUpdated,
            searchPath,
            0,
          ))
            CompositeSlot(
              type: type,
              system: row.quantitySystem.value,
              value: row.quantityCode.value,
              raw: row.quantityUnit.value,
              low: row.quantityLow.value,
              high: row.quantityHigh.value,
            ),
        ];
      case 'number':
        return [
          for (final row in numberRows(
            value,
            resourceType,
            id,
            lastUpdated,
            searchPath,
            0,
          ))
            CompositeSlot(
              type: type,
              low: row.numberLow.value,
              high: row.numberHigh.value,
            ),
        ];
      case 'date':
        return [
          for (final row
              in dateRows(value, resourceType, id, lastUpdated, searchPath, 0))
            CompositeSlot(
              type: type,
              low: row.dateValue.value == null
                  ? null
                  : row.dateValue.value!.millisecondsSinceEpoch / 1000,
              high: row.dateValueEnd.value == null
                  ? null
                  : row.dateValueEnd.value!.millisecondsSinceEpoch / 1000,
            ),
        ];
      case 'string':
        return [
          for (final row in stringRows(
            value,
            resourceType,
            id,
            lastUpdated,
            searchPath,
            0,
          ))
            CompositeSlot(
              type: type,
              value: row.stringValue.value,
              raw: row.exactValue.value,
            ),
        ];
      case 'reference':
        return [
          for (final row in referenceRows(
            value,
            resourceType,
            id,
            lastUpdated,
            searchPath,
            0,
          ))
            CompositeSlot(
              type: type,
              system: row.referenceResourceType.value,
              value: row.referenceIdPart.value,
              raw: row.referenceValue.value,
            ),
        ];
      case 'uri':
        return [
          for (final row
              in uriRows(value, resourceType, id, lastUpdated, searchPath, 0))
            CompositeSlot(type: type, value: row.uriValue.value),
        ];
      default:
        return const [];
    }
  }

  /// The JSON text of a complex value, for a row that keeps the value as
  /// written (a Period or Timing's `date_string`).
  String _json(FhirNode value) => model.jsonText(value);
}

/// The range `[low, high)` a stored number covers, R4B 3.1.1.4.5–6, and
/// the number itself; null when [number] carries no numeric value.
///
/// A decimal covers half a unit of its last significant digit either side,
/// read from the value as written ([implicitRange]); "when a number search
/// is used against a resource element that stores a simple integer … the
/// significance issues cancel out and searching is based on exact matches",
/// so an integer is a point, `low == high`.
({double value, double low, double high})? numberRange(FhirNode number) {
  final written = number.primitiveValue;
  final value = written == null ? null : double.tryParse(written);
  if (value == null) return null;
  if (number.fhirType != 'decimal') {
    return (value: value, low: value, high: value);
  }
  final range = implicitRange(written!);
  return range == null
      ? (value: value, low: value, high: value)
      : (value: value, low: range.low, high: range.high);
}

/// One component's value, reduced to the slot columns.
class CompositeSlot {
  /// Creates a slot value.
  const CompositeSlot({
    required this.type,
    this.system,
    this.value,
    this.raw,
    this.low,
    this.high,
  });

  /// token | quantity | number | date | string | reference | uri.
  final String type;

  /// See [CompositeSearchParameters.c1System].
  final String? system;

  /// See [CompositeSearchParameters.c1Value].
  final String? value;

  /// See [CompositeSearchParameters.c1Raw].
  final String? raw;

  /// See [CompositeSearchParameters.c1Low].
  final double? low;

  /// See [CompositeSearchParameters.c1High].
  final double? high;
}

/// Evaluates the small FHIRPath subset a composite's component expressions
/// use — `code`, `value.as(Quantity)`, `(value as CodeableConcept) | (value
/// as boolean)`, `%resource.referenceSeq.chromosome`, `item.answer.value
/// .ofType(Reference)` — against an element, through [FhirNode] child
/// access. Public for its tests.
List<FhirNode> evaluateComponentPath(
  FhirNode element,
  String expression, {
  FhirNode? root,
}) {
  final results = <FhirNode>[];
  for (final member in _splitUnion(expression)) {
    var path = member.trim();
    while (path.startsWith('(') && path.endsWith(')')) {
      path = path.substring(1, path.length - 1).trim();
    }
    // `x as T` → `x.as(T)`.
    final infix = RegExp(r'^(.*?)\s+as\s+([A-Za-z]+)$').firstMatch(path);
    if (infix != null) {
      path = '${infix.group(1)}.as(${infix.group(2)})';
    }
    var nodes = <FhirNode>[element];
    if (path.startsWith('%resource')) {
      nodes = root == null ? const [] : [root];
      path = path.substring('%resource'.length);
      if (path.startsWith('.')) path = path.substring(1);
    }
    for (final segment in path.split('.').where((s) => s.isNotEmpty)) {
      final cast = RegExp(r'^(?:as|ofType)\((\w+)\)$').firstMatch(segment);
      if (cast != null) {
        final wanted = cast.group(1)!;
        nodes = nodes.where((n) => _isType(n, wanted)).toList();
        continue;
      }
      nodes = [
        for (final node in nodes) ...node.getChildrenByName(segment),
      ];
    }
    results.addAll(nodes);
  }
  return results;
}

/// Splits on `|` at parenthesis depth zero.
List<String> _splitUnion(String expression) {
  final members = <String>[];
  var depth = 0;
  var start = 0;
  for (var i = 0; i < expression.length; i++) {
    final c = expression[i];
    if (c == '(') depth++;
    if (c == ')') depth--;
    if (c == '|' && depth == 0) {
      members.add(expression.substring(start, i));
      start = i + 1;
    }
  }
  members.add(expression.substring(start));
  return members;
}

/// Whether [node] is of FHIR type [wanted], case-insensitively so that
/// `DateTime` in a definition matches the `dateTime` type name, and with
/// Quantity's specialisations counting as a Quantity, as `as(Quantity)`
/// does in FHIRPath.
bool _isType(FhirNode node, String wanted) {
  if (node.fhirType.toLowerCase() == wanted.toLowerCase()) return true;
  if (wanted == 'Quantity' && quantityTypes.contains(node.fhirType)) {
    return true;
  }
  return false;
}

/// The parts of a literal reference.
class ReferenceComponents {
  /// Creates the parts.
  const ReferenceComponents({
    this.resourceType,
    this.id,
    this.version,
    this.baseUrl,
  });

  /// The target resource type (e.g. 'Patient')
  final String? resourceType;

  /// The target resource id
  final String? id;

  /// The version from a versioned reference
  final String? version;

  /// The base URL for absolute references
  final String? baseUrl;
}

/// Parses a literal reference into base URL, type, id and version.
///
/// R4B references.html "Literal References" (read 2026-09-07) gives the
/// shape as a regex: an optional `(http|https)://` base of one or more
/// path segments, then `[type]/[id]`, then optionally
/// `(\/_history\/[A-Za-z0-9\-\.]{1,64})?`. So the version suffix comes off
/// first, whatever the rest is, and the base is everything before the LAST
/// `/[type]/[id]`. An absolute versioned reference used to be split on its
/// last two segments and indexed as type `_history`, id `[vid]`, and a
/// base path that happened to contain the type name was cut at the first
/// occurrence (fhirant REVIEW-2026-09-06 finding 18).
ReferenceComponents parseReference(String? referenceString) {
  if (referenceString == null || referenceString.isEmpty) {
    return const ReferenceComponents();
  }

  String? version;
  var rest = referenceString;
  const historyMarker = '/_history/';
  final h = rest.indexOf(historyMarker);
  if (h >= 0) {
    final v = rest.substring(h + historyMarker.length);
    version = v.isEmpty ? null : v;
    rest = rest.substring(0, h);
  }

  // Absolute URLs: "http://example.org/fhir/Patient/123"
  if (rest.startsWith('http://') || rest.startsWith('https://')) {
    final uri = Uri.tryParse(rest);
    if (uri == null) return const ReferenceComponents();
    final pathSegments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (pathSegments.length >= 2) {
      final type = pathSegments[pathSegments.length - 2];
      final id = pathSegments[pathSegments.length - 1];
      final cut = uri.path.lastIndexOf('/$type/$id');
      return ReferenceComponents(
        baseUrl: '${uri.scheme}://${uri.authority}'
            '${uri.path.substring(0, cut + 1)}',
        resourceType: type,
        id: id,
        version: version,
      );
    }
    return const ReferenceComponents();
  }

  // Relative references: "Patient/123"
  final parts = rest.split('/');
  if (parts.length == 2) {
    return ReferenceComponents(
      resourceType: parts[0],
      id: parts[1],
      version: version,
    );
  }

  // ID-only references
  if (!rest.contains('/')) {
    return ReferenceComponents(id: rest, version: version);
  }

  return const ReferenceComponents();
}
