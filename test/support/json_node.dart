import 'dart:convert';

import 'package:fhir_db/fhir_db.dart';
import 'package:fhir_node/fhir_node.dart';

/// A [FhirNode] over plain JSON, for the core's own tests: no FHIR version
/// is linked. Type names come from `resourceType` for a resource and from
/// a small table of element names for the complex types the index reads;
/// primitives carry their JSON value as text.
class JsonNode implements FhirNode {
  JsonNode(this.value, {required this.fhirType});

  /// A resource from its JSON map.
  factory JsonNode.resource(Map<String, dynamic> json) =>
      JsonNode(json, fhirType: json['resourceType']! as String);

  final Object? value;

  @override
  final String fhirType;

  Map<String, dynamic> get map => value! as Map<String, dynamic>;

  @override
  bool get isPrimitive => value is! Map && value is! List;

  @override
  bool get isResource => value is Map && map.containsKey('resourceType');

  @override
  String? get primitiveValue => isPrimitive ? value?.toString() : null;

  @override
  bool hasType(List<String> names) =>
      names.any((n) => n.toLowerCase() == fhirType.toLowerCase());

  @override
  bool isEmpty() => value == null;

  @override
  bool get isMetadataBased => false;

  @override
  bool equalsDeep(covariant FhirNode? other) =>
      other is JsonNode && jsonEncode(value) == jsonEncode(other.value);

  @override
  List<String> listChildrenNames() =>
      value is Map ? map.keys.toList() : const [];

  @override
  FhirNode? getChildByName(String name) {
    final all = getChildrenByName(name);
    return all.isEmpty ? null : all.first;
  }

  @override
  List<FhirNode> getChildrenByName(String name, [bool checkValid = false]) {
    if (value is! Map) return const [];
    var v = map[name];
    var type = v == null ? null : _childType(fhirType, name, v);
    if (v == null) {
      // A choice element: `value` finds `valueQuantity`, typed by its
      // suffix, as the model's getChildrenByName does.
      for (final key in map.keys) {
        if (key.startsWith(name) &&
            key.length > name.length &&
            key[name.length].toUpperCase() == key[name.length]) {
          v = map[key];
          final suffix = key.substring(name.length);
          type = _primitiveSuffixes.contains(suffix)
              ? suffix[0].toLowerCase() + suffix.substring(1)
              : suffix;
          break;
        }
      }
    }
    if (v == null || type == null) return const [];
    if (v is List) {
      return [for (final e in v) JsonNode(e, fhirType: type)];
    }
    return [JsonNode(v, fhirType: type)];
  }

  static const _primitiveSuffixes = {
    'String',
    'Integer',
    'Boolean',
    'DateTime',
    'Date',
    'Decimal',
    'Time',
    'Instant',
    'Uri',
    'Code',
  };

  /// The FHIR type of child [name] of a [parent] type, from the element
  /// table below; a nested map with `resourceType` is that resource.
  static String _childType(String parent, String name, Object? v) {
    if (v is Map && v['resourceType'] is String) {
      return v['resourceType'] as String;
    }
    if (v is List &&
        v.isNotEmpty &&
        v.first is Map &&
        (v.first as Map)['resourceType'] is String) {
      return (v.first as Map)['resourceType'] as String;
    }
    return elementTypes['$parent.$name'] ?? elementTypes['*.$name'] ?? 'string';
  }
}

