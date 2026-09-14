import 'package:fhir_db/src/fhir_model.dart';
import 'package:fhir_db/src/search/search_indexer.dart';
import 'package:fhir_db/src/search/search_parameter_types.dart';
import 'package:fhir_node/fhir_node.dart';
import 'package:fhir_path/fhir_path.dart';

/// A `SearchParameter` resource the store cannot index, refused at save.
class InvalidSearchParameter implements Exception {
  /// Creates the error.
  InvalidSearchParameter(this.message);

  /// Why the definition was refused.
  final String message;

  @override
  String toString() => 'InvalidSearchParameter: $message';
}

/// The `SearchParameter.type` values an uploaded definition may carry. A
/// composite names other parameters' components and is not evaluated from
/// one expression, so it is not accepted.
const Set<String> customSearchParameterTypes = {
  'string',
  'token',
  'reference',
  'date',
  'quantity',
  'number',
  'uri',
  'special',
};

/// The prefixes a date, number or quantity parameter accepts when its
/// definition names none (R4B 3.1.1.4.5 lists nine).
const List<String> _orderedComparators = [
  'eq',
  'ne',
  'gt',
  'lt',
  'ge',
  'le',
  'sa',
  'eb',
  'ap',
];

/// One uploaded `SearchParameter`, parsed once: what it is called, which
/// table its rows go to, which bases it is written on, and its FHIRPath
/// expression ready to evaluate.
class CustomSearchParameter {
  /// Creates the parameter.
  CustomSearchParameter({
    required this.code,
    required this.type,
    required this.bases,
    required this.targets,
    required this.expression,
    required this.parsed,
    required this.comparators,
    this.url,
    this.id,
  });

  /// `SearchParameter.code`, the name used in a query.
  final String code;

  /// `SearchParameter.type`: the index table.
  final String type;

  /// `SearchParameter.base`: the resource types it applies to. `Resource`
  /// and `DomainResource` cover every type.
  final Set<String> bases;

  /// `SearchParameter.target` of a reference parameter.
  final List<String> targets;

  /// `SearchParameter.expression` as written.
  final String expression;

  /// [expression] parsed.
  final ExpressionNode parsed;

  /// The prefixes a query may use.
  final List<String> comparators;

  /// `SearchParameter.url`.
  final String? url;

  /// The resource id it was stored under.
  final String? id;

  /// Whether a resource of [resourceType] is indexed by this parameter.
  bool appliesTo(String resourceType) =>
      bases.contains(resourceType) ||
      bases.contains('Resource') ||
      bases.contains('DomainResource');

  /// The definition the query side reads: type, prefixes, targets.
  SearchParameterDefinition get definition =>
      SearchParameterDefinition(type, comparators, targets: targets);
}

/// The uploaded search parameters of one store: read from the stored
/// `SearchParameter` resources, evaluated with the FHIRPath engine on every
/// save and on a rebuild, and consulted by the query side for the table a
/// name routes to. What HAPI/Smile CDR and the Azure FHIR service do for
/// every parameter, done here for the ones the specification does not
/// define (the generated extractor keeps those).
class CustomSearchParameters {
  /// Creates an empty registry over [engine] and [indexer].
  CustomSearchParameters(
    this.engine, {
    required this.indexer,
    required this.knownTypes,
    required this.builtIn,
  });

  /// The engine the expressions are parsed and evaluated with.
  final FHIRPathEngine engine;

  /// The row builders of this store's model.
  final SearchIndexer indexer;

  /// The resource type names of the model, for checking `base`.
  final Set<String> knownTypes;

  /// The specification's own definitions, which an upload may not shadow.
  final SearchDefinitions builtIn;

  final Map<String, Map<String, CustomSearchParameter>> _byBase = {};

  /// Stored definitions that could not be registered when the registry was
  /// loaded (id, reason): saved before validation existed, or by a model
  /// without an engine. Nothing is indexed by them.
  final List<(String, String)> rejected = [];

  /// Every registered parameter.
  Iterable<CustomSearchParameter> get all =>
      _byBase.values.expand((m) => m.values).toSet();

  /// The registered parameters a resource of [resourceType] is indexed by.
  List<CustomSearchParameter> forType(String resourceType) => [
        ...?_byBase[resourceType]?.values,
        ...?_byBase['DomainResource']?.values,
        ...?_byBase['Resource']?.values,
      ];

