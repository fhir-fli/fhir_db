import 'package:drift/drift.dart';
import 'package:fhir_db/src/fhir_model.dart';
import 'package:fhir_db/src/search/search_parameter_types.dart';
import 'package:fhir_node/fhir_node.dart';

/// The index rows of [resource] and of every resource it contains.
///
/// R4B search.html 3.1.1.5.5, read whole 2026-09-07: the `_contained`
/// parameter selects contained resources, and a contained resource is
/// searched under its own type. Its rows are filed under type `#Type` with
/// id `[containerType]/[containerId]#[containedId]`, so a search of the
/// type can be asked with or without them and a delete of the container
/// takes them along ([FhirDao.containedRowsOf]). Rows for the container's
/// own parameters that read into `contained` are unaffected.
///
/// A contained resource has no `meta` of its own, and the generated
/// extractor needs `meta.lastUpdated`, so it borrows the container's.
SearchParameterLists extractWithContained(
  FhirModel<FhirNode, Object> model,
  FhirNode resource,
) {
  final lists = model.extract(resource);
  final contained = resource.children('contained');
  if (contained.isEmpty) return lists;
  final containerType = resource.fhirType;
  final containerId = resource.resourceId;
  if (containerId == null) return lists;
  final lastUpdated = resource.child('meta')?.childValue('lastUpdated');
  // Contained id → the type its rows are filed under.
  final containedTypes = <String, String>{};
  for (final inner in contained) {
    final innerId = inner.resourceId;
    if (innerId == null) continue;
    final type = '#${inner.fhirType}';
    final id = '$containerType/$containerId#$innerId';
    containedTypes[innerId] = type;
    final innerMeta = inner.child('meta');
    final withMeta =
        innerMeta?.childValue('lastUpdated') != null || lastUpdated == null
            ? inner
            : model.withMeta(inner, {
                ...?(innerMeta == null ? null : model.jsonOf(innerMeta)),
                'lastUpdated': lastUpdated,
              });
    final innerLists = model.extract(withMeta);
    lists.addAll(_refiled(innerLists, type, id));
  }

  // The container's `#m1` references now point at the contained rows.
  for (var i = 0; i < lists.referenceParams.length; i++) {
    final row = lists.referenceParams[i];
    final written = row.referenceValue.value;
    if (written == null || !written.startsWith('#')) continue;
    final type = containedTypes[written.substring(1)];
    if (type == null) continue;
    lists.referenceParams[i] = row.copyWith(
      referenceResourceType: Value(type),
      referenceIdPart: Value('$containerType/$containerId$written'),
    );
  }
  return lists;
}

/// [lists] with every row's owner set to ([type], [id]).
SearchParameterLists _refiled(
  SearchParameterLists lists,
  String type,
  String id,
) {
  final out = SearchParameterLists();
  for (final r in lists.stringParams) {
    out.stringParams.add(r.copyWith(resourceType: Value(type), id: Value(id)));
  }
  for (final r in lists.tokenParams) {
    out.tokenParams.add(r.copyWith(resourceType: Value(type), id: Value(id)));
  }
  for (final r in lists.referenceParams) {
    out.referenceParams
        .add(r.copyWith(resourceType: Value(type), id: Value(id)));
  }
  for (final r in lists.dateParams) {
    out.dateParams.add(r.copyWith(resourceType: Value(type), id: Value(id)));
  }
  for (final r in lists.numberParams) {
    out.numberParams.add(r.copyWith(resourceType: Value(type), id: Value(id)));
  }
  for (final r in lists.quantityParams) {
    out.quantityParams
        .add(r.copyWith(resourceType: Value(type), id: Value(id)));
  }
  for (final r in lists.uriParams) {
    out.uriParams.add(r.copyWith(resourceType: Value(type), id: Value(id)));
  }
  for (final r in lists.compositeParams) {
    out.compositeParams
        .add(r.copyWith(resourceType: Value(type), id: Value(id)));
  }
  for (final r in lists.specialParams) {
    out.specialParams.add(r.copyWith(resourceType: Value(type), id: Value(id)));
  }
  return out;
}
