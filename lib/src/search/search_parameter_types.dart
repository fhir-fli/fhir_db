import 'package:drift/drift.dart';
import 'package:fhir_db/src/fhir_db.dart';

/// What a search parameter is, and which comparators it takes.
///
/// Read from the published SearchParameter definitions (a binding's
/// generated `searchParameterTypes`). A query cannot be parsed without it:
/// whether `gt` at the front of a value is a comparator or the first two
/// letters of a name is decided by the parameter's declared type, never by
/// the shape of the value.
class SearchParameterDefinition {
  /// Creates a definition.
  const SearchParameterDefinition(
    this.type,
    this.comparators, {
    this.components = const [],
    this.mime = false,
    this.targets = const [],
  });

  /// string | token | date | number | quantity | reference |
  /// uri | composite | special.
  final String type;

  /// The prefixes this parameter accepts, empty for the types
  /// that take none.
  final List<String> comparators;

  /// For a composite (R4B 3.1.1.4.17): its components, in the
  /// order the $-joined value gives them, each the type of the
  /// parameter it stands for and its expression relative to the
  /// composite's own element. Empty for every other type.
  final List<SearchComponent> components;

  /// True for a token parameter whose element is bound to the
  /// mimetypes value set (`Attachment.contentType`,
  /// `CapabilityStatement.format`, ...). `:below` on such a
  /// parameter is the mime-type search of search.html
  /// "Searching MIME Types"; on any other token it is code
  /// subsumption.
  final bool mime;

  /// For a reference parameter, the resource types it may
  /// point at (SearchParameter.target), sorted. Empty for
  /// every other type, and for the reference parameters
  /// whose definition declares none.
  final List<String> targets;
}

/// One component of a composite search parameter.
class SearchComponent {
  /// Creates a component.
  const SearchComponent(this.type, this.expression);

  /// The component parameter's type: token, quantity, ...
  final String type;

  /// The path from the composite's element to the value, as
  /// the definition writes it: `code`, `value.as(Quantity)`,
  /// `%resource.referenceSeq.chromosome`.
  final String expression;
}

/// Every search parameter of a FHIR version, by resource type then by
/// code, with the lookup the store makes.
class SearchDefinitions {
  /// Creates the catalogue over a binding's generated map.
  const SearchDefinitions(this.byType);

  /// Resource type → code → definition. `Resource` and `DomainResource`
  /// hold the parameters published against them (`_id`, `_lastUpdated`,
  /// `_tag`, `_profile`, `_security`, `_source`, `_text`, ...).
  final Map<String, Map<String, SearchParameterDefinition>> byType;

  /// The definition of [code] on [resourceType], the parameters published
  /// against `Resource` and `DomainResource` included, or null.
  ///
  /// A contained resource's rows are filed under `#Type` (search
  /// §3.1.1.5.5); its parameters are the type's own.
  SearchParameterDefinition? lookup(String resourceType, String code) {
    final type =
        resourceType.startsWith('#') ? resourceType.substring(1) : resourceType;
    // `_id`, `_lastUpdated`, `_tag`, `_profile`, `_security`, `_source`
    // and the rest of R4B 3.1.1.4.1 are published against Resource and
    // DomainResource, not against each type.
    return byType[type]?[code] ??
        byType['DomainResource']?[code] ??
        byType['Resource']?[code];
  }
}

/// The index rows one resource yields, one list per index table.
class SearchParameterLists {
  /// String rows.
  final stringParams = <StringSearchParametersCompanion>[];

  /// Token rows.
  final tokenParams = <TokenSearchParametersCompanion>[];

  /// Reference rows.
  final referenceParams = <ReferenceSearchParametersCompanion>[];

  /// Date rows.
  final dateParams = <DateSearchParametersCompanion>[];

  /// Number rows.
  final numberParams = <NumberSearchParametersCompanion>[];

  /// Quantity rows.
  final quantityParams = <QuantitySearchParametersCompanion>[];

  /// URI rows.
  final uriParams = <UriSearchParametersCompanion>[];

  /// Composite rows.
  final compositeParams = <CompositeSearchParametersCompanion>[];

  /// Special rows.
  final specialParams = <SpecialSearchParametersCompanion>[];

  /// Appends every list of [other] to this one.
  void addAll(SearchParameterLists other) {
    stringParams.addAll(other.stringParams);
    tokenParams.addAll(other.tokenParams);
    referenceParams.addAll(other.referenceParams);
    dateParams.addAll(other.dateParams);
    numberParams.addAll(other.numberParams);
    quantityParams.addAll(other.quantityParams);
    uriParams.addAll(other.uriParams);
    compositeParams.addAll(other.compositeParams);
    specialParams.addAll(other.specialParams);
  }
}

/// Drift's `Value.absent()` for a null [index], else the value.
Value<int> indexValue(int? index) =>
    index == null ? const Value.absent() : Value(index);