/// Element → FHIR type, for what the tests exercise.
const elementTypes = <String, String>{
  '*.id': 'id',
  '*.meta': 'Meta',
  'Meta.versionId': 'id',
  'Meta.lastUpdated': 'instant',
  'Meta.tag': 'Coding',
  'Meta.security': 'Coding',
  'Meta.profile': 'canonical',
  '*.contained': 'Resource',
  'Patient.name': 'HumanName',
  'Patient.gender': 'code',
  'Patient.birthDate': 'date',
  'Patient.active': 'boolean',
  'Patient.identifier': 'Identifier',
  'Patient.telecom': 'ContactPoint',
  'Patient.address': 'Address',
  'Patient.deceasedDateTime': 'dateTime',
  'Patient.link': 'PatientLink',
  'PatientLink.other': 'Reference',
  'HumanName.family': 'string',
  'HumanName.given': 'string',
  'HumanName.prefix': 'string',
  'HumanName.suffix': 'string',
  'HumanName.text': 'string',
  'Identifier.system': 'uri',
  'Identifier.value': 'string',
  'Identifier.type': 'CodeableConcept',
  'ContactPoint.value': 'string',
  'ContactPoint.system': 'code',
  'Address.line': 'string',
  'Address.city': 'string',
  'Address.postalCode': 'string',
  'Address.country': 'string',
  'Observation.status': 'code',
  'Observation.code': 'CodeableConcept',
  'Observation.subject': 'Reference',
  'Observation.performer': 'Reference',
  'Observation.effectiveDateTime': 'dateTime',
  'Observation.effectivePeriod': 'Period',
  'Observation.valueQuantity': 'Quantity',
  'Observation.valueString': 'string',
  'Observation.valueInteger': 'integer',
  'Observation.component': 'ObservationComponent',
  'ObservationComponent.code': 'CodeableConcept',
  'ObservationComponent.valueQuantity': 'Quantity',
  'CodeableConcept.coding': 'Coding',
  'CodeableConcept.text': 'string',
  'Coding.system': 'uri',
  'Coding.code': 'code',
  'Coding.display': 'string',
  'Reference.reference': 'string',
  'Reference.identifier': 'Identifier',
  'CodeableReference.concept': 'CodeableConcept',
  'CodeableReference.reference': 'Reference',
  'Range.low': 'Quantity',
  'Range.high': 'Quantity',
  'Timing.event': 'dateTime',
  'Period.start': 'dateTime',
  'Period.end': 'dateTime',
  'Quantity.value': 'decimal',
  'Quantity.unit': 'string',
  'Quantity.system': 'uri',
  'Quantity.code': 'code',
  'Encounter.status': 'code',
  'Encounter.subject': 'Reference',
  'Encounter.period': 'Period',
  'ValueSet.url': 'uri',
  'ValueSet.compose': 'ValueSetCompose',
  'ValueSetCompose.include': 'ValueSetInclude',
  'ValueSetCompose.exclude': 'ValueSetInclude',
  'ValueSetInclude.system': 'uri',
  'ValueSetInclude.concept': 'ValueSetConcept',
  'ValueSetInclude.filter': 'ValueSetFilter',
  'ValueSetInclude.valueSet': 'canonical',
  'ValueSetConcept.code': 'code',
  'ValueSet.expansion': 'ValueSetExpansion',
  'ValueSetExpansion.contains': 'ValueSetContains',
  'ValueSetContains.system': 'uri',
  'ValueSetContains.code': 'code',
  'ValueSetContains.contains': 'ValueSetContains',
  'CodeSystem.url': 'uri',
  'CodeSystem.concept': 'CodeSystemConcept',
  'CodeSystemConcept.code': 'code',
  'CodeSystemConcept.concept': 'CodeSystemConcept',
  'Location.position': 'LocationPosition',
  'LocationPosition.latitude': 'decimal',
  'LocationPosition.longitude': 'decimal',
};

/// The test model: JSON in and out, a hand-written extractor over the
/// [SearchIndexer] for a handful of parameters, definitions to match.
class JsonModel extends FhirModel<JsonNode, String> {
  JsonModel();

  late final SearchIndexer indexer = SearchIndexer(this);

  @override
  String get fhirVersion => 'test';

  @override
  Set<String> get resourceTypeNames => const {
        'Patient',
        'Observation',
        'Encounter',
        'ValueSet',
        'CodeSystem',
        'Location',
        'Basic',
      };

  @override
  String? typeFromName(String name) =>
      resourceTypeNames.contains(name) ? name : null;

  @override
  JsonNode fromJson(String json) =>
      JsonNode.resource(jsonDecode(json) as Map<String, dynamic>);

  @override
  String toJson(JsonNode resource) => jsonEncode(resource.value);

  @override
  Map<String, dynamic> jsonOf(FhirNode element) =>
      Map<String, dynamic>.from((element as JsonNode).map);

  @override
  String jsonText(FhirNode element) => jsonEncode((element as JsonNode).value);

  @override
  JsonNode withId(JsonNode resource, String id) =>
      JsonNode.resource({...resource.map, 'id': id});

  @override
  JsonNode withMeta(JsonNode resource, Map<String, dynamic> meta) =>
      JsonNode.resource({...resource.map, 'meta': meta});

