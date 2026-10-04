import 'dart:convert';

import 'package:fhir_db/fhir_db.dart';
import 'package:fhir_node/fhir_node.dart';

export 'package:fhir_node/fhir_node.dart' show JsonNode;

/// A resource over [elementTypes], so its children carry the types the
/// indexer reads.
JsonNode jsonResource(Map<String, dynamic> json) =>
    JsonNode.resource(json, elementTypes: elementTypes);

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
  JsonNode fromJsonText(String json) =>
      fromJson(jsonDecode(json) as Map<String, dynamic>);

  @override
  String toJsonText(JsonNode resource) => jsonEncode(resource.value);

  @override
  JsonNode fromJson(Map<String, dynamic> json) =>
      JsonNode.resource(json, elementTypes: elementTypes);

  @override
  Map<String, dynamic> toJson(JsonNode resource) => resource.json;

  @override
  Map<String, dynamic> jsonOf(FhirNode element) =>
      Map<String, dynamic>.from((element as JsonNode).json);

  @override
  String jsonText(FhirNode element) => jsonEncode((element as JsonNode).value);

  @override
  JsonNode withId(JsonNode resource, String id) =>
      fromJson({...resource.json, 'id': id});

  @override
  JsonNode withMeta(JsonNode resource, Map<String, dynamic> meta) =>
      fromJson({...resource.json, 'meta': meta});

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
          // Typed as the R4B definitions type them (fhir_r4_db
          // search_parameter_types.dart: `_text`, `_content`, `_list` are
          // 'string').
          '_text': SearchParameterDefinition('string', []),
          '_content': SearchParameterDefinition('string', []),
          '_list': SearchParameterDefinition('string', []),
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