  /// The definition of [code] on [resourceType], or null when no upload
  /// defines it.
  SearchParameterDefinition? lookup(String resourceType, String code) {
    final type =
        resourceType.startsWith('#') ? resourceType.substring(1) : resourceType;
    return (_byBase[type]?[code] ??
            _byBase['DomainResource']?[code] ??
            _byBase['Resource']?[code])
        ?.definition;
  }

  /// Parses and checks [definition], a `SearchParameter` resource, without
  /// registering it. Throws [InvalidSearchParameter] when the store could
  /// not index by it. Returns null for a definition whose `status` is not
  /// `active`: stored, but not indexed (Smile CDR: "assuming the new
  /// parameter is valid and active, all resource changes (creates, updates,
  /// etc.) will be indexed by the new search parameter").
  CustomSearchParameter? parse(FhirNode definition) {
    final code = definition.childValue('code');
    final type = definition.childValue('type');
    final expression = definition.childValue('expression');
    final bases = definition
        .children('base')
        .map((b) => b.primitiveValue)
        .whereType<String>()
        .toSet();
    if (code == null || code.isEmpty) {
      throw InvalidSearchParameter('SearchParameter.code is required');
    }
    if (bases.isEmpty) {
      throw InvalidSearchParameter('SearchParameter.base is required');
    }
    if (type == null || !customSearchParameterTypes.contains(type)) {
      throw InvalidSearchParameter(
        'SearchParameter.type $type is not one the store indexes '
        '(${customSearchParameterTypes.join(', ')})',
      );
    }
    if (expression == null || expression.trim().isEmpty) {
      throw InvalidSearchParameter(
        'SearchParameter.expression is required: the store indexes by '
        'evaluating it',
      );
    }
    for (final base in bases) {
      if (base != 'Resource' &&
          base != 'DomainResource' &&
          !knownTypes.contains(base)) {
        throw InvalidSearchParameter(
          'SearchParameter.base $base is not a resource type of this '
          'FHIR version',
        );
      }
      if (builtIn.lookup(base, code) != null) {
        throw InvalidSearchParameter(
          "SearchParameter.code '$code' on $base is defined by the "
          'specification; an upload cannot redefine it',
        );
      }
    }
    final ExpressionNode parsed;
    try {
      parsed = engine.parse(expression);
    } catch (e) {
      throw InvalidSearchParameter(
        'SearchParameter.expression does not parse: $e',
      );
    }
    if (definition.childValue('status') != 'active') return null;
    final declared = definition
        .children('comparator')
        .map((c) => c.primitiveValue)
        .whereType<String>()
        .toList();
    return CustomSearchParameter(
      code: code,
      type: type,
      bases: bases,
      targets: definition
          .children('target')
          .map((t) => t.primitiveValue)
          .whereType<String>()
          .toList(),
      expression: expression,
      parsed: parsed,
      comparators: declared.isNotEmpty
          ? declared
          : const {'date', 'number', 'quantity'}.contains(type)
              ? _orderedComparators
              : const [],
      url: definition.childValue('url'),
      id: definition.resourceId,
    );
  }

  /// Registers [definition]; see [parse] for what is refused.
  CustomSearchParameter? add(FhirNode definition) {
    final parameter = parse(definition);
    if (parameter == null) return null;
    for (final base in parameter.bases) {
      _byBase.putIfAbsent(base, () => {})[parameter.code] = parameter;
    }
    return parameter;
  }