  @override
  Map<String, Map<String, List<String>>> get compartmentDefinitions => const {
        'Patient': {
          'Observation': ['subject', 'performer'],
          'Encounter': ['subject'],
          'Patient': ['link'],
        },
      };

  @override
  SearchDefinitions get searchParameters => const SearchDefinitions({
        'Resource': {
          '_id': SearchParameterDefinition('token', []),
          '_lastUpdated': SearchParameterDefinition(
            'date',
            ['eq', 'ne', 'gt', 'ge', 'lt', 'le', 'sa', 'eb', 'ap'],
          ),
          '_tag': SearchParameterDefinition('token', []),
          '_profile': SearchParameterDefinition('uri', []),
          '_security': SearchParameterDefinition('token', []),
        },
        'Patient': {
          'name': SearchParameterDefinition('string', []),
          'family': SearchParameterDefinition('string', []),
          'given': SearchParameterDefinition('string', []),
          'gender': SearchParameterDefinition('token', []),
          'birthdate': SearchParameterDefinition(
            'date',
            ['eq', 'ne', 'gt', 'ge', 'lt', 'le', 'sa', 'eb', 'ap'],
          ),
          'identifier': SearchParameterDefinition('token', []),
          'active': SearchParameterDefinition('token', []),
          'phone': SearchParameterDefinition('token', []),
          'address': SearchParameterDefinition('string', []),
          'link': SearchParameterDefinition(
            'reference',
            [],
            targets: ['Patient', 'RelatedPerson'],
          ),
        },
        'Observation': {
          'code': SearchParameterDefinition('token', []),
          'status': SearchParameterDefinition('token', []),
          'subject':
              SearchParameterDefinition('reference', [], targets: ['Patient']),
          'patient':
              SearchParameterDefinition('reference', [], targets: ['Patient']),
          'performer':
              SearchParameterDefinition('reference', [], targets: ['Patient']),
          'date': SearchParameterDefinition(
            'date',
            ['eq', 'ne', 'gt', 'ge', 'lt', 'le', 'sa', 'eb', 'ap'],
          ),
          'value-quantity': SearchParameterDefinition(
            'quantity',
            ['eq', 'ne', 'gt', 'ge', 'lt', 'le', 'sa', 'eb', 'ap'],
          ),
          'value-string': SearchParameterDefinition('string', []),
          'code-value-quantity': SearchParameterDefinition(
            'composite',
            [],
            components: [
              SearchComponent('token', 'code'),
              SearchComponent('quantity', 'value.as(Quantity)'),
            ],
          ),
          'component-code': SearchParameterDefinition('token', []),
        },
        'Encounter': {
          'status': SearchParameterDefinition('token', []),
          'subject':
              SearchParameterDefinition('reference', [], targets: ['Patient']),
          'patient':
              SearchParameterDefinition('reference', [], targets: ['Patient']),
          'date': SearchParameterDefinition(
            'date',
            ['eq', 'ne', 'gt', 'ge', 'lt', 'le', 'sa', 'eb', 'ap'],
          ),
        },
        'ValueSet': {'url': SearchParameterDefinition('uri', [])},
        'CodeSystem': {'url': SearchParameterDefinition('uri', [])},
        'Location': {'near': SearchParameterDefinition('special', [])},
      });