  /// The index rows of [resource] for every registered parameter that
  /// applies to it, appended to [into]. Each expression is evaluated by the
  /// engine and its values handed to the row builder of the parameter's
  /// type, the same builders the generated extractor uses. An evaluation
  /// error propagates: the save fails rather than storing a resource the
  /// parameter cannot find, as every other indexing failure does here.
  Future<void> appendRows(FhirNode resource, SearchParameterLists into) async {
    final parameters = forType(resource.fhirType);
    if (parameters.isEmpty) return;
    final resourceType = resource.fhirType;
    final id = resource.resourceId;
    if (id == null) return;
    final lastUpdated = resource.metaLastUpdated?.millisecondsSinceEpoch ?? 0;
    for (final p in parameters) {
      final values = await engine.evaluate(resource, p.parsed);
      var i = 0;
      for (final value in values) {
        switch (p.type) {
          case 'string':
            into.stringParams.addAll(
              indexer.stringRows(
                value,
                resourceType,
                id,
                lastUpdated,
                p.expression,
                i,
                searchName: p.code,
              ),
            );
          case 'token':
            into.tokenParams.addAll(
              indexer.tokenRows(
                value,
                resourceType,
                id,
                lastUpdated,
                p.expression,
                i,
                searchName: p.code,
              ),
            );
          case 'reference':
            into.referenceParams.addAll(
              indexer.referenceRows(
                value,
                resourceType,
                id,
                lastUpdated,
                p.expression,
                i,
                searchName: p.code,
              ),
            );
          case 'date':
            into.dateParams.addAll(
              indexer.dateRows(
                value,
                resourceType,
                id,
                lastUpdated,
                p.expression,
                i,
                searchName: p.code,
              ),
            );
          case 'quantity':
            into.quantityParams.addAll(
              indexer.quantityRows(
                value,
                resourceType,
                id,
                lastUpdated,
                p.expression,
                i,
                searchName: p.code,
              ),
            );
          case 'number':
            into.numberParams.addAll(
              indexer.numberRows(
                value,
                resourceType,
                id,
                lastUpdated,
                p.expression,
                i,
                searchName: p.code,
              ),
            );
          case 'uri':
            into.uriParams.addAll(
              indexer.uriRows(
                value,
                resourceType,
                id,
                lastUpdated,
                p.expression,
                i,
                searchName: p.code,
              ),
            );
          case 'special':
            into.specialParams.addAll(
              indexer.specialRows(
                value,
                resourceType,
                id,
                lastUpdated,
                p.expression,
                i,
                searchName: p.code,
              ),
            );
        }
        i++;
      }
    }
  }
}

/// What the engine may ask of the store while indexing. `resolve()` on a
/// literal reference answers a resource of the referenced TYPE with that id
/// and nothing else, built by [stub] (the model's own parser over
/// `{"resourceType": T, "id": id}`), without a fetch: `subject.where(
/// resolve() is Patient)` then holds for `Patient/123` whether or not that
/// Patient is stored yet, which is what the generated extractor tests and
/// what the reference servers do at index time. A type the model does not
/// know makes [stub] throw, which the engine reads as unresolved. Nothing
/// else is provided: no constants, no host functions, no profiles, no value
/// sets.
class IndexHostServices implements IEvaluationContext {
  /// Creates the services over [stub].
  const IndexHostServices(this.stub);

  /// A resource of the model with only a type and an id.
  final FhirNode Function(String resourceType, String id) stub;

  // A literal reference ends in Type/id, optionally /_history/vid, after an
  // optional absolute base (references.html "Literal References"). Only the
  // type and id are read here.
  static final RegExp _typeAndId = RegExp(
    r'([A-Za-z]+)/([A-Za-z0-9\-\.]{1,64})(?:/_history/[A-Za-z0-9\-\.]{1,64})?$',
  );

  @override
  FhirNode resolveReference(
    FHIRPathEngine engine,
    Object appContext,
    String url,
    FhirNode refContext,
  ) {
    final m = _typeAndId.firstMatch(url);
    if (m == null) {
      throw ArgumentError.value(url, 'url', 'not a literal Type/id reference');
    }
    return stub(m.group(1)!, m.group(2)!);
  }

  @override
  List<FhirNode> resolveConstant(
    FHIRPathEngine? engine,
    Object? appContext,
    String? name,
    bool beforeContext,
    bool explicitConstant,
  ) =>
      const [];

  @override
  TypeDetails resolveConstantType(
    FHIRPathEngine engine,
    Object appContext,
    String name,
    bool explicitConstant,
  ) =>
      throw UnsupportedError('no constants while indexing: %$name');

  @override
  bool fpLog(String argument, List<FhirNode> focus) => false;

  @override
  FunctionDetails resolveFunction(FHIRPathEngine engine, String functionName) =>
      throw UnsupportedError('no host functions while indexing: $functionName');

  @override
  TypeDetails checkFunction(
    FHIRPathEngine engine,
    Object appContext,
    String functionName,
    TypeDetails focus,
    List<TypeDetails> parameters,
  ) =>
      throw UnsupportedError('no host functions while indexing: $functionName');

  @override
  List<FhirNode> executeFunction(
    FHIRPathEngine engine,
    Object? appContext,
    List<FhirNode> focus,
    String? functionName,
    List<List<FhirNode>> parameters,
  ) =>
      throw UnsupportedError('no host functions while indexing: $functionName');

  @override
  bool conformsToProfile(
    FHIRPathEngine engine,
    Object appContext,
    FhirNode item,
    String url,
  ) =>
      false;

  @override
  FhirNode? resolveValueSet(
    FHIRPathEngine engine,
    Object? appContext,
    String url,
  ) =>
      null;
}