  /// The extractor a binding generates, written by hand for the types
  /// above: each parameter's elements to the row builder of its type.
  @override
  SearchParameterLists extract(JsonNode resource) {
    final lists = SearchParameterLists();
    final type = resource.fhirType;
    final id = resource.resourceId!;
    final lastUpdated = resource.metaLastUpdated!.millisecondsSinceEpoch;
    void token(String path, String name, List<FhirNode> values) {
      for (final (i, v) in values.indexed) {
        lists.tokenParams.addAll(
          indexer.tokenRows(
            v,
            type,
            id,
            lastUpdated,
            path,
            i,
            searchName: name,
          ),
        );
      }
    }

    void string(String path, String name, List<FhirNode> values) {
      for (final (i, v) in values.indexed) {
        lists.stringParams.addAll(
          indexer.stringRows(
            v,
            type,
            id,
            lastUpdated,
            path,
            i,
            searchName: name,
          ),
        );
      }
    }

    void reference(String path, String name, List<FhirNode> values) {
      for (final (i, v) in values.indexed) {
        lists.referenceParams.addAll(
          indexer.referenceRows(
            v,
            type,
            id,
            lastUpdated,
            path,
            i,
            searchName: name,
          ),
        );
      }
    }

    void date(String path, String name, List<FhirNode> values) {
      for (final (i, v) in values.indexed) {
        lists.dateParams.addAll(
          indexer.dateRows(v, type, id, lastUpdated, path, i, searchName: name),
        );
      }
    }

    void quantity(String path, String name, List<FhirNode> values) {
      for (final (i, v) in values.indexed) {
        lists.quantityParams.addAll(
          indexer.quantityRows(
            v,
            type,
            id,
            lastUpdated,
            path,
            i,
            searchName: name,
          ),
        );
      }
    }

    // Resource-level
    token('Resource.id', '_id', resource.children('id'));
    final meta = resource.child('meta');
    if (meta != null) {
      date(
        'Resource.meta.lastUpdated',
        '_lastUpdated',
        meta.children('lastUpdated'),
      );
      token('Resource.meta.tag', '_tag', meta.children('tag'));
      token('Resource.meta.security', '_security', meta.children('security'));
      for (final (i, v) in meta.children('profile').indexed) {
        lists.uriParams.addAll(
          indexer.uriRows(
            v,
            type,
            id,
            lastUpdated,
            'Resource.meta.profile',
            i,
            searchName: '_profile',
          ),
        );
      }
    }
    switch (type) {
      case 'Patient':
        string('Patient.name', 'name', resource.children('name'));
        for (final n in resource.children('name')) {
          string('Patient.name.family', 'family', n.children('family'));
          string('Patient.name.given', 'given', n.children('given'));
        }
        token('Patient.gender', 'gender', resource.children('gender'));
        date('Patient.birthDate', 'birthdate', resource.children('birthDate'));
        token(
          'Patient.identifier',
          'identifier',
          resource.children('identifier'),
        );
        token('Patient.active', 'active', resource.children('active'));
        token('Patient.telecom', 'phone', resource.children('telecom'));
        string('Patient.address', 'address', resource.children('address'));
        for (final l in resource.children('link')) {
          reference('Patient.link.other', 'link', l.children('other'));
        }
      case 'Observation':
        token('Observation.code', 'code', resource.children('code'));
        token('Observation.status', 'status', resource.children('status'));
        reference(
          'Observation.subject',
          'subject',
          resource.children('subject'),
        );
        reference(
          'Observation.subject',
          'patient',
          resource.children('subject'),
        );
        reference(
          'Observation.performer',
          'performer',
          resource.children('performer'),
        );
        date('Observation.effective', 'date', [
          ...resource.children('effectiveDateTime'),
          ...resource.children('effectivePeriod'),
        ]);
        quantity(
          'Observation.value',
          'value-quantity',
          resource.children('valueQuantity'),
        );
        string(
          'Observation.value',
          'value-string',
          resource.children('valueString'),
        );
        for (final c in resource.children('component')) {
          token(
            'Observation.component.code',
            'component-code',
            c.children('code'),
          );
        }
        lists.compositeParams.addAll(
          indexer.compositeRows(
            resource,
            type,
            id,
            lastUpdated,
            'Observation',
            0,
            searchName: 'code-value-quantity',
            root: resource,
          ),
        );
      case 'Encounter':
        token('Encounter.status', 'status', resource.children('status'));
        reference('Encounter.subject', 'subject', resource.children('subject'));
        reference('Encounter.subject', 'patient', resource.children('subject'));
        date('Encounter.period', 'date', resource.children('period'));
      case 'ValueSet' || 'CodeSystem':
        for (final (i, v) in resource.children('url').indexed) {
          lists.uriParams.addAll(
            indexer.uriRows(
              v,
              type,
              id,
              lastUpdated,
              '$type.url',
              i,
              searchName: 'url',
            ),
          );
        }
      case 'Location':
        for (final (i, v) in resource.children('position').indexed) {
          lists.specialParams.addAll(
            indexer.specialRows(
              v,
              type,
              id,
              lastUpdated,
              'Location.position',
              i,
              searchName: 'near',
            ),
          );
        }
    }
    return lists;
  }
}
